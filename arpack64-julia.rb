require 'formula'

class Arpack64Julia < Formula
  homepage 'http://forge.scilab.org/index.php/p/arpack-ng'
  url 'http://forge.scilab.org/index.php/p/arpack-ng/downloads/get/arpack-ng-3.1.3.tar.gz'
  mirror 'http://d304tytmzqn1fl.cloudfront.net/arpack-ng-3.1.3.tar.gz'
  sha1 'c1ac96663916a4e11618e9557636ba1bd1a7b556'

  depends_on :fortran
  depends_on :mpi => :f77
  depends_on 'staticfloat/julia/openblas64-julia'

  keg_only "Conflicts with arpack"

  def install

    if !ENV.has_key?('FFLAGS')
        ENV['FFLAGS'] = ''
    end
    ENV['FFLAGS'] += ' -fdefault-integer-8'

    configure_args = ["--disable-dependency-tracking", "--prefix=#{prefix}", "--enable-shared"]
    configure_args << "--with-blas=openblas"
    configure_args << "--with-lapack=openblas"

    system "./configure", *configure_args

    system "make install"
  end
end
