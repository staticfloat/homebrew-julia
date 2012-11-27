require 'formula'

class Openblas < Formula
  homepage 'http://xianyi.github.com/OpenBLAS/'
  url 'http://github.com/xianyi/OpenBLAS/zipball/v0.2.5'
  sha1 '3dabfacac02a1943dc49d5008aa44b29d930d8a2'
  head "https://github.com/xianyi/OpenBLAS.git", :branch => "develop"

  keg_only :provided_by_osx

  env :std

  def install
    ENV.fortran

    # Must call in two steps
    system "make", "CC=#{ENV['CC']}", "FC=#{ENV['FC']}"
    system "make", "PREFIX=#{prefix}", "install"
  end
end
