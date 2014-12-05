require 'formula'

class OpenblasJulia < Formula
  homepage 'http://xianyi.github.com/OpenBLAS/'
  url 'http://github.com/xianyi/OpenBLAS/archive/v0.2.12.tar.gz'
  head "https://github.com/xianyi/OpenBLAS.git", :branch => "develop"
  sha1 '2bdedca65e29186d1ecaaed45cb6c9b1f3f1c868'

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
    revision 2
    sha1 "adf133d8f7734366004387d75f38d0f0819ee0d1" => :mountain_lion
    sha1 "eab5bb9497a2d515555e949f15dbf0f69c7de9f1" => :mavericks
    sha1 "e0d249b4cc21f8a6f31c898ffa1aeeb7eb4870e0" => :yosemite
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
