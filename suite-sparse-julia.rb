require 'formula'
class SuiteSparseJulia < Formula
  homepage 'http://faculty.cse.tamu.edu/davis/suitesparse.html'
  url 'http://faculty.cse.tamu.edu/davis/SuiteSparse/SuiteSparse-4.4.6.tar.gz'
  sha256 '7f22509d87ada8506580d537efde79cf90e28e228355c18b8bf603aad1a2d7b6'

  bottle do
    revision 1
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any_skip_relocation
    sha256 "b5d1c6cc44aa84ee3afdd2f53e0417a7822794e152a6a83b85616bbc7382aff4" => :mavericks
    sha256 "40915d5410aa86defd31dc37da9052a7a63ce1cebfafdcde3efbea01fbf1c1f0" => :yosemite
    sha256 "25445feb003d31eb437cafe5941f8e483f2ca4587d62647115ec62c4cffed608" => :el_capitan
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
