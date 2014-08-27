require 'formula'
class SuiteSparseJulia < Formula
  homepage 'http://www.cise.ufl.edu/research/sparse/SuiteSparse'
  url 'http://www.cise.ufl.edu/research/sparse/SuiteSparse/SuiteSparse-4.2.1.tar.gz'
  mirror 'http://d304tytmzqn1fl.cloudfront.net/SuiteSparse-4.2.1.tar.gz'
  sha1 '2fec3bf93314bd14cbb7470c0a2c294988096ed6'

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
    revision 3
    sha1 '2af1a69b48e7e7ce5244c945238fce79c6d9e7b1' => :lion
    sha1 'ed1237672de6b3102a958b9976f91f567274c6ad' => :mavericks
    sha1 '21ce175d9d1f73d34da0f417caa90f9c2715f1a9' => :mountain_lion
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
      s.change_make_var! "BLAS", "-lopenblas"
      s.change_make_var! "LAPACK", "$(BLAS)"

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
