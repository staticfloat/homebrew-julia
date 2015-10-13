require 'formula'

class Gmp4Julia < Formula
  homepage 'http://gmplib.org/'
  # Track gcc infrastructure releases.
  url 'ftp://ftp.gmplib.org/pub/gmp-4.3.2/gmp-4.3.2.tar.bz2'
  mirror 'ftp://gcc.gnu.org/pub/gcc/infrastructure/gmp-4.3.2.tar.bz2'
  mirror 'http://mirrors.kernel.org/gnu/gmp/gmp-4.3.2.tar.bz2'
  sha1 'c011e8feaf1bb89158bd55eaabd7ef8fdd101a2c'

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
    revision 1
    sha1 '627289818d185c949a1313fbd52c5472631e75d6' => :lion
    sha1 '46f5b391f57012301da0ecab317989fb52ad31c4' => :mavericks
    sha1 '7d389346de35a8fd729d09d23a2e944df11f18cb' => :mountain_lion
    sha1 '92352c7657d48b844dabb0fdea91a49ce7f0b46f' => :yosemite
  end

  keg_only "Conflicts with gmp in main repository."

  option '32-bit'
  option 'skip-check', 'Do not run `make check` to verify libraries'

  fails_with :gcc_4_0 do
    cause "Reports of problems using gcc 4.0 on Leopard: https://github.com/mxcl/homebrew/issues/issue/2302"
  end

  # Patches gmp.h to remove the __need_size_t define, which
  # was preventing libc++ builds from getting the ptrdiff_t type
  # Applied upstream in http://gmplib.org:8000/gmp/raw-rev/6cd3658f5621
  patch :DATA

  def install
    args = ["--prefix=#{prefix}", "--enable-cxx"]

    # Build 32-bit where appropriate, and help configure find 64-bit CPUs
    if MacOS.prefer_64_bit? and not build.build_32_bit?
      ENV.m64
      args << "--build=x86_64-apple-darwin"
    else
      ENV.m32
      args << "--host=none-apple-darwin"
    end

    system "./configure", *args
    system "make"
    ENV.j1 # Doesn't install in parallel on 8-core Mac Pro
    system "make install"

    # Different compilers and options can cause tests to fail even
    # if everything compiles, so yes, we want to do this step.
    system "make check" unless build.include? "skip-check"
  end
end

__END__
diff -r c7ed424a63b2 -r 6cd3658f5621 gmp-h.in
--- a/gmp-h.in	Tue Oct 08 14:01:35 2013 +0200
+++ b/gmp-h.in	Tue Oct 08 14:45:27 2013 +0200
@@ -46,13 +46,11 @@
 #ifndef __GNU_MP__
 #define __GNU_MP__ 5
 
-#define __need_size_t  /* tell gcc stddef.h we only want size_t */
 #if defined (__cplusplus)
 #include <cstddef>     /* for size_t */
 #else
 #include <stddef.h>    /* for size_t */
 #endif
-#undef __need_size_t
 
 /* Instantiated by configure. */
 #if ! defined (__GMP_WITHIN_CONFIGURE)
