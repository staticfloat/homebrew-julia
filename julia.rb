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
    DATA
  end


  def install
    ENV.fortran

    # Julia ignores CPPFLAGS and only uses CFLAGS, so we must store CPPFLAGS into CFLAGS
    ENV.append_to_cflags ENV['CPPFLAGS']

    ENV.remove 'LDFLAGS', "-I#{MacOS.sdk_path}/usr/include"

    # Hack to allow julia to get the git version on demand
    ENV['GIT_DIR'] = cached_download/'.git'

    # This from @ijt's formula, with possible exclusion if @sharpie makes standard for ENV.fortran builds
    libgfortran = `$FC --print-file-name libgfortran.a`.chomp
    ENV.append "LDFLAGS", "-L#{File.dirname libgfortran}"

    # symlink external dylibs into julia's usr/lib directory, so that it can load them at runtime
    mkdir_p "usr/lib"
    ['', 'f', 'l', '_threads', 'f_threads', 'l_threads'].each do |ext|
      ln_s "#{Formula.factory('fftw').lib}/libfftw3#{ext}.dylib", "usr/lib/"
    end

    ln_s "#{Formula.factory('staticfloat/julia/arpack-ng').lib}/libarpack.dylib", "usr/lib/"

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
    
    # symlink lighttpd binary into usr/sbin, so that launch-julia-webserver works properly
    mkdir_p "usr/sbin/"
    ln_s "#{Formula.factory('lighttpd').sbin}/lighttpd", "usr/sbin/"    

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
diff --git a/Make.inc b/Make.inc
index 8a13c2e..8adb50e 100644
--- a/Make.inc
+++ b/Make.inc
@@ -61,8 +61,8 @@ DEBUGFLAGS = -g -DDEBUG
 SHIPFLAGS = -O3 -DNDEBUG
 ifeq ($(OS), Darwin)
 # use $(sw_vers -productVersion) instead of 10.5?
-CC += -mmacosx-version-min=10.5
-CXX += -mmacosx-version-min=10.5
+CC += $(CFLAGS)
+CXX += $(CXXFLAGS)
 endif
 endif
 
diff --git a/base/Makefile b/base/Makefile
index 8d97532..3e09082 100644
--- a/base/Makefile
+++ b/base/Makefile
@@ -9,7 +9,7 @@ pcre_h.jl:
 	$(QUIET_PERL) ${CC} -E -dM $(shell $(PCRE_CONFIG) --prefix)/include/pcre.h | perl -nle '/^\s*#define\s+(PCRE\w*)\s*\(?($(PCRE_CONST))\)?\s*$$/ and print "const $$1 = int32($$2)"' | sort > $@
 
 errno_h.jl:
-	$(QUIET_PERL) echo '#include "errno.h"' | cpp -dM - | perl -nle 'print "const $$1 = int32($$2)" if /^#define\s+(E\w+)\s+(\d+)\s*$$/' | sort > $@
+	$(QUIET_PERL) echo '#include "errno.h"' | cpp -I$(SDKROOT)/usr/include -dM - | perl -nle 'print "const $$1 = int32($$2)" if /^#define\s+(E\w+)\s+(\d+)\s*$$/' | sort > $@
 
 os_detect.jl: ../src/os_detect.h
 	$(QUIET_PERL) ${CC} -E -P -DJULIA ../src/os_detect.h | perl -p -e 's/\\n/\n/g' > $@
diff --git a/deps/Makefile b/deps/Makefile
index e8ab8cd..2e8bb4f 100644
--- a/deps/Makefile
+++ b/deps/Makefile
@@ -631,7 +631,7 @@ distclean-suitesparse: clean-suitesparse
 # SUITESPARSE WRAPPER
 
 ifeq ($(USE_SYSTEM_SUITESPARSE), 1)
-SUITESPARSE_INC = -I /usr/include/suitesparse
+SUITESPARSE_INC = -I $(shell ${HOMEBREW_BREW_FILE} --prefix)/include/suitesparse
 SUITESPARSE_LIB = -lumfpack -lcholmod -lamd -lcamd -lcolamd
 else
 SUITESPARSE_INC = -I SuiteSparse-$(SUITESPARSE_VER)/CHOLMOD/Include -I SuiteSparse-$(SUITESPARSE_VER)/SuiteSparse_config -L$(USRLIB)
@@ -824,7 +824,7 @@ distclean-glpk: clean-glpk
 ## GLPK Wrapper
 
 ifeq ($(USE_SYSTEM_GLPK), 1)
-GLPKW_INC = -I /usr/include/
+GLPKW_INC = -I $(shell ${HOMEBREW_BREW_FILE} --prefix)/include/
 GLPKW_LIB = -lglpk
 else
 GLPKW_INC = -I $(abspath $(USR))/include/
@@ -833,6 +833,7 @@ endif
 
 
 $(USRLIB)/libglpk_wrapper.$(SHLIB_EXT): glpk_wrapper.c $(GLPK_OBJ_TARGET)
+	echo "doing the wrapping thing ..."
 	mkdir -p $(USRLIB)
 	$(CC) $(CFLAGS) $(LDFLAGS) -O2 -shared $(fPIC) $(GLPKW_INC) glpk_wrapper.c $(GLPKW_LIB) -o $(USRLIB)/libglpk_wrapper.$(SHLIB_EXT) -Wl,-rpath,$(USRLIB)
 	$(INSTALL_NAME_CMD)libglpk_wrapper.$(SHLIB_EXT) $@
diff --git a/deps/Rmath/src/Makefile b/deps/Rmath/src/Makefile
index a6f33dc..f1d1ab2 100644
--- a/deps/Rmath/src/Makefile
+++ b/deps/Rmath/src/Makefile
@@ -42,7 +42,7 @@ release debug: libRmath.$(SHLIB_EXT)
 
 libRmath.$(SHLIB_EXT): $(XOBJS)
 	rm -rf $@
-	$(QUIET_LINK) $(CC) -shared -o $@ $^ -L$(USRLIB) -lrandom $(RPATH_ORIGIN)
+	$(QUIET_LINK) $(CC) $(LDFLAGS) -shared -o $@ $^ -L$(USRLIB) -lrandom $(RPATH_ORIGIN)
 
 clean:
 	rm -f *.o *.do *.a *.$(SHLIB_EXT) core* *~ *#
diff --git a/extras/Makefile b/extras/Makefile
index 0c4a0fd..5aea51d 100644
--- a/extras/Makefile
+++ b/extras/Makefile
@@ -8,7 +8,7 @@ GLPK_VER = 4.47
 GLPK_CONST = 0x[0-9a-fA-F]+|[-+]?\s*[0-9]+
 
 ifeq ($(USE_SYSTEM_GLPK), 1)
-GLPK_PREFIX = /usr/include
+GLPK_PREFIX = $(shell ${HOMEBREW_BREW_FILE} --prefix)/include
 else
 GLPK_PREFIX = $(JULIAHOME)/deps/glpk-$(GLPK_VER)/src
 endif
@@ -17,7 +17,7 @@ glpk_h.jl:
 	$(QUIET_PERL) cpp -dM $(GLPK_PREFIX)/glpk.h | perl -nle '/^\s*#define\s+(GLP\w*)\s*\(?($(GLPK_CONST))\)?\s*$$/ and print "const $$1 = int32($$2)"' | sort > $@
 
 julia_message_types_h.jl: ../ui/webserver/message_types.h
-	$(QUIET_PERL) cpp -Dnotdefined $^ > $@
+	$(QUIET_PERL) cpp -I$(SDKROOT)/usr/include -Dnotdefined $^ > $@
 
 clean:
 	rm -f glpk_h.jl julia_message_types_h.jl
