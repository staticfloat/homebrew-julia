require 'formula'

class Arpack64Julia < Formula
  homepage 'http://forge.scilab.org/index.php/p/arpack-ng'
  url 'http://d304tytmzqn1fl.cloudfront.net/arpack-ng-3.1.3.tar.gz'
  sha1 '45b282d0aee768d9504c1a8d5440d069aa39dd62'

  depends_on 'open-mpi'
  depends_on 'openblas64-julia'

  keg_only "Conflicts with arpack"

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
