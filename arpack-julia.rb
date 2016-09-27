require 'formula'

class ArpackJulia < Formula
  homepage 'https://github.com/opencollab/arpack-ng'
  url 'https://github.com/opencollab/arpack-ng/archive/3.3.0.tar.gz'
  sha256 'ad59811e7d79d50b8ba19fd908f92a3683d883597b2c7759fdcc38f6311fe5b3'
  revision 4

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
    sha256 "78e9679556e7f46e8b5c2a23afeb82d50c199e5007123a11da08b88e0ddeac67" => :mavericks
    sha256 "a4658f6e86a44edf45f36bca6ff497e943fa366a5203a00da7130edec62f9237" => :yosemite
    sha256 "d8296a483d095c17d594aae11fab62f2a8d50d95697b91df82a7bcfb61bc013a" => :el_capitan
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
