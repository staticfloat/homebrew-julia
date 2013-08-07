require 'formula'

class OpenblasJulia < Formula
  homepage 'http://xianyi.github.com/OpenBLAS/'
  # Maintainers, remember to update the LAPACK url in OpenblasLapack above.
  # See the "LAPACK_URL" in the openblas Makefile for the right version.
  url 'http://github.com/xianyi/OpenBLAS/archive/v0.2.8.tar.gz'
  sha1 'd012ebc2b8dcd3e95f667dff08318a81479a47c3'
  head "https://github.com/xianyi/OpenBLAS.git", :branch => "develop"

  # OS X provides the Accelerate.framework, which is a BLAS/LAPACK impl.
  keg_only :provided_by_osx

  def install
    ENV.fortran

    # Must call in two steps
    system "make", "FC=#{ENV['FC']}"
    system "make", "PREFIX=#{prefix}", "install"
  end
end
