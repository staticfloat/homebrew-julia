require 'formula'

class ArpackJulia < Formula
  homepage 'http://forge.scilab.org/index.php/p/arpack-ng'
  url 'https://github.com/opencollab/arpack-ng/archive/3.2.0.tar.gz'
  sha256 'ce6de85d8de6ae3a741fb9d6169c194ff1b2ffdab289f7af8e41d71bb7818cbb'

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
