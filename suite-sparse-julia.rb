require 'formula'
class SuiteSparseJulia < Formula
  homepage 'http://www.cise.ufl.edu/research/sparse/SuiteSparse'
  url 'http://faculty.cse.tamu.edu/davis/SuiteSparse/SuiteSparse-4.4.5.tar.gz'
  sha256 '83f4b88657c7dc57681633e8ca6835ddb12c146bc51af77b6494972ed1ea8bc9'

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
    sha256 "432986f1f8c4646a9b59a1505dc156eee79ed323f2a06b8a8b7be83d6d3be67a" => :mavericks
    sha256 "226fc10718a7b7baa4de7a70e64cce10bb4d50a1d48cd621edc583cc3928e806" => :yosemite
    sha256 "54bcd010eaf372435b2ce32542ad67d200879291c0c9bae9ab03a698dafcb286" => :el_capitan
  end
  keg_only 'Conflicts with suite-sparse in homebrew-science.'

  depends_on "tbb" => :optional
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
