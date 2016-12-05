require 'formula'
class SuiteSparseJulia < Formula
  homepage 'http://faculty.cse.tamu.edu/davis/suitesparse.html'
  url 'http://faculty.cse.tamu.edu/davis/SuiteSparse/SuiteSparse-4.4.6.tar.gz'
  sha256 '7f22509d87ada8506580d537efde79cf90e28e228355c18b8bf603aad1a2d7b6'
  revision 2

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any_skip_relocation
    rebuild 1
    sha256 "131276d30615b93924b493edca2a309a048d1315c79dbf2e1e4f7d093a41cfe5" => :el_capitan
    sha256 "f550bd78668e56756891a4edd7cab8dcd045ae8065a9f0de6056d89ef14001e7" => :mavericks
    sha256 "3cfdba5efff7563ce56d2c403c8c59043c58043d06cc9ef0ba60edfd7676a4fc" => :yosemite
    sha256 "3cc322b02279a5ff549635ef6b3f89fe7e60041cdfb22fb09538bc4714d6de1f" => :sierra
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
