require 'formula'

class GitNoDepthDownloadStrategy < GitDownloadStrategy
  def support_depth?
    false
  end

  # We need the .git folder for it's information, so we clone the whole thing
  # We also want to avoid downloading all the submodules, so we clone those explicitly
  def stage
    dst = Dir.getwd
    @clone.cd do
      reset
      safe_system 'git', 'clone', '.', dst
      # Get the deps/ submodules
      ["Rmath", "libuv", "openlibm"].each do |subm|
        safe_system 'git', 'clone', "deps/#{subm}", "#{dst}/deps/#{subm}"
      end
      # Also the docs submodule
      safe_system 'git', 'clone', 'doc/juliadoc', "#{dst}/doc/juliadoc"
    end
  end
end

# Avoid Julia downloading these tools on demand
# We don't have full formulae for them, as julia makes very specific use of these formulae
class JuliaDoubleConversion < Formula
  url 'http://double-conversion.googlecode.com/files/double-conversion-1.1.1.tar.gz'
  sha1 'de238c7f0ec2d28bd7c54cff05504478a7a72124'
end
class JuliaDSFMT < Formula
  url 'http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/SFMT/dSFMT-src-2.2.tar.gz'
  sha1 'd64e1c1927d6532c62aff271bd1cd0d4859c3c6d'
end

class Julia < Formula
  homepage 'http://julialang.org'
  url 'https://github.com/JuliaLang/julia.git', :using => GitNoDepthDownloadStrategy, :tag => 'v0.2.0'
  head 'https://github.com/JuliaLang/julia.git', :using => GitNoDepthDownloadStrategy

  depends_on "readline"
  depends_on "pcre"
  depends_on "gmp"

  if build.head?
    depends_on "llvm"
  else
    depends_on "llvm33"
  end
  depends_on "fftw"
  depends_on "mpfr"
  
  # We have our custom formulae of arpack, openblas and suite-sparse
  if build.include? "64bit"
    if build.include? 'with-accelerate'
      depends_on "arpack64-julia" => 'with-accelerate'
      depends_on "suite-sparse64-julia" => 'with-accelerate'
    else
      depends_on "arpack64-julia"
      depends_on "suite-sparse64-julia"
      depends_on "openblas64-julia"
    end
  else
    if build.include? 'with-accelerate'
      depends_on "arpack-julia" => 'with-accelerate'
      depends_on "suite-sparse-julia" => 'with-accelerate'
    else
      depends_on "arpack-julia"
      depends_on "suite-sparse-julia"
      depends_on "openblas-julia"
    end
  end
  
  # Need this as Julia's build process is quite messy with respect to env variables
  env :std

  # Options that can be passed to the build process
  option "build-debug", "Builds julia with debugging information included"
  option "64bit", "Builds julia on top of 64-bit linear algebra libraries"
  option "with-accelerate", "Builds julia (and dependent libraries) against Accelerate/vecLib, not OpenBLAS. Incompatible with --64bit option"

  # Here we build up a list of patches to be applied
  def patches
    patch_list = []
    
    # First patch fixes hardcoded paths to deps in deps/Makefile
    patch_list << "https://gist.github.com/staticfloat/3806093/raw/cb34c7262b9130f0e9e07641a66fccaa0d08b5d2/deps.Makefile.diff"

    return patch_list
  end

  def install
    ENV.fortran
    ENV['PLATFORM'] = 'darwin'

    # This is necessary on mavericks so that we can link against the proper bottles
    ENV.cxx += ' -stdlib=libstdc++' if ENV.compiler == :clang && MacOS.version >= :mavericks

    # First, check to make sure we don't have impossible options passed in
    if build.include? "64bit"
      if !Hardware.is_64_bit?
        opoo "Cannot compile 64-bit on a 32-bit architecture!"
      end
      if build.include? "with-accelerate"
        opoo "Cannot compile a 64-bit interface with the Accelerate libraries!"
      end
    end
    
    # Download double-conversion, then symlink it into deps/
    doubleconversion = JuliaDoubleConversion.new
    doubleconversion.brew{}
    ln_s doubleconversion.cached_download, 'deps/'
    ohai "Using double-conversion: #{doubleconversion.cached_download}"
    
    # Download DSFMT, then symlink it into deps/random/
    dsfmt = JuliaDSFMT.new
    dsfmt.brew{}
    ln_s dsfmt.cached_download, 'deps/random/'
    ohai "Using DSFMT: #{dsfmt.cached_download}"
    

    # This makes it easier to see what has broken
    ENV.deparallelize if build.has_option? "d"

    # Build up list of build options
    build_opts = []
    if build.head?
      build_opts = "prefix=#{prefix}"
    else
      build_opts << "PREFIX=#{prefix}"
    end

    # Be sure to get the right library names for when we symlink later on
    openblas = 'openblas-julia'
    arpack = 'arpack-julia'
    suitesparse = 'suite-sparse-julia'
    if build.include? "64bit"
      build_opts << "USE_BLAS64=1"
      openblas = 'openblas64-julia'
      arpack = 'arpack64-julia'
      suitesparse = 'suite-sparse64-julia'
    else
      build_opts << "USE_BLAS64=0"
    end

    # Tell julia about our gfortran 
    # (this enables use of gfortran-4.7 from the tap homebrew-dupes/gcc.rb)
    if ENV.has_key? 'FC'
      build_opts << "FC=#{ENV['FC']}"
    end

    # Tell julia about our llc, if it's been named nonstandardly
    if build.head?
      if which( 'llc' ) == nil
        build_opts << "LLVM_LLC=llc-#{Formula.factory('llvm').version}"
      end
    else
      # Since we build off of llvm33 for v0.2.0, we need to point it directly at llvm33
      build_opts << "LLVM_CONFIG=llvm-config-3.3"
    end
    
    # Make sure we have space to muck around with RPATHS
    ENV['LDFLAGS'] += " -headerpad_max_install_names"

    # Make sure Julia uses clang if the environment supports it
    build_opts << "USECLANG=1" if ENV.compiler == :clang
    #build_opts << "VERBOSE=1" if ARGV.verbose? # Note; this is causing errors!  Don't know why yet...

    if !build.include? "with-accelerate"
        build_opts << "LIBBLAS=-lopenblas"
        build_opts << "LIBBLASNAME=libopenblas"
        build_opts << "LIBLAPACK=-lopenblas"
        build_opts << "LIBLAPACKNAME=libopenblas"
    end

    # Kudos to @ijt for these lines of code
    ['ZLIB', 'FFTW', 'READLINE', 'GLPK', 'GMP', 'LLVM', 'PCRE', 'BLAS', 'SUITESPARSE', 'ARPACK', 'MPFR'].each do |dep|
      build_opts << "USE_SYSTEM_#{dep}=1"
    end
    build_opts << "USE_SYSTEM_LAPACK=1" if !build.include? "with-accelerate"
    
    # call makefile to grab suitesparse libraries
    system "make", "-C", "contrib", "-f", "repackage_system_suitesparse4.make", *build_opts

    # Sneak in the fftw libraries, as julia doesn't know how to load dylibs from any place other than
    # julia's usr/lib directory and system default paths yet; the build process fixes that after the
    # install step, but the bootstrapping process requires the use of the fftw libraries before then
    ['', 'f', '_threads', 'f_threads'].each do |ext|
      ln_s "#{Formula.factory('fftw').lib}/libfftw3#{ext}.dylib", "usr/lib/"
    end
    # Do the same for openblas, pcre, mpfr, and gmp
    ln_s "#{Formula.factory(openblas).opt_prefix}/lib/libopenblas.dylib", "usr/lib/" if !build.include? 'with-accelerate'
    ln_s "#{Formula.factory('pcre').lib}/libpcre.dylib", "usr/lib/"
    ln_s "#{Formula.factory('mpfr').lib}/libmpfr.dylib", "usr/lib/"
    ln_s "#{Formula.factory('gmp').lib}/libgmp.dylib", "usr/lib/"

    # call make with the build options
    target = "release"
    if build.include? "build-debug"
      target = "debug"
      ohai "Making debug build"
    end

    build_opts << target
    system "make", *build_opts
    build_opts.pop

    # Remove the fftw symlinks again, so we don't have conflicts when installing julia
    ['', 'f', '_threads', 'f_threads'].each do |ext|
      rm "usr/lib/libfftw3#{ext}.dylib"
    end
    rm "usr/lib/libopenblas.dylib" if !build.include? 'with-accelerate'
    rm "usr/lib/libpcre.dylib"
    rm "usr/lib/libmpfr.dylib"
    rm "usr/lib/libgmp.dylib"

    # Install!
    build_opts << "install"
    system "make", *build_opts

    # Add in rpath's into the julia executables so that they can find the homebrew lib folder,
    # as well as any keg-only libraries that they need.
    rpaths = []

    # Only add in openblas if we're not using accelerate
    rpathFormulae = [arpack, suitesparse]
    rpathFormulae << openblas if !build.include? 'with-accelerate'

    # Add in each formula to the rpaths list
    rpathFormulae.each do |formula|
      rpaths << "#{Formula.factory(formula).opt_prefix}/lib"
    end

    # Add in generic Homebrew and system paths
    rpaths << "#{HOMEBREW_PREFIX}/lib"

    # Only add this in if we're < 10.8, because after that libxstub makes our lives miserable
    if MacOS.version < :mountain_lion
      rpaths << "/usr/X11/lib"
    end

    # Add those rpaths to the binaries
    rpaths.each do |rpath|
      Dir["#{bin}/julia-*"].each do |file|
        quiet_system "install_name_tool", "-add_rpath", rpath, file
      end
    end

    # copy over suite-sparse shlibs manually, pending discussion in https://github.com/JuliaLang/julia/commit/077c63a7164e270970de16863c7575c808a0c756#commitcomment-4128441
    ["spqr", "umfpack", "colamd", "cholmod", "amd", "suitesparse_wrapper"].each do |f|
      (lib + 'julia/').install "usr/lib/lib#{f}.dylib"
    end
  end

  def test
    # Run julia-provided test suite, copied over in install step
    if not (share + 'julia/test').exist?
      err = "Could not find test files directory\n"
      if build.head?
        err << "Did you accidentally include --HEAD in the test invocation?"
      else
        err << "Did you mean to include --HEAD in the test invocation?"
      end
      opoo err
    else
      chdir "#{share}/julia/test"
      system "#{bin}/julia", "runtests.jl", "all"
    end
  end
  
  def caveats
    head_flag = build.head? ? " --HEAD " : " "
    <<-EOS.undent
    Documentation and Examples have been installed into:
    #{share}/julia
    
    Test suite has been installed into:
    #{share}/julia/test
     
    Run the command `brew test#{head_flag}-v julia` to run all tests.
    EOS
  end
end
