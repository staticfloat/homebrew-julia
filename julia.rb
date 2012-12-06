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
  
  # We have our custom formulae of arpack-ng, openblas and suite-sparse, pending acceptance into either homebrew-science or homebrew-main
  depends_on "staticfloat/julia/arpack-ng"
  depends_on "staticfloat/julia/suite-sparse"
  depends_on "staticfloat/julia/openblas"

  # Soon we will remove lighttpd in favor of nginx
  depends_on "lighttpd"
  depends_on "nginx"
  
  # Because of new tk wrapper part
  depends_on :x11
  
  # Need this as Julia's build process is quite messy with respect to env variables
  env :std

  # Options that can be passed to the build process
  option "build-debug", "Builds julia with debugging information included"

  # Here we build up a list of patches to be applied
  def patches
    patch_list = []
    
    # First patch fixes hardcoded location of glpk.h
    patch_list << "https://raw.github.com/gist/3806089/77b10c7bf7bac9370806cdc7e887435d56b505f6/glpk.h.diff"
    
    # Second patch fixes hardcoded paths to deps in deps/Makefile
    patch_list << "https://raw.github.com/gist/3806093/0f1f38e9f03dcfecd5b01df082ed60ef3f5a6562/deps.Makefile.diff"

    # Third patch forces us to link with OpenBLAS, not Accelerate
    patch_list << "https://raw.github.com/gist/3806092/426a2912a0a0fec764e4048801a9427e615e33d7/make.inc.diff"
    
    return patch_list
  end

  def install
    ENV.fortran

    # This makes it easier to see what has broken
    ENV.deparallelize if build.has_option? "d"

    # Hack to allow julia to get the git version on demand
    ENV['GIT_DIR'] = cached_download/'.git'
    
    # Have to include CPPFLAGS in CFLAGS and CXXFLAGS because Julia's buildsystem doesn't listen to CPPFLAGS
    ENV['CFLAGS'] += ' ' + ENV['CPPFLAGS']
    ENV['CXXFLAGS'] += ' ' + ENV['CPPFLAGS']

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
    ln_s "#{Formula.factory('openblas').opt_prefix}/lib/libopenblas.dylib", "usr/lib/"
    ln_s "#{Formula.factory('pcre').lib}/libpcre.dylib", "usr/lib/"

    # call make with the build options
    target = "release"
    if build.include? "build-debug"
      target = "debug"
      ohai "Making debug build"
    end
    system "make", target, *build_opts

    if not build.include? "build-debug"
      # Have to actually go into deps to make install-tk-wrapper.  What's all that about, eh?
      cd "deps"
      system "make", "install-tk-wrapper", *build_opts
      cd ".."
    end
    
    # Remove the fftw symlinks again, so we don't have conflicts when installing julia
    ['', 'f', '_threads', 'f_threads'].each do |ext|
      rm "usr/lib/libfftw3#{ext}.dylib"
    end
    rm "usr/lib/libopenblas.dylib"
    rm "usr/lib/libpcre.dylib"

    # Add in rpath's into the julia executables so that they can find the homebrew lib folder,
    # as well as any keg-only libraries that they need.
    ["#{HOMEBREW_PREFIX}/lib", "#{Formula.factory('openblas').opt_prefix}/lib", "/usr/X11/lib"].each do |rpath|
      system "install_name_tool", "-add_rpath", rpath, "usr/bin/julia-#{target}-basic"
      system "install_name_tool", "-add_rpath", rpath, "usr/bin/julia-#{target}-readline"
    end

    # Install!
    system "make", *(build_opts + ["install"])
  end

  def test
    # Run julia-provided test suite, copied over in install step
    chdir "#{share}/julia/test"
    system "#{bin}/julia", "runtests.jl", "all"
  end
  
  def caveats
    caveat = ""
    if build.include? "build-debug"
      caveat += "Because this was a debug build, the tk wrapper has not been installed\n\n"
    end

    caveat + <<-EOS.undent
    Documentation and Examples have been installed into:
    #{share}/julia
    
    Test suite has been installed into:
    #{share}/julia/test
     
    Run the command `brew test -v julia` to run all tests.
    EOS
  end
end
