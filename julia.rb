require 'formula'

class Julia < Formula
  homepage 'http://julialang.org'
  head 'https://github.com/JuliaLang/julia.git'

  depends_on "readline"
  depends_on "pcre"
  depends_on "gmp"
  depends_on "llvm"
  depends_on "glpk"
  depends_on "fftw"
  depends_on "homebrew/dupes/zlib"
  
  # We have our custom formulae of arpack-ng, openblas and suite-sparse, pending acceptance into either homebrew-science or homebrew-main
  if build.include? "with-accelerate"
    depends_on "staticfloat/julia/arpack-ng"
    depends_on "staticfloat/julia/suite-sparse"
  else
    depends_on "staticfloat/julia/arpack-ng" => "with-openblas"
    depends_on "staticfloat/julia/suite-sparse" => "with-openblas"
    depends_on "staticfloat/julia/openblas"
  end

  # Soon we will remove lighttpd in favor of nginx
  depends_on "lighttpd"
  depends_on "nginx"
  
  # This option forces us to use accelerate, as opposed to the default of openblas
  option "with-accelerate", "Use Apple's Accelerate framework instead of OpenBLAS for linear algebra routines"
  
  # Fixes strip issues, thanks to @nolta
  skip_clean 'bin'
  
  # Need this as Julia's build process is quite messy with respect to env variables
  env :std

  # Here we build up a list of patches to be applied
  def patches
    patch_list = []
    
    # First patch fixes hardcoded location of glpk.h
    patch_list << "https://raw.github.com/gist/3806089/77b10c7bf7bac9370806cdc7e887435d56b505f6/glpk.h.diff"
    
    # Second patch fixes hardcoded paths to deps in deps/Makefile
    patch_list << "https://raw.github.com/gist/3806093/7c812721a27b9e88f74facc4d726044d415c4c41/deps.Makefile.diff"
    
    # Finally, if we're compiling for openblas, we need to patch that into make.inc
    if not build.include? "with-accelerate"
      patch_list << "https://raw.github.com/gist/3806092/5993e2f3753e1cbb7725be20ac3b3f7dc9eab56c/make.inc.diff"
    end
    
    return patch_list
  end

  def install
    ENV.fortran
    ENV.deparallelize if build.has_option? "d"

    # Hack to allow julia to get the git version on demand
    ENV['GIT_DIR'] = cached_download/'.git'
    
    # Have to include CPPFLAGS in CFLAGS and CXXFLAGS because Julia's buildsystem doesn't listen to CPPFLAGS
    ENV['CFLAGS'] += ' ' + ENV['CPPFLAGS']
    ENV['CXXFLAGS'] += ' ' + ENV['CPPFLAGS']

    # This from @ijt's formula, with possible exclusion if @sharpie makes standard for ENV.fortran builds
    libgfortran = `$FC --print-file-name libgfortran.a`.chomp
    ENV.append "LDFLAGS", "-L#{File.dirname libgfortran}"

    # Build up list of build options
    build_opts = ["PREFIX=#{prefix}"]

    # Tell julia about our gfortran 
    # (this enables use of gfortran-4.7 from the tap homebrew-dupes/gcc.rb)
    build_opts << "FC=#{ENV['FC']}"

    # Make sure Julia uses clang if the environment supports it
    build_opts << "USECLANG=1" if ENV.compiler == :clang

    # Kudos to @ijt for these lines of code
    ['ZLIB', 'FFTW', 'READLINE', 'GLPK', 'GMP', 'LLVM', 'PCRE', 'LIGHTTPD', 'BLAS', 'LAPACK', 'SUITESPARSE', 'ARPACK', 'NGINX'].each do |dep|
      build_opts << "USE_SYSTEM_#{dep}=1"
    end
    
    # call makefile to grab suitesparse libraries
    system "make", "-C", "contrib", "-f", "repackage_system_suitesparse4.make", *build_opts

    # Sneak in the fftw libraries, as julia doesn't know how to load dylibs from any place other than
    # julia's usr/lib directory and system default paths yet; the build process fixes that after the
    # install step, but the bootstrapping process requires the use of the fftw libraries before then
    ['', 'f', '_threads', 'f_threads'].each do |ext|
      ln_s "#{Formula.factory('fftw').lib}/libfftw3#{ext}.dylib", "usr/lib/"
    end
    if not build.include? "with-accelerate"
      ln_s "#{Formula.factory('openblas').lib}/libopenblas.dylib", "usr/lib/"
    end

    # call make with the build options
    system "make", *build_opts

    # Remove the fftw symlinks again, so we don't have conflicts when installing julia
    ['', 'f', '_threads', 'f_threads'].each do |ext|
      rm "usr/lib/libfftw3#{ext}.dylib"
    end
    if not build.include? "with-accelerate"
      rm "usr/lib/libopenblas.dylib"
    end

    # Add in rpath's into the julia executables so that they can find the homebrew lib folder,
    # as well as any keg-only libraries that they need.
    ["#{HOMEBREW_PREFIX}/lib", "#{Formula.factory('openblas').lib}"].each do |rpath|
      system "install_name_tool", "-add_rpath", rpath, "usr/bin/julia-release-basic"
      system "install_name_tool", "-add_rpath", rpath, "usr/bin/julia-release-readline"
      system "install_name_tool", "-add_rpath", rpath, "usr/bin/julia-release-webserver"
    end

    # Install!
    system "make", *(build_opts + ["install"])

    # and for boatloads of fun, we'll make the test data, and allow it to be run from `brew test julia`
    system "make", "-C", "test/unicode/"
    
    # I want the doc and examples! Todo: write about this in the caveats.
    (share/'julia').install ['doc', 'examples']
    # ...and the tests! (why are they not installed?)
    (lib/'julia').install 'test'
  end

  def test
    # Run julia-provided test suite, copied over in install step
    chdir "#{lib}/julia/test"
    system "#{bin}/julia", "runtests.jl", "all"
  end
  
  def caveats; <<-EOS.undent
    Documentation and Examples have been installed into:
    #{share}/julia
    
    Test suite has been installed into:
    #{lib}/julia/test
     
    Run the command `brew test -v julia` to run all tests.
    EOS
  end
end
