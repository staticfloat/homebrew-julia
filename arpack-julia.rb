require 'formula'

class ArpackJulia < Formula
  homepage 'https://github.com/opencollab/arpack-ng'
  url 'https://github.com/opencollab/arpack-ng/archive/3.3.0.tar.gz'
  sha256 'ad59811e7d79d50b8ba19fd908f92a3683d883597b2c7759fdcc38f6311fe5b3'
  revision 2

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
    sha256 "9ac83da7eaf691106702dac4daa4ad72d0b30428b81b922e8122bc63cd4adf44" => :mavericks
    sha256 "4a883942ea5a373b96021c7f6cf81664176f5ac356b392d6946f1f0d492e8dac" => :yosemite
    sha256 "39fa4bff2e39a35150cc36fa7f0f0a9427ada3a7039a159981841400b8d704c8" => :el_capitan
  end

  keg_only 'Conflicts with arpack in homebrew-science.'

  depends_on :fortran
  depends_on 'staticfloat/julia/openblas-julia'
  depends_on 'autoconf' => :build
  depends_on 'automake' => :build
  depends_on 'libtool' => :build

  def install
    system "./bootstrap"
    configure_args = ["--disable-dependency-tracking",
                      "--prefix=#{prefix}",
                      "--enable-shared",
                      "--with-blas=openblas",
                      "--with-lapack=openblas"]
    system "./configure", *configure_args
    system "make install"
  end
end
