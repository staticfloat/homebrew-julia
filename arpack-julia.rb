require 'formula'

class ArpackJulia < Formula
  homepage 'https://github.com/opencollab/arpack-ng'
  url 'https://github.com/opencollab/arpack-ng/archive/3.3.0.tar.gz'
  sha256 'ad59811e7d79d50b8ba19fd908f92a3683d883597b2c7759fdcc38f6311fe5b3'
  revision 3

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
    sha256 "2d79d6c92ece1e1034a0502add1e4e0d6495a4ea54776ff0200ee6d9a4a73411" => :mavericks
    sha256 "ea2f58568a8b892b188663f129bc21468aa3332d2921c5b5f8cc179a63e9134c" => :yosemite
    sha256 "b4a6f5cc1215e5ed622857e795f20a7a72373b0ade585281a2725de2cc953373" => :el_capitan
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
