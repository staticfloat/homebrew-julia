require 'formula'

class Isl011Julia < Formula
  homepage 'http://freecode.com/projects/isl'
  # Track gcc infrastructure releases.
  url 'http://isl.gforge.inria.fr/isl-0.11.2.tar.bz2'
  mirror 'ftp://gcc.gnu.org/pub/gcc/infrastructure/isl-0.11.2.tar.bz2'

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
  end

  keg_only 'Conflicts with isl in main repository.'

  depends_on 'staticfloat/julia/gmp4-julia'

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--with-gmp=system",
                          "--with-gmp-prefix=#{Formula["gmp4-julia"].opt_prefix}"
    system "make install"
    (share/"gdb/auto-load").install Dir["#{lib}/*-gdb.py"]
  end
end
