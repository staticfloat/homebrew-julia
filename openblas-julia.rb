require 'formula'

class OpenblasJulia < Formula
  homepage 'http://xianyi.github.com/OpenBLAS/'
  url 'http://github.com/xianyi/OpenBLAS/archive/v0.2.15.tar.gz'
  head 'https://github.com/xianyi/OpenBLAS.git', :branch => 'develop'
  sha256 '73c40ace5978282224e5e122a41c8388c5a19e65a6f2329c2b7c0b61bacc9044'

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
    sha256 "176e31c0a13828894e4d89a6042fe3ee744e37fd0a5dcae0d402b93c9453285e" => :mavericks
    sha256 "354049a1b6fd648bbf4519589332d52ccaeea09defd04f5f9120e9c5c29c32a0" => :yosemite
    sha256 "984e402500b3297195fcbbd583b52aa768065dd8b5e6243e489e72c74f89ef27" => :el_capitan
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
