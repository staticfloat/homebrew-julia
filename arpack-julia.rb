require 'formula'

class ArpackJulia < Formula
  homepage 'http://forge.scilab.org/index.php/p/arpack-ng'
  url 'https://github.com/opencollab/arpack-ng/archive/3.2.0.tar.gz'
  sha256 'ce6de85d8de6ae3a741fb9d6169c194ff1b2ffdab289f7af8e41d71bb7818cbb'

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
    sha256 "a53075cc88341d8e527a403fcac0c4624133ce9aa9e4eb4e6bff4642d9ac2bbf" => :mountain_lion
    sha256 "cc1649cd234d6ffa8de1fdc1b7b0ba164e79f6ab86962634586902401fd80016" => :yosemite
    sha256 "c67494f9a97c996945318fdcda2ad71d379442fa5736cfcff2ae6d835496f86f" => :mavericks
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
