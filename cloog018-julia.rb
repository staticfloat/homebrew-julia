require 'formula'

class Cloog018Julia < Formula
  homepage 'http://www.cloog.org/'
  # Track gcc infrastructure releases.
  url 'http://www.bastoul.net/cloog/pages/download/count.php3?url=./cloog-0.18.0.tar.gz'
  mirror 'ftp://gcc.gnu.org/pub/gcc/infrastructure/cloog-0.18.0.tar.gz'
  sha1 '85f620a26aabf6a934c44ca40a9799af0952f863'

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
    revision 1
    sha1 'ef93a3f89ec912781315fa206e2731dc2d65bae6' => :lion
    sha1 'e2ee2363aa35d3e02e47b0f81a727dde031fac32' => :mavericks
    sha1 '243b762581c65cb9414f9e7ac7d284d78301bcc2' => :mountain_lion
    sha1 "fab85e4b7244f9ed7c92b0cbbde53cd75c99bfd0" => :yosemite
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
