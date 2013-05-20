require 'formula'
class SuiteSparse64Julia < Formula
  homepage 'http://www.cise.ufl.edu/research/sparse/SuiteSparse'
  url 'http://www.cise.ufl.edu/research/sparse/SuiteSparse/SuiteSparse-4.2.1.tar.gz'
  sha1 'ea6688bd6f6adf81e2e5aacdc71d7dcf9a5d208d'

  depends_on "tbb" if build.include? 'with-tbb'
  depends_on "metis" if build.include? 'with-metis'
  depends_on "openblas64-julia"

  option "with-metis", "Compile in metis libraries"

  keg_only "Conflicts with suite-sparse"

  def install
    # SuiteSparse doesn't like to build in parallel
    ENV.j1

    inreplace 'SuiteSparse_config/SuiteSparse_config.mk' do |s|
      # Put in the proper libraries
      s.change_make_var! "BLAS", "-lopenblas"
      s.change_make_var! "LAPACK", "$(BLAS)"

      if build.include? "with-tbb"
        s.change_make_var! "SPQR_CONFIG", "-DHAVE_TBB"
        s.change_make_var! "TBB", "-ltbb"
      end

      if build.include? "with-metis"
        s.remove_make_var! "METIS_PATH"
        s.change_make_var! "METIS", Formula.factory("metis").lib + "libmetis.a"
      end

      # Installation
      s.change_make_var! "INSTALL_LIB", lib
      s.change_make_var! "INSTALL_INCLUDE", include
      
      s.change_make_var! "SPQR_CONFIG", "-DNCAMD -DNPARTITION"
    end

    system "make library UMFPACK_CONFIG=-DLONGBLAS=\"'long long'\" CHOLMOD_CONFIG=\"-DLONGBLAS='long long' -DNCAMD -DNPARTITION\""

    lib.mkpath
    include.mkpath
    system "make install"
  end
end
