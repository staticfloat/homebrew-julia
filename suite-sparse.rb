require 'formula'

def metis?
  build.include? 'with-metis'
end

def openblas?
  build.include? 'with-openblas'
end

class SuiteSparse < Formula
  homepage 'http://www.cise.ufl.edu/research/sparse/SuiteSparse'
  url 'http://www.cise.ufl.edu/research/sparse/SuiteSparse/SuiteSparse-4.0.2.tar.gz'
  sha1 '46b24a28eef4b040ea5a02d2c43e82e28b7d6195'

  depends_on "tbb"
  depends_on "metis" if metis?
  depends_on "staticfloat/julia/openblas" if openblas?
  
  options "with-metis", "Compile in metis libraries"
  options "with-openblas", "Use the openblas BLAS libraries instead of Apple's Accelerate"

  def install
    # SuiteSparse doesn't like to build in parallel
    ENV.j1

    inreplace 'SuiteSparse_config/SuiteSparse_config.mk' do |s|
      # Put in the proper libraries
      if openblas?
        s.change_make_var! "BLAS", "-lopenblas"
      else
        s.change_make_var! "BLAS", "-Wl,-framework -Wl,Accelerate"
      end
      s.change_make_var! "LAPACK", "$(BLAS)"
      s.change_make_var! "SPQR_CONFIG", "-DHAVE_TBB"
      s.change_make_var! "TBB", "-ltbb"
      
      if metis?
        s.remove_make_var! "METIS_PATH"
        s.change_make_var! "METIS", Formula.factory("metis").lib + "libmetis.a"
      end

      # Installation
      s.change_make_var! "INSTALL_LIB", lib
      s.change_make_var! "INSTALL_INCLUDE", include
    end

    system "make library"

    lib.mkpath
    include.mkpath
    system "make install"
  end
end