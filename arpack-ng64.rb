require 'formula'

class ArpackNg < Formula
  homepage 'http://forge.scilab.org/index.php/p/arpack-ng'
  url 'http://forge.scilab.org/index.php/p/arpack-ng/downloads/get/arpack-ng_3.1.1.tar.gz'
  md5 'd65b915736650d8878719d4168e50c36'

  depends_on 'open-mpi'
  depends_on 'openblas'

  def install
    ENV.fortran

    # Include MPIF77, as the arpack-ng build process doesn't autodetect properly
    ENV['MPIF77'] = 'mpif77'
    ENV['FFLAGS'] += '-fdefault-integer-8'

    configure_args = ["--disable-dependency-tracking", "--prefix=#{prefix}", "--enable-shared"]
    configure_args << "--with-blas=openblas"
    configure_args << "--with-lapack=openblas"

    system "./configure", *configure_args

    system "make install"
  end
end
