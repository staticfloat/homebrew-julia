require 'formula'

class Openblas64Julia < Formula
  homepage 'http://xianyi.github.com/OpenBLAS/'
  # Maintainers, remember to update the LAPACK url in OpenblasLapack above.
  # See the "LAPACK_URL" in the openblas Makefile for the right version.
  url 'http://github.com/xianyi/OpenBLAS/archive/v0.2.8.tar.gz'
  sha1 'd012ebc2b8dcd3e95f667dff08318a81479a47c3'
  head "https://github.com/xianyi/OpenBLAS.git", :branch => "develop"

  depends_on :fortran

  # OS X provides the Accelerate.framework, which is a BLAS/LAPACK impl.
  keg_only :provided_by_osx

  option "target=", "Manually override the CPU type detection and provide your own TARGET make variable"

  def install
    # Must call in two steps
    if ARGV.value('target')
      system "make", "FC=#{ENV['FC']}", "INTERFACE64=1", "TARGET=#{ARGV.value('target')}"
    else
      system "make", "FC=#{ENV['FC']}", "INTERFACE64=1"
    end
    system "make", "PREFIX=#{prefix}", "install"
  end
end
