require 'formula'

class OpenblasJulia < Formula
  homepage 'http://xianyi.github.com/OpenBLAS/'
  url 'http://github.com/xianyi/OpenBLAS/archive/v0.2.17.tar.gz'
  head 'https://github.com/xianyi/OpenBLAS.git', :branch => 'develop'
  sha256 '0fe836dfee219ff4cadcc3567fb2223d9e0da5f60c7382711fb9e2c35ecf0dbf'

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    sha256 "9688e22d55459194ff52c5d1a7638996d309f9611349a3dbcb56523dc50dcc1b" => :mavericks
    sha256 "6ec4f344c233e9a068190d9463751da280456b8813d6fd0bad10765f3baa3c2e" => :yosemite
    sha256 "20b584e87be5fef72f3c6e113f26be9094af4dcfd1cef7e0e7d8d7215e9c553a" => :el_capitan
    cellar :any
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
