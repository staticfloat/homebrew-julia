require 'formula'
class SuiteSparseJulia < Formula
  homepage 'http://www.cise.ufl.edu/research/sparse/SuiteSparse'
  url 'http://faculty.cse.tamu.edu/davis/SuiteSparse/SuiteSparse-4.4.3.tar.gz'
  mirror 'http://d304tytmzqn1fl.cloudfront.net/SuiteSparse-4.4.3.tar.gz'
  sha1 '3a583ca4c09c6e9d7c574d313ad93e514478bb29'

  bottle do
    revision 1
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
    sha256 "f3672a7af2550d137c12945bdfe7c804e65c8d76eae15a0bc5e27520dc283adf" => :mountain_lion
    sha256 "08151e96b5dbe02b9cac21500f2d17e28670b6ed081f8e46d831c90208422a54" => :yosemite
    sha256 "998b61c8d0432aa973af5181f96159db98288f5f0e65b787000b299a9b585468" => :mavericks
  end
  keg_only 'Conflicts with suite-sparse in homebrew-science.'

  depends_on "tbb" => :optional
  depends_on "metis" => :optional
  depends_on "staticfloat/julia/openblas-julia"

  option "with-metis", "Compile in metis libraries"

  def install
    # SuiteSparse doesn't like to build in parallel
    ENV.j1

    inreplace 'SuiteSparse_config/SuiteSparse_config.mk' do |s|
      # Put in the proper libraries
      s.change_make_var! "  BLAS", "-lopenblas"
      s.change_make_var! "  LAPACK", "$(BLAS)"

      if build.with? "metis"
        s.remove_make_var! "METIS_PATH"
        s.change_make_var! "METIS", Formula["metis"].lib + "libmetis.a"
      end

      # Installation
      s.change_make_var! "INSTALL_LIB", lib
      s.change_make_var! "INSTALL_INCLUDE", include

      s.change_make_var! "SPQR_CONFIG", "-DNCAMD -DNPARTITION"
      s.change_make_var! "CHOLMOD_CONFIG", "-DNCAMD -DNPARTITION"
    end

    system "make library"

    lib.mkpath
    include.mkpath
    system "make install"
  end
end
