require 'formula'

class OpenblasJulia < Formula
  homepage 'http://xianyi.github.com/OpenBLAS/'
  url 'http://github.com/xianyi/OpenBLAS/archive/v0.2.10.tar.gz'
  sha1 'c4a5ca4cb9876a90193f81a0c38f4abccdf2944d'
  head "https://github.com/xianyi/OpenBLAS.git", :branch => "develop"

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
    sha1 '50ba32be785ad9f9e620181bcae33eaa54cf087b' => :lion
    sha1 '4dd642d93206c6a219fe99fff5600449a3e6bdaa' => :mavericks
    sha1 '6f9673f7241f7e3fa0f1b84d93ac89f0781035a7' => :mountain_lion
  end


  depends_on :fortran

  keg_only 'Conflicts with openblas in homebrew-science.'

  option "target", "Manually override the CPU type detection and provide your own TARGET make variable"

  def install
    # Must call in two steps
    if ARGV.value('target')
      system "make", "FC=#{ENV['FC']}", "TARGET=#{ARGV.value('target')}"
    else
      system "make", "FC=#{ENV['FC']}"
    end

    system "make", "PREFIX=#{prefix}", "install"
    cd "#{lib}" do
      dylib = Dir.glob("libopenblas_*.dylib")[0]

      # Explicitly add libopenblas.dylib
      system "ln", "-sf", dylib, "libopenblas.dylib"
      system "strip", "-S", "libopenblas.dylib"
    end
  end
end
