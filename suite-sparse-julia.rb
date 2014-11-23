require 'formula'
class SuiteSparseJulia < Formula
  homepage 'http://www.cise.ufl.edu/research/sparse/SuiteSparse'
  url 'http://faculty.cse.tamu.edu/davis/SuiteSparse/SuiteSparse-4.4.1.tar.gz'
  mirror 'http://d304tytmzqn1fl.cloudfront.net/SuiteSparse-4.4.1.tar.gz'
  sha1 'c8fa39b117b3121839deddbd0e56bf366c8130de'

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
    sha1 "df8f079b74f7cd6d4748d3b4b39e1d4708d75f93" => :mountain_lion
    sha1 "2a955beee5545258fe69c2200228e33de6338fcc" => :mavericks
    sha1 "13e1d74b2aed262acd819f07dda0830e62f65106" => :yosemite
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
