require 'formula'

class OpenblasJulia < Formula
  homepage 'http://xianyi.github.com/OpenBLAS/'
  url 'http://github.com/xianyi/OpenBLAS/archive/v0.2.18.tar.gz'
  head 'https://github.com/xianyi/OpenBLAS.git', :branch => 'develop'
  sha256 '7d9f8d4ea4a65ab68088f3bb557f03a7ac9cb5036ef2ba30546c3a28774a4112'

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
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
