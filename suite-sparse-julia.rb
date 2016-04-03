require 'formula'
class SuiteSparseJulia < Formula
  homepage 'http://faculty.cse.tamu.edu/davis/suitesparse.html'
  url 'http://faculty.cse.tamu.edu/davis/SuiteSparse/SuiteSparse-4.4.6.tar.gz'
  sha256 '7f22509d87ada8506580d537efde79cf90e28e228355c18b8bf603aad1a2d7b6'

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any_skip_relocation
    sha256 "f79b380d1d36b87758d45241d1f05a6ee76fb27a4ff18e27e1687651589606df" => :mavericks
    sha256 "d1914a3d3dc61d11b2144824180cfe2ac430eddd6c661df5e69b950e41fde8f9" => :yosemite
    sha256 "92bed6f12174f1ba861069bde3f530e0adf6b0ea7c259b2cac3866866b540944" => :el_capitan
  end

  keg_only 'Conflicts with suite-sparse in homebrew-science.'

  depends_on "tbb" => :optional
  depends_on "staticfloat/julia/openblas-julia"

  def install
    # SuiteSparse doesn't like to build in parallel
    ENV.j1

    makevars = ["BLAS=-lopenblas", "LAPACK=-lopenblas"]
    makevars << "INSTALL_LIB='#{lib}'"
    makevars << "INSTALL_INCLUDE='#{include}'"
    makevars << "SPQR_CONFIG='-DNCAMD -DNPARTITION'"
    makevars << "CHOLMOD_CONFIG='-DNCAMD -DNPARTITION'"

    system "make", "library", *makevars

    lib.mkpath
    include.mkpath
    system "make", "install", *makevars
  end
end
