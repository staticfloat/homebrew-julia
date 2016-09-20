require 'formula'

class OpenblasJulia < Formula
  homepage 'http://xianyi.github.com/OpenBLAS/'
  url 'http://github.com/xianyi/OpenBLAS/archive/v0.2.19.tar.gz'
  head 'https://github.com/xianyi/OpenBLAS.git', :branch => 'develop'
  sha256 '9c40b5e4970f27c5f6911cb0a28aa26b6c83f17418b69f8e5a116bb983ca8557'

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
    sha256 "bacadc04c86395457632374877ec9f2cb5f189c311adc56a076b132d027200f8" => :mavericks
    sha256 "c17d10efb51679f320ab52ce2300cca2dc027cb3405c5c6426608097070099e4" => :yosemite
    sha256 "0df26a818ad0bdd19eec1a8f038776f26362e60bc6e75baac15158294c702ae9" => :el_capitan
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
