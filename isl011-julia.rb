require 'formula'

class Isl011Julia < Formula
  homepage 'http://freecode.com/projects/isl'
  # Track gcc infrastructure releases.
  url 'http://isl.gforge.inria.fr/isl-0.11.2.tar.bz2'
  mirror 'ftp://gcc.gnu.org/pub/gcc/infrastructure/isl-0.11.2.tar.bz2'

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
    sha256 "2e2b07b71313947f60f20711962b0eb7c3385d443b253138137aa6a0b7f7bdfb" => :mavericks
    sha256 "bf0d4c6fdd3797dcb543d2cb42061c8dd2658402b8a623b5018737a86e5522b4" => :yosemite
    sha256 "e9eee9fe806f38bee7648b59d73610500fe27cac6625b4ad7396c2eca5781705" => :el_capitan
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
