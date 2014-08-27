require 'formula'

class OpenblasJulia < Formula
  homepage 'http://xianyi.github.com/OpenBLAS/'
  url 'http://github.com/xianyi/OpenBLAS/archive/v0.2.10.tar.gz'
  sha1 'c4a5ca4cb9876a90193f81a0c38f4abccdf2944d'
  head "https://github.com/xianyi/OpenBLAS.git", :branch => "develop"

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
    revision 1
    sha1 'c872ddac786e9486525fbc07d2e6d17c9aca476c' => :lion
    sha1 'e34e0a6d92a9dfeba9466d7cb3fd4237c200992f' => :mavericks
    sha1 'f6f4d767468230d8a50f7356090c0c4def25d7e2' => :mountain_lion
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
