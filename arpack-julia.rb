require 'formula'

class ArpackJulia < Formula
  homepage 'http://forge.scilab.org/index.php/p/arpack-ng'
  url 'http://forge.scilab.org/index.php/p/arpack-ng/downloads/get/arpack-ng-3.1.3.tar.gz'
  mirror 'http://d304tytmzqn1fl.cloudfront.net/arpack-ng-3.1.3.tar.gz'
  sha1 'c1ac96663916a4e11618e9557636ba1bd1a7b556'
  revision 1

  bottle do
    revision 1
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
    sha256 "e1cf1d051cf420d5eaa658f6848ef8ae1575bc594dd73dbbe9e23058ee20a5a1" => :mountain_lion
    sha256 "9490e33de2f787e96527a4981db0ed080336d5953ccb82a8a486760d4fa1cf4f" => :mavericks
    sha256 "f26c082a3ec0833f6769ad3c155296379c90b0ea9398dcde751904e9425e188c" => :yosemite
  end
  keg_only 'Conflicts with arpack in homebrew-science.'

  depends_on :fortran
  depends_on 'staticfloat/julia/openblas-julia'

  def install
    configure_args = ["--disable-dependency-tracking",
                      "--prefix=#{prefix}",
                      "--enable-shared",
                      "--with-blas=openblas",
                      "--with-lapack=openblas"]
    system "./configure", *configure_args
    system "make install"
  end
end
