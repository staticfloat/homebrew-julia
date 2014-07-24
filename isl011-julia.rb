require 'formula'

class Isl011Julia < Formula
  homepage 'http://freecode.com/projects/isl'
  # Track gcc infrastructure releases.
  url 'http://isl.gforge.inria.fr/isl-0.11.1.tar.bz2'
  mirror 'ftp://gcc.gnu.org/pub/gcc/infrastructure/isl-0.11.1.tar.bz2'
  sha1 'd7936929c3937e03f09b64c3c54e49422fa8ddb3'

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
    sha1 'c739e018126b7e5674bdbd1e1c19f2d6abd4b4ff' => :lion
    sha1 'fc962814b005bdea1945f72fef405fb53e88984e' => :mavericks
    sha1 '402a78ecb734c30508dbe3733135547542520e4d' => :mountain_lion
  end

  keg_only 'Conflicts with isl in main repository.'

  depends_on 'staticfloat/julia/gmp4-julia'

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--with-gmp=system",
                          "--with-gmp-prefix=#{Formula["gmp4"].opt_prefix}"
    system "make install"
    (share/"gdb/auto-load").install Dir["#{lib}/*-gdb.py"]
  end
end
