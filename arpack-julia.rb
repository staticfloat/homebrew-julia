require 'formula'

class ArpackJulia < Formula
  homepage 'http://forge.scilab.org/index.php/p/arpack-ng'
  url 'http://forge.scilab.org/index.php/p/arpack-ng/downloads/get/arpack-ng_3.1.1.tar.gz'
  sha1 '45b282d0aee768d9504c1a8d5440d069aa39dd62'

  depends_on 'open-mpi'
  depends_on 'openblas-julia' if !build.include? 'with-accelerate'
  
  keg_only "Conflicts with arpack"

  option 'with-accelerate', 'Compile against Accelerate/vecLib instead of OpenBLAS'

  def install
    ENV.fortran

    # Include MPIF77, as the arpack-ng build process doesn't autodetect properly
    ENV['MPIF77'] = 'mpif77'

    configure_args = ["--disable-dependency-tracking", "--prefix=#{prefix}", "--enable-shared"]
    if build.include? "with-accelerate"
      configure_args << "--with-blas=-framework Accelerate"
      configure_args << "--with-lapack=-framework Accelerate"
    else
      configure_args << "--with-blas=openblas"
      configure_args << "--with-lapack=openblas"
    end

    system "./configure", *configure_args

    system "make install"
  end
end
