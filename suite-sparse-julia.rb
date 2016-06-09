require 'formula'
class SuiteSparseJulia < Formula
  homepage 'http://faculty.cse.tamu.edu/davis/suitesparse.html'
  url 'http://faculty.cse.tamu.edu/davis/SuiteSparse/SuiteSparse-4.4.6.tar.gz'
  sha256 '7f22509d87ada8506580d537efde79cf90e28e228355c18b8bf603aad1a2d7b6'
  revision 1

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any_skip_relocation
    sha256 "8ccda16edde2c8f67361c61404e39d08553feded0ae5a262525a19c0ba733f75" => :mavericks
    sha256 "2adb96fa54c46cc9098c2a2a3c147be4495e9267caecaaf5358be2ba67e5075b" => :yosemite
    sha256 "c13e552af6350f0ac838939342e9cb1872745df18c0199e2394e727131d4b9a5" => :el_capitan
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
