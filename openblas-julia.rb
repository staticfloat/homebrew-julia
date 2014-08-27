require 'formula'

class OpenblasJulia < Formula
  homepage 'http://xianyi.github.com/OpenBLAS/'
  url 'http://github.com/xianyi/OpenBLAS/archive/v0.2.10.tar.gz'
  sha1 'c4a5ca4cb9876a90193f81a0c38f4abccdf2944d'
  head "https://github.com/xianyi/OpenBLAS.git", :branch => "develop"

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
    revision 2
    sha1 '62a0a65e7835f5e63dd901cfbab2247199ad910d' => :lion
    sha1 'ea1e94d03476ecb182d0dcbbb21e046a73cf249d' => :mavericks
    sha1 'e458ee0415396beb66b1a861ab9d8c4d832cc6cd' => :mountain_lion
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
