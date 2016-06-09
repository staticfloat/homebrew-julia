require 'formula'

class ArpackJulia < Formula
  homepage 'https://github.com/opencollab/arpack-ng'
  url 'https://github.com/opencollab/arpack-ng/archive/3.3.0.tar.gz'
  sha256 'ad59811e7d79d50b8ba19fd908f92a3683d883597b2c7759fdcc38f6311fe5b3'
  revision 1

  bottle do
    revision 1
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
    sha256 "ae09972ab2ee7166e7e42ccbe938185841f78387485d2b9a638c58330785566d" => :el_capitan
    sha256 "fd160c9c959dc8eef03d72e859e0533b8e2019a3efe68f9d0490e42e046bdccf" => :yosemite
    sha256 "cd4a275e37881107e12681bd70947c6efa3b92555e03b6cb1c52bc7ece0139ad" => :mavericks
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
