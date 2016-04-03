require 'formula'

class ArpackJulia < Formula
  homepage 'https://github.com/opencollab/arpack-ng'
  url 'https://github.com/opencollab/arpack-ng/archive/3.3.0.tar.gz'
  sha256 'ad59811e7d79d50b8ba19fd908f92a3683d883597b2c7759fdcc38f6311fe5b3'
  revision 1

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
    sha256 "e30d730310924db8b2a8cd4be4b43696aa497b51ea1bd3206c0b1291fe986062" => :mavericks
    sha256 "078b52612781afa10d879abcfc71dc8aab6c6cd566a79df163855ad803639068" => :yosemite
    sha256 "16b8b22b69253b2284fde5a09d20cbe7e4c8a3f5505e787f52b0c9bb5b10f66c" => :el_capitan
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
