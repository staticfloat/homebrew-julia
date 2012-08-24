require 'formula'

class Openblas < Formula
  homepage 'http://xianyi.github.com/OpenBLAS/'
  url 'http://github.com/xianyi/OpenBLAS/zipball/v0.2.3'
  sha1 '388094941b39e702b75768b0a94da49b77d474c0'
  head "https://github.com/xianyi/OpenBLAS.git"

  keg_only :provided_by_osx

  def install
    ENV.fortran

    # Must call in two steps
    system "make", "CC=#{ENV.cc} #{ENV.cflags}", "FC=#{ENV['FC']}"
    system "make", "PREFIX=#{prefix}", "install"
  end
end
