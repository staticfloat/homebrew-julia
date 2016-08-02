require 'formula'

class Gmp4Julia < Formula
  homepage 'http://gmplib.org/'
  # Track gcc infrastructure releases.
  url 'ftp://ftp.gmplib.org/pub/gmp-4.3.2/gmp-4.3.2.tar.bz2'
  mirror 'ftp://gcc.gnu.org/pub/gcc/infrastructure/gmp-4.3.2.tar.bz2'
  mirror 'http://mirrors.kernel.org/gnu/gmp/gmp-4.3.2.tar.bz2'
  sha256 '936162c0312886c21581002b79932829aa048cfaf9937c6265aeaa14f1cd1775'

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
    revision 1
    sha256 'afb3e45728caf001c23f61001b9ef99032c1cba6cf4282fe425e14e35ce7660a' => :mavericks
    sha256 'ba0e659992293be8f28eb4b5c6f865ed8befb5f8be1b6ec3836fb79069e74dee' => :yosemite
    sha256 "bc28d363ecd584f878cf47f308cafb4bbfb491de64a1089f7e572846975c7493" => :el_capitan
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
