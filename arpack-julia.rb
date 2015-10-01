require 'formula'

class ArpackJulia < Formula
  homepage 'http://forge.scilab.org/index.php/p/arpack-ng'
  url 'https://github.com/opencollab/arpack-ng/archive/3.2.0.tar.gz'
  sha1 'c1ac96663916a4e11618e9557636ba1bd1a7b556'

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
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
