require 'formula'

class OpenblasJulia < Formula
  homepage 'http://xianyi.github.com/OpenBLAS/'
  url 'http://github.com/xianyi/OpenBLAS/archive/v0.2.12.tar.gz'
  head "https://github.com/xianyi/OpenBLAS.git", :branch => "develop"
  sha1 '2bdedca65e29186d1ecaaed45cb6c9b1f3f1c868'

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
