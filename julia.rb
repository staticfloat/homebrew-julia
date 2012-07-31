require 'formula'

class Julia < Formula
  homepage 'http://julialang.org'
  head 'https://github.com/JuliaLang/julia.git'
  #head 'https://github.com/staticfloat/julia.git'

  depends_on "gfortran"
  depends_on "readline"
  depends_on "pcre"
  depends_on "gmp"
  depends_on "llvm"
  depends_on "glpk"
  depends_on "staticfloat/julia/arpack-ng"
  depends_on "staticfloat/julia/suite-sparse"
  depends_on "lighttpd"
  depends_on "fftw"
  depends_on "tbb"
  depends_on "metis"

  # Fixes strip issues, thanks to @nolta
  skip_clean 'bin'

  def patches
    # Uses install_name_tool to add in ${HOMEBREW_PREFIX}/lib to the rpath of julia
    DATA
  end

  def install
    ENV.fortran
    ENV.deparallelize

    # Julia ignores CPPFLAGS and only uses CFLAGS, so we must store CPPFLAGS into CFLAGS
    ENV.append_to_cflags ENV['CPPFLAGS']

    # Hack to allow julia to get the git version on demand
    ENV['GIT_DIR'] = cached_download/'.git'

    # This from @ijt's formula, with possible exclusion if @sharpie makes standard for ENV.fortran builds
    libgfortran = `$FC --print-file-name libgfortran.a`.chomp
    ENV.append "LDFLAGS", "-L#{File.dirname libgfortran}"

    # Build up list of build options
    build_opts = ["PREFIX=#{prefix}"]

    # Make sure Julia uses clang if the environment supports it
    build_opts << "USECLANG=1" if ENV.compiler == :clang

    # Kudos to @ijt for these lines of code
    ['READLINE', 'GLPK', 'GMP', 'LLVM', 'PCRE', 'LIGHTTPD', 'FFTW', 'LAPACK', 'BLAS', 'SUITESPARSE', 'ARPACK'].each do |dep|
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
    cp_r "test", "#{lib}/julia/"
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
+	install_name_tool -rpath $(BUILD)/lib $(HOMEBREW_PREFIX)/lib $(PREFIX)/bin/julia-release-basic
+	install_name_tool -rpath $(BUILD)/lib $(HOMEBREW_PREFIX)/lib $(PREFIX)/bin/julia-release-readline
+	install_name_tool -add_rpath $(HOMEBREW_PREFIX)/lib $(PREFIX)/bin/julia-release-webserver
 endif
 	cd $(PREFIX)/bin && ln -s julia-release-$(DEFAULT_REPL) julia
 	cp -R -L $(BUILD)/lib/julia/* $(PREFIX)/lib/julia
