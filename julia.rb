require 'formula'

class Julia < Formula
  homepage 'http://julialang.org'
  head 'https://github.com/JuliaLang/julia.git'

  depends_on "readline"
  depends_on "pcre"
  depends_on "gmp"
  depends_on "llvm"
  depends_on "glpk"
  depends_on "staticfloat/julia/arpack-ng"

  # Temporarily use pull request for suite-sparse 4.0.2
  depends_on "https://raw.github.com/staticfloat/homebrew/652835f810439ffdde237a1818af58140421acd1/Library/Formula/suite-sparse.rb"
  depends_on "lighttpd"
  depends_on "fftw"
  depends_on "tbb"
  depends_on "metis"
  # Not yet, but soon, julia will need openblas. We will know this when
  # the patch of the Makefile breakes, because right now it links against the
  # accelerate framework on Darwin.
  #depends_on "openblas"

  # Fixes strip issues, thanks to @nolta
  skip_clean 'bin'

  def patches
    # Uses install_name_tool to add in ${HOMEBREW_PREFIX}/lib to the rpath of julia,
    # and fixes hardcoded include path for glpk.h
    DATA
  end

  def install
    ENV.fortran

    # Hack to allow julia to get the git version on demand
    ENV['GIT_DIR'] = cached_download/'.git'

    # This from @ijt's formula, with possible exclusion if @sharpie makes standard for ENV.fortran builds
    libgfortran = `$FC --print-file-name libgfortran.a`.chomp
    ENV.append "LDFLAGS", "-L#{File.dirname libgfortran}"

    # Build up list of build options
    build_opts = ["PREFIX=#{prefix}"]

    # Tell julia about our gfortran
    # (this enables to use gfortran-4.7 from the tap homebrew-dupes/gcc.rb)
    build_opts << "FC=#{ENV['FC']}"

    # Make sure Julia uses clang if the environment supports it
    build_opts << "USECLANG=1" if ENV.compiler == :clang

    # Kudos to @ijt for these lines of code
    ['FFTW', 'READLINE', 'GLPK', 'GMP', 'LLVM', 'PCRE', 'LIGHTTPD', 'LAPACK', 'BLAS', 'SUITESPARSE', 'ARPACK', 'NGINX'].each do |dep|
      build_opts << "USE_SYSTEM_#{dep}=1"
    end

    # call makefile to grab suitesparse libraries
    system "make", "-C", "contrib", "-f", "repackage_system_suitesparse4.make", *build_opts

    # call make with the build options
    system "make", *build_opts

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
