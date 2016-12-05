require 'formula'

class ArpackJulia < Formula
  homepage 'https://github.com/opencollab/arpack-ng'
  url 'https://github.com/opencollab/arpack-ng/archive/3.3.0.tar.gz'
  sha256 'ad59811e7d79d50b8ba19fd908f92a3683d883597b2c7759fdcc38f6311fe5b3'
  revision 4

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
    rebuild 1
    sha256 "88474d2569fec1e8e7fe1a3c996441d7c465b75873881c7db3a6168cc91a2922" => :mavericks
    sha256 "eb58a635b7792754a20d2ebaa00bcaca8d4764fd9eab6e7c92ccab3fec792678" => :yosemite
    sha256 "8dd57cd970b6bcda1dfafeebc776d863abc7670702327117bb3909212842647f" => :el_capitan
    sha256 "9270aa1218081787f845de5da6b5e9124f88580c7b09cbed7bb52de4411954a6" => :sierra
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
