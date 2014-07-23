require 'formula'
class SuiteSparseJulia < Formula
  homepage 'http://www.cise.ufl.edu/research/sparse/SuiteSparse'
  url 'http://www.cise.ufl.edu/research/sparse/SuiteSparse/SuiteSparse-4.2.1.tar.gz'
  mirror 'http://d304tytmzqn1fl.cloudfront.net/SuiteSparse-4.2.1.tar.gz'
  sha1 '2fec3bf93314bd14cbb7470c0a2c294988096ed6'

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
    sha1 'f7111df67b8162ee10ca4cc84431153304dfd8f3' => :lion
    sha1 '44a9726dae5bc711a9734d5e8b23c9301d86ce05' => :mavericks
    sha1 '16db0dd7fc69a535e7bed985db90be29c2febd29' => :mountain_lion
  end

  depends_on "tbb" => :optional
  depends_on "metis" => :optional
  depends_on "staticfloat/julia/openblas-julia" if build.without? 'accelerate'

  option "with-metis", "Compile in metis libraries"
  option 'with-accelerate', 'Compile against Accelerate/vecLib instead of OpenBLAS'

  def install
    # SuiteSparse doesn't like to build in parallel
    ENV.j1

    inreplace 'SuiteSparse_config/SuiteSparse_config.mk' do |s|
      # Put in the proper libraries
      s.change_make_var! "BLAS", "-lopenblas" if build.without? 'accelerate'
      s.change_make_var! "BLAS", "-Wl,-framework -Wl,Accelerate" if build.with? 'accelerate'
      s.change_make_var! "LAPACK", "$(BLAS)"

      if build.with? "tbb"
        s.change_make_var! "SPQR_CONFIG", "-DHAVE_TBB"
        s.change_make_var! "TBB", "-ltbb"
      end

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
