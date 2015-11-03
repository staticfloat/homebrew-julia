require 'formula'

class Cloog018Julia < Formula
  homepage 'http://www.cloog.org/'
  # Track gcc infrastructure releases.
  url 'http://www.bastoul.net/cloog/pages/download/count.php3?url=./cloog-0.18.1.tar.gz'
  mirror 'ftp://gcc.gnu.org/pub/gcc/infrastructure/cloog-0.18.1.tar.gz'
  sha256 '02500a4edd14875f94fe84cbeda4290425cb0c1c2474c6f75d75a303d64b4196'

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
    sha256 "a1e3c84d1ae82a1e49ae2443972d228de3cfbaef826f0803d2932caff09b4c11" => :mavericks
    sha256 "1492ba002895f52ab8eb76b23cf722245b47b95ea201611789ae708a7eff084f" => :yosemite
    sha256 "9f1b9c1b7cae97e88179b19c29e2d49b970ae9f5e8111235f89ecbd5e1811f0c" => :el_capitan
  end

  keg_only 'Conflicts with cloog in main repository.'

  depends_on 'pkg-config' => :build
  depends_on 'staticfloat/julia/gmp4-julia'
  depends_on 'staticfloat/julia/isl011-julia'

  def install
    args = [
      "--prefix=#{prefix}",
      "--disable-dependency-tracking",
      "--disable-silent-rules",
      "--with-gmp-prefix=#{Formula["gmp4-julia"].opt_prefix}",
      "--with-isl-prefix=#{Formula["isl011-julia"].opt_prefix}"
    ]

    system "./configure", *args
    system "make install"
  end

  test do
    cloog_source = <<-EOS.undent
      c

      0 2
      0

      1

      1
      0 2
      0 0 0
      0

      0
    EOS

    require 'open3'
    Open3.popen3("#{bin}/cloog", "/dev/stdin") do |stdin, stdout, _|
      stdin.write(cloog_source)
      stdin.close
      assert_match /Generated from \/dev\/stdin by CLooG/, stdout.read
    end
  end
end
