class CodesignRequirement < Requirement
  include FileUtils
  fatal true

  satisfy(:build_env => false) do
    mktemp do
      touch "llvm_check.txt"
      quiet_system "/usr/bin/codesign", "-s", "lldb_codesign", "--dryrun", "llvm_check.txt"
    end
  end

  def message
    <<-EOS
      lldb_codesign identity must be available to build with LLDB.
      See: https://llvm.org/svn/llvm-project/lldb/trunk/docs/code-signing.txt
    EOS
  end
end

class Llvm37Julia < Formula
  desc "The LLVM Compiler Infrastructure"
  homepage "http://llvm.org/"
  revision 3

  stable do
    url "http://llvm.org/releases/3.7.1/llvm-3.7.1.src.tar.xz"
    sha256 "be7794ed0cec42d6c682ca8e3517535b54555a3defabec83554dbc74db545ad5"

    resource "clang" do
      url "http://llvm.org/releases/3.7.1/cfe-3.7.1.src.tar.xz"
      sha256 "56e2164c7c2a1772d5ed2a3e57485ff73ff06c97dff12edbeea1acc4412b0674"
    end

    resource "clang-tools-extra" do
      url "http://llvm.org/releases/3.7.1/clang-tools-extra-3.7.1.src.tar.xz"
      sha256 "4a91edaccad1ce984c7c49a4a87db186b7f7b21267b2b03bcf4bd7820715bc6b"
    end

    resource "compiler-rt" do
      url "http://llvm.org/releases/3.7.1/compiler-rt-3.7.1.src.tar.xz"
      sha256 "9d4769e4a927d3824bcb7a9c82b01e307c68588e6de4e7f04ab82d82c5af8181"
    end

    resource "polly" do
      url "http://llvm.org/releases/3.7.1/polly-3.7.1.src.tar.xz"
      sha256 "ce9273ad315e1904fd35dc64ac4375fd592f3c296252ab1d163b9ff593ec3542"
    end

    resource "lld" do
      url "http://llvm.org/releases/3.7.1/lld-3.7.1.src.tar.xz"
      sha256 "a929cb44b45e3181a0ad02d8c9df1d3fc71e001139455c6805f3abf2835ef3ac"
    end

    resource "lldb" do
      url "http://llvm.org/releases/3.7.1/lldb-3.7.1.src.tar.xz"
      sha256 "9a0bc315ef55f44c98cdf92d064df0847f453ed156dd0ef6a87e04f5fd6a0e01"
    end

    resource "libcxx" do
      url "http://llvm.org/releases/3.7.1/libcxx-3.7.1.src.tar.xz"
      sha256 "357fbd4288ce99733ba06ae2bec6f503413d258aeebaab8b6a791201e6f7f144"
    end

    if MacOS.version <= :snow_leopard
      resource "libcxxabi" do
        url "http://llvm.org/releases/3.7.1/libcxxabi-3.7.1.src.tar.xz"
        sha256 "a47faaed90f577da8ca3b5f044be9458d354a53fab03003a44085a912b73ab2a"
      end
    end
  end

  head do
    url "http://llvm.org/git/llvm.git", :branch => "release_37"

    resource "clang" do
      url "http://llvm.org/git/clang.git", :branch => "release_37"
    end

    resource "clang-tools-extra" do
      url "http://llvm.org/git/clang-tools-extra.git", :branch => "release_37"
    end

    resource "compiler-rt" do
      url "http://llvm.org/git/compiler-rt.git", :branch => "release_37"
    end

    resource "polly" do
      url "http://llvm.org/git/polly.git", :branch => "release_37"
    end

    resource "lld" do
      url "http://llvm.org/git/lld.git"
    end

    resource "lldb" do
      url "http://llvm.org/git/lldb.git", :branch => "release_37"
    end

    resource "libcxx" do
      url "http://llvm.org/git/libcxx.git", :branch => "release_37"
    end

    if MacOS.version <= :snow_leopard
      resource "libcxxabi" do
        url "http://llvm.org/git/libcxxabi.git", :branch => "release_37"
      end
    end
  end

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
    rebuild 1
    sha256 "1adf4d91578a83bfd1bab56a9b27edd6fc1c4f205a75b7811deae2b02dd99a98" => :mavericks
    sha256 "18e3bb601d7c9d3b76d52e40113c12afe1e0bd0e7664f5d7244a5013578a1773" => :yosemite
    sha256 "6a072218991275037ddb37a1aa5f89d47b4bcf938596a2745b28f657de273638" => :el_capitan
    sha256 "89c8f526ed2d4e33cccaa8de4290d6a95fe37c451361f8543bdc20c623ed34bf" => :sierra
  end

  keg_only 'Conflicts with llvm37 in homebrew-versions.'

  def patches
    patch_list = []

   # LLVM 3.7.1 patches
    for patch_name in ["llvm-3.7.1", "llvm-3.7.1_2", "llvm-3.7.1_3", "llvm-D14260", "llvm-nodllalias", "llvm-D21271-instcombine-tbaa-3.7"]
      patch_list << "https://raw.githubusercontent.com/JuliaLang/julia/v0.5.0-rc2/deps/patches/#{patch_name}.patch"
    end

    # Add Homebrew's llvm37 patch
    patch_list << "https://gist.githubusercontent.com/staticfloat/a430de88fefffcf79d1a75d7b8362aab/raw/142ac6885a438eb5555ed38f1359193ebf588b7a/homebrew-llvm37.patch"

    return patch_list
  end


  option :universal
  option "with-lld", "Build LLD linker"
  option "with-lldb", "Build LLDB debugger"
  option "with-asan", "Include support for -faddress-sanitizer (from compiler-rt)"
  option "with-all-targets", "Build all target backends"
  option "with-python", "Build lldb bindings against the python in PATH instead of system Python"
  option "without-shared", "Don't build LLVM as a shared library"
  option "with-assertions", "Slows down LLVM, but provides more debug information"

  depends_on "gnu-sed" => :build
  depends_on "gmp"
  depends_on "libffi" => :recommended
  depends_on "python@2" => :optional

  if build.with? "lldb"
    depends_on "swig"
    depends_on CodesignRequirement
  end

  # version suffix
  def ver
    "3.7"
  end

  # LLVM installs its own standard library which confuses stdlib checking.
  cxxstdlib_check :skip

  # Apple's libstdc++ is too old to build LLVM
  #fails_with :gcc
  #fails_with :llvm

  def install
    # One of llvm makefiles relies on gnu sed behavior to generate CMake modules correctly
    ENV.prepend_path "PATH", "#{Formula["gnu-sed"].opt_libexec}/gnubin"
    # Apple's libstdc++ is too old to build LLVM
    ENV.libcxx if ENV.compiler == :clang

    clang_buildpath = buildpath/"tools/clang"
    libcxx_buildpath = buildpath/"projects/libcxx"
    libcxxabi_buildpath = buildpath/"libcxxabi" # build failure if put in projects due to no Makefile

    clang_buildpath.install resource("clang")
    libcxx_buildpath.install resource("libcxx")
    (buildpath/"tools/polly").install resource("polly")
    (buildpath/"tools/clang/tools/extra").install resource("clang-tools-extra")
    (buildpath/"tools/lld").install resource("lld") if build.with? "lld"
    (buildpath/"tools/lldb").install resource("lldb") if build.with? "lldb"
    (buildpath/"projects/compiler-rt").install resource("compiler-rt") if build.with? "asan"

    if build.universal?
      ENV.permit_arch_flags
      ENV["UNIVERSAL"] = "1"
      ENV["UNIVERSAL_ARCH"] = Hardware::CPU.universal_archs.join(" ")
    end

    ENV["REQUIRES_RTTI"] = "1"

    install_prefix = lib/"llvm-#{ver}"

    args = %W[
      --prefix=#{install_prefix}
      --enable-optimized
      --disable-bindings
      --with-gmp=#{Formula["gmp"].opt_prefix}
    ]

    if build.with? "all-targets"
      args << "--enable-targets=all"
    else
      args << "--enable-targets=host"
    end

    args << "--enable-shared" if build.with? "shared"
    args << "--disable-assertions" if build.without? "assertions"
    args << "--enable-libffi" if build.with? "libffi"

    mktemp do
      system buildpath/"configure", *args
      system "make", "VERBOSE=1"
      system "make", "VERBOSE=1", "install"
    end

    if MacOS.version <= :snow_leopard
      libcxxabi_buildpath.install resource("libcxxabi")

      cd libcxxabi_buildpath/"lib" do
        # Set rpath to save user from setting DYLD_LIBRARY_PATH
        inreplace "buildit", "-install_name /usr/lib/libc++abi.dylib", "-install_name #{install_prefix}/usr/lib/libc++abi.dylib"

        ENV["CC"] = "#{install_prefix}/bin/clang"
        ENV["CXX"] = "#{install_prefix}/bin/clang++"
        ENV["TRIPLE"] = "*-apple-*"
        system "./buildit"
        (install_prefix/"usr/lib").install "libc++abi.dylib"
        cp libcxxabi_buildpath/"include/cxxabi.h", install_prefix/"lib/c++/v1"
      end

      # Snow Leopard make rules hardcode libc++ and libc++abi path.
      # Change to Cellar path here.
      inreplace "#{libcxx_buildpath}/lib/buildit" do |s|
        s.gsub! "-install_name /usr/lib/libc++.1.dylib", "-install_name #{install_prefix}/usr/lib/libc++.1.dylib"
        s.gsub! "-Wl,-reexport_library,/usr/lib/libc++abi.dylib", "-Wl,-reexport_library,#{install_prefix}/usr/lib/libc++abi.dylib"
      end

      # On Snow Leopard and older system libc++abi is not shipped but
      # needed here. It is hard to tweak environment settings to change
      # include path as libc++ uses a custom build script, so just
      # symlink the needed header here.
      ln_s libcxxabi_buildpath/"include/cxxabi.h", libcxx_buildpath/"include"
    end

    if MacOS.version >= :el_capitan
      inreplace "#{libcxx_buildpath}/include/string",
        "basic_string<_CharT, _Traits, _Allocator>::basic_string(const allocator_type& __a)",
        "basic_string<_CharT, _Traits, _Allocator>::basic_string(const allocator_type& __a) noexcept(is_nothrow_copy_constructible<allocator_type>::value)"
    end

    # Putting libcxx in projects only ensures that headers are installed.
    # Manually "make install" to actually install the shared libs.
    libcxx_make_args = [
      # Use the built clang for building
      "CC=#{install_prefix}/bin/clang",
      "CXX=#{install_prefix}/bin/clang++",
      # Properly set deployment target, which is needed for Snow Leopard
      "MACOSX_DEPLOYMENT_TARGET=#{MacOS.version}",
      # The following flags are needed so it can be installed correctly.
      "DSTROOT=#{install_prefix}",
      "SYMROOT=#{libcxx_buildpath}",
    ]

    system "make", "-C", libcxx_buildpath, "install", *libcxx_make_args

    (share/"clang-#{ver}/tools").install Dir["tools/clang/tools/scan-{build,view}"]
    inreplace share/"clang-#{ver}/tools/scan-build/scan-build", "$RealBin/bin/clang", install_prefix/"bin/clang"
    ln_s share/"clang-#{ver}/tools/scan-build/scan-build", install_prefix/"bin"
    ln_s share/"clang-#{ver}/tools/scan-view/scan-view", install_prefix/"bin"
    (install_prefix/"share/man/man1").install share/"clang-#{ver}/tools/scan-build/scan-build.1"

    (lib/"python2.7/site-packages").install "bindings/python/llvm" => "llvm-#{ver}",
                                            clang_buildpath/"bindings/python/clang" => "clang-#{ver}"
    (lib/"python2.7/site-packages").install_symlink install_prefix/"lib/python2.7/site-packages/lldb" => "lldb-#{ver}" if build.with? "lldb"

    Dir.glob(install_prefix/"bin/*") do |exec_path|
      basename = File.basename(exec_path)
      bin.install_symlink exec_path => "#{basename}-#{ver}"
    end

    Dir.glob(install_prefix/"share/man/man1/*") do |manpage|
      basename = File.basename(manpage, ".1")
      man1.install_symlink manpage => "#{basename}-#{ver}.1"
    end
  end

  def caveats; <<-EOS
    Extra tools are installed in #{opt_share}/clang-#{ver}

    To link to libc++, something like the following is required:
      CXX="clang++-#{ver} -stdlib=libc++"
      CXXFLAGS="$CXXFLAGS -nostdinc++ -I#{opt_lib}/llvm-#{ver}/include/c++/v1"
      LDFLAGS="$LDFLAGS -L#{opt_lib}/llvm-#{ver}/lib"
    EOS
  end

  test do
    # test for sed errors since some llvm makefiles assume that sed
    # understands '\n' which is true for gnu sed and not for bsd sed.
    assert_no_match /PATH\)n/, (lib/"llvm-3.7/share/llvm/cmake/LLVMConfig.cmake").read
    system "#{bin}/llvm-config-#{ver}", "--version"
  end
end

__END__
