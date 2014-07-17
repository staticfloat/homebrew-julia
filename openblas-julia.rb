require 'formula'

class OpenblasJulia < Formula
  homepage 'http://xianyi.github.com/OpenBLAS/'
  # Maintainers, remember to update the LAPACK url in OpenblasLapack above.
  # See the "LAPACK_URL" in the openblas Makefile for the right version.
  url 'http://github.com/xianyi/OpenBLAS/archive/v0.2.10.tar.gz'
  sha1 'bcc55e335792874b00a9f3460e7e9778ded3b848'
  head "https://github.com/xianyi/OpenBLAS.git", :branch => "develop"

  depends_on :fortran

  # OS X provides the Accelerate.framework, which is a BLAS/LAPACK impl.
  keg_only :provided_by_osx

  option "target=", "Manually override the CPU type detection and provide your own TARGET make variable"

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
      system "ln", "-sf", dylib, "libopenblas.dylib"
      system "strip", "-S", "libopenblas.dylib"
    end
  end
end
