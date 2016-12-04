require 'formula'

class OpenblasJulia < Formula
  homepage 'http://xianyi.github.com/OpenBLAS/'
  url 'http://github.com/xianyi/OpenBLAS/archive/v0.2.19.tar.gz'
  head 'https://github.com/xianyi/OpenBLAS.git', :branch => 'develop'
  sha256 '9c40b5e4970f27c5f6911cb0a28aa26b6c83f17418b69f8e5a116bb983ca8557'

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
    rebuild 1
    sha256 "8660959f1b5c4907b26ad719f22a6946983e6845109a056c5c6cc15d4e96785e" => :mavericks
    sha256 "eac5cd4f0bd509f58faca8006910ab0daa302cafcc72813a306b634d23f52539" => :el_capitan
    sha256 "607948b2c706b9e4d4926f2a5a90b69bf25edbe8078b26905d12730a87a81bce" => :yosemite
    sha256 "3c0bd462ac422352318462bcb679f4d465a399f62815fecad5f152a8648fe99c" => :sierra
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
