require 'formula'
class SuiteSparseJulia < Formula
  homepage 'http://www.cise.ufl.edu/research/sparse/SuiteSparse'
  url 'http://www.cise.ufl.edu/research/sparse/SuiteSparse/SuiteSparse-4.2.1.tar.gz'
  mirror 'http://d304tytmzqn1fl.cloudfront.net/SuiteSparse-4.2.1.tar.gz'
  sha1 '2fec3bf93314bd14cbb7470c0a2c294988096ed6'

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
    revision 2
    sha1 'ba963279f7bf48fd503ad5a54b733c7ab5b5475d' => :lion
    sha1 'f41b77d912392ca399edc68396b5fb3968b8f9d8' => :mavericks
    sha1 '9b32ce483aa3e2182ae67e3d81dddf7394fdde8d' => :mountain_lion
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
