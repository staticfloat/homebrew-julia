require 'formula'

class ArpackJulia < Formula
  homepage 'http://forge.scilab.org/index.php/p/arpack-ng'
  url 'http://forge.scilab.org/index.php/p/arpack-ng/downloads/get/arpack-ng-3.1.3.tar.gz'
  mirror 'http://d304tytmzqn1fl.cloudfront.net/arpack-ng-3.1.3.tar.gz'
  sha1 'c1ac96663916a4e11618e9557636ba1bd1a7b556'

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
    sha1 '0d2494af7d16f42ff9c27806a73005594ab55564' => :lion
    sha1 'a6994b96ec9ff02684e35335ba5dd3aeeea9ab80' => :mavericks
    sha1 '423337e210f1d3e050212986810d8604a49cddfa' => :mountain_lion
  end

  depends_on :fortran
  depends_on 'staticfloat/julia/openblas-julia' if build.without? 'accelerate'

  option 'with-accelerate', 'Compile against Accelerate/vecLib instead of OpenBLAS'

  def install
    configure_args = ["--disable-dependency-tracking", "--prefix=#{prefix}", "--enable-shared"]
    if build.with? "accelerate"
      configure_args << "--with-blas=-framework vecLib -lblas"
      configure_args << "--with-lapack=-framework vecLib -lblas"
    else
      configure_args << "--with-blas=openblas"
      configure_args << "--with-lapack=openblas"
    end

    system "./configure", *configure_args

    system "make install"
  end
end
