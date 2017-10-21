require 'formula'

class OpenblasJulia < Formula
  homepage 'http://xianyi.github.com/OpenBLAS/'
  url 'http://github.com/xianyi/OpenBLAS/archive/v0.2.20.tar.gz'
  head 'https://github.com/xianyi/OpenBLAS.git', :branch => 'develop'
  sha256 '5ef38b15d9c652985774869efd548b8e3e972e1e99475c673b25537ed7bcf394'

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
    sha256 'b5ce47feaed363e89751a14d5bb0d5e53fa4edf670b9eb5cdbe491b78ab5d168' => :el_capitan
    sha256 'ee7ac2970c35b32558ac80faf43e64aa54920407e5c3b2ce65daa6a799a6011d' => :sierra
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
