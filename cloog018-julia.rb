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
    sha1 '0c74b6580e3b847d4a888ac859449b6d3d96a237' => :lion
    sha1 '322bc2ae77615149ea6cb56cf9e66fa8add96f72' => :mavericks
    sha1 '58c41f54c5121ad606ef83e02aab69e242d8d12c' => :mountain_lion
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
      "--with-gmp-prefix=#{Formula["gmp4"].opt_prefix}",
      "--with-isl-prefix=#{Formula["isl011"].opt_prefix}"
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
