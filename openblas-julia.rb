require 'formula'

class OpenblasJulia < Formula
  homepage 'http://xianyi.github.com/OpenBLAS/'
  url 'http://github.com/xianyi/OpenBLAS/archive/v0.2.12.tar.gz'
  head "https://github.com/xianyi/OpenBLAS.git", :branch => "develop"
  sha1 '2bdedca65e29186d1ecaaed45cb6c9b1f3f1c868'

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
    revision 1
    sha1 '820d7a691df2aa3ba569aa5456d7b116b7627916' => :mavericks
    sha1 '2a82f3fa4cc97d8a5dce5d2413ffc1b03533813a' => :mountain_lion
    sha1 "1b5d2f66a979fd442d202eea754d623ee7bf6682" => :yosemite
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
