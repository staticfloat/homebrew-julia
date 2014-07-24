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
    revision 1
    sha1 '9887c5b8388ffa65dbd12ed2d1e3cc4936225544' => :lion
    sha1 'd6b2f3f0e616e945791506ead488d640bfc2927a' => :mavericks
    sha1 '50a608cf43e181a99a1ed1c39b8b978314698d87' => :mountain_lion
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
