require 'formula'
class SuiteSparseJulia < Formula
  homepage 'http://faculty.cse.tamu.edu/davis/suitesparse.html'
  url 'http://faculty.cse.tamu.edu/davis/SuiteSparse/SuiteSparse-4.4.6.tar.gz'
  sha256 '7f22509d87ada8506580d537efde79cf90e28e228355c18b8bf603aad1a2d7b6'
  revision 2

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any_skip_relocation
    sha256 "4b327bf63b1e70f77218910706d12af6be4528159df3899dcb0f1e89aedca258" => :mavericks
    sha256 "b21151e62bbe70d700070ddbc9dce5f7f57adb1fcc0e4175fae8719c72877c3c" => :yosemite
    sha256 "255b8d24097cf410f58bf36352d14caf9de2c40a28a4d0f5a4f07a8ecf92b59b" => :el_capitan
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
