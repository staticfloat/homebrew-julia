require 'formula'

class ArpackJulia < Formula
  homepage 'http://forge.scilab.org/index.php/p/arpack-ng'
  url 'http://forge.scilab.org/index.php/p/arpack-ng/downloads/get/arpack-ng-3.1.3.tar.gz'
  mirror 'http://d304tytmzqn1fl.cloudfront.net/arpack-ng-3.1.3.tar.gz'
  sha1 'c1ac96663916a4e11618e9557636ba1bd1a7b556'

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
    revision 5
    sha1 '3e89ea9679001f90e3efe62e8861cfb9ad877f97' => :lion
    sha1 '2b74476e124ddecc7edfa03136c130774fc25d1e' => :mavericks
    sha1 'fbc37a09be8b88d54f6fc938e5ff7086466c0945' => :mountain_lion
  end

  keg_only 'Conflicts with arpack in homebrew-science.'

  depends_on :fortran
  depends_on 'staticfloat/julia/openblas-julia'

  def install
    configure_args = ["--disable-dependency-tracking",
                      "--prefix=#{prefix}",
                      "--enable-shared",
                      "--with-blas=openblas",
                      "--with-lapack=openblas"]
    system "./configure", *configure_args
    system "make install"
  end
end
