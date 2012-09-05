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
  depends_on "zlib"
  
  # We have our custom version of arpack-ng, pending acceptance into either homebrew-science or homebrew-main
  depends_on "staticfloat/julia/arpack-ng"

  # Temporarily use pull request for suite-sparse 4.0.2
  depends_on "https://raw.github.com/staticfloat/homebrew/652835f810439ffdde237a1818af58140421acd1/Library/Formula/suite-sparse.rb"
  # Right now, use @samueljohn's openblas formula, until it gets merged into homebrew/science.
  depends_on "staticfloat/julia/openblas"
  
  # Soon we will remove lighttpd in favor of nginx
  depends_on "lighttpd"
  depends_on "nginx"
  
  # Fixes strip issues, thanks to @nolta
  skip_clean 'bin'

  def patches
    # Uses install_name_tool to add in ${HOMEBREW_PREFIX}/lib to the rpath of julia,
    # and fixes hardcoded include path for glpk.h
    DATA
  end

  def install
    ENV.fortran
    ENV.deparallelize if build.has_option? "d"

    # Hack to allow julia to get the git version on demand
    ENV['GIT_DIR'] = cached_download/'.git'
    
    # Have to include CPPFLAGS in CFLAGS and CXXFLAGS because Julia's buildsystem doesn't listen to CPPFLAGS
    if not ENV['CPPFLAGS'] or not ENV['CFLAGS'] or not ENV['CXXFLAGS']
      raise "Must include --env=std option, e.g. `brew install --HEAD --env=std julia`"
    end
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
    ['ZLIB', 'FFTW', 'READLINE', 'GLPK', 'GMP', 'LLVM', 'PCRE', 'LIGHTTPD', 'LAPACK', 'BLAS', 'SUITESPARSE', 'ARPACK', 'NGINX'].each do |dep|
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

    # call make with the build options
    system "make", *build_opts

    # Remove the fftw symlinks again, so we don't have conflicts when installing julia
    ['', 'f', '_threads', 'f_threads'].each do |ext|
      rm "usr/lib/libfftw3#{ext}.dylib"
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

__END__
diff --git a/Makefile b/Makefile
index 140a144..d67ab6a 100644
--- a/Makefile
+++ b/Makefile
@@ -39,9 +39,9 @@ install: release
 	mkdir -p $(PREFIX)/{sbin,bin,etc,lib/julia,share/julia}
 	cp $(BUILD)/bin/*julia* $(PREFIX)/bin
 ifeq ($(OS), Darwin)
-	install_name_tool -rpath $(BUILD)/lib $(PREFIX)/lib $(PREFIX)/bin/julia-release-basic
-	install_name_tool -rpath $(BUILD)/lib $(PREFIX)/lib $(PREFIX)/bin/julia-release-readline
-	install_name_tool -add_rpath $(PREFIX)/lib $(PREFIX)/bin/julia-release-webserver
+	install_name_tool -rpath $(BUILD)/lib HOMEBREW_PREFIX/lib $(PREFIX)/bin/julia-release-basic
+	install_name_tool -rpath $(BUILD)/lib HOMEBREW_PREFIX/lib $(PREFIX)/bin/julia-release-readline
+	install_name_tool -add_rpath HOMEBREW_PREFIX/lib $(PREFIX)/bin/julia-release-webserver
 endif
 	cd $(PREFIX)/bin && ln -s julia-release-$(DEFAULT_REPL) julia
 	cp -R -L $(BUILD)/lib/julia/* $(PREFIX)/lib/julia
diff --git a/extras/Makefile b/extras/Makefile
index 0c4a0fd..d6edb9f 100644
--- a/extras/Makefile
+++ b/extras/Makefile
@@ -8,7 +8,7 @@ GLPK_VER = 4.47
 GLPK_CONST = 0x[0-9a-fA-F]+|[-+]?\s*[0-9]+
 
 ifeq ($(USE_SYSTEM_GLPK), 1)
-GLPK_PREFIX = /usr/include
+GLPK_PREFIX = HOMEBREW_PREFIX/include
 else
 GLPK_PREFIX = $(JULIAHOME)/deps/glpk-$(GLPK_VER)/src
 endif
diff --git a/deps/Makefile b/deps/Makefile
index 64d01bb..a7ffdc9 100644
--- a/deps/Makefile
+++ b/deps/Makefile
@@ -654,7 +654,7 @@ distclean-suitesparse: clean-suitesparse
 # SUITESPARSE WRAPPER
 
 ifeq ($(USE_SYSTEM_SUITESPARSE), 1)
-SUITESPARSE_INC = -I /usr/include/suitesparse
+SUITESPARSE_INC = -I HOMEBREW_PREFIX/include
 SUITESPARSE_LIB = -lumfpack -lcholmod -lamd -lcamd -lcolamd
 else
 SUITESPARSE_INC = -I SuiteSparse-$(SUITESPARSE_VER)/CHOLMOD/Include -I SuiteSparse-$(SUITESPARSE_VER)/
@@ -847,7 +847,7 @@ distclean-glpk: clean-glpk
 ## GLPK Wrapper
 
 ifeq ($(USE_SYSTEM_GLPK), 1)
-GLPKW_INC = -I /usr/include/
+GLPKW_INC = -I HOMEBREW_PREFIX/include/
 GLPKW_LIB = -lglpk
 else
 GLPKW_INC = -I $(abspath $(USR))/include/
diff --git a/Make.inc b/Make.inc
index 5007938..146d0bd 100644
--- a/Make.inc
+++ b/Make.inc
@@ -147,7 +147,7 @@ endif
 
 ifeq ($(USE_SYSTEM_BLAS), 1)
 ifeq ($(OS), Darwin)
-LIBBLAS = -framework vecLib -lBLAS
+LIBBLAS = -lopenblas
 LIBBLASNAME = libblas
 else
 LIBBLAS = -lblas
