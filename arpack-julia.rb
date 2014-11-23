require 'formula'

class ArpackJulia < Formula
  homepage 'http://forge.scilab.org/index.php/p/arpack-ng'
  url 'http://forge.scilab.org/index.php/p/arpack-ng/downloads/get/arpack-ng-3.1.3.tar.gz'
  mirror 'http://d304tytmzqn1fl.cloudfront.net/arpack-ng-3.1.3.tar.gz'
  sha1 'c1ac96663916a4e11618e9557636ba1bd1a7b556'
  revision 1

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
    sha1 "c423ce133e147e996fd9678b04a6eb299458e63c" => :mountain_lion
    sha1 "ee130ea5d34ac9a67be239d156a1a7cf082115f4" => :mavericks
    sha1 "4b8b45f3ff6d9437491f7bc23830e433eb759f63" => :yosemite
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
