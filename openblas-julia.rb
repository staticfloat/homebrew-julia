require 'formula'

class OpenblasJulia < Formula
  homepage 'http://xianyi.github.com/OpenBLAS/'
  url 'http://github.com/xianyi/OpenBLAS/archive/v0.2.12.tar.gz'
  head "https://github.com/xianyi/OpenBLAS.git", :branch => "develop"
  sha1 '2bdedca65e29186d1ecaaed45cb6c9b1f3f1c868'
  revision 1

  bottle do
    revision 2
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
    sha256 "0078f9e4263b31ee90a9397890eddee3bbd25e438fb142abc1fb646a6ae81ef2" => :mavericks
    sha256 "e54b900019bce9fc095af9b1c124191dd0e2165220a2db5c53256eb75617b833" => :yosemite
    sha256 "62c8930f090f9fe75e0c16f65b3896ad113ea3687c8399858139225362c0415b" => :mountain_lion
  end

  depends_on :fortran

  keg_only 'Conflicts with openblas in homebrew-science.'

  option "target", "Manually override the CPU type detection and provide your own TARGET make variable (ignored when building a bottle in lieu of DYNAMIC_ARCH)"

  def install
    # Build up our list of build options
    buildopts = []
    if build.bottle?
      buildopts << "DYNAMIC_ARCH=1"
    else
      # Ignore --target if building a bottle
      if ARGV.value('target')
        buildopts << "TARGET=#{ARGV.value('target')}"
      end
    end

    system "make", "FC=#{ENV['FC']}", *buildopts
    system "make", "PREFIX=#{prefix}", "install"
  end
end
