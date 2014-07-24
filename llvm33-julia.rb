require 'formula'

class Llvm33Julia < Formula
  homepage  'http://llvm.org/'
  revision 1

  stable do
    url 'http://llvm.org/releases/3.3/llvm-3.3.src.tar.gz'
    sha1 'c6c22d5593419e3cb47cbcf16d967640e5cce133'

    resource 'clang' do
      url 'http://llvm.org/releases/3.3/cfe-3.3.src.tar.gz'
      sha1 'ccd6dbf2cdb1189a028b70bcb8a22509c25c74c8'
    end

    resource 'clang-tools-extra' do
      url 'http://llvm.org/releases/3.3/clang-tools-extra-3.3.src.tar.gz'
      sha1 '6f7af9ba8014f7e286a02e4ae2e3f2017b8bfac2'
    end

    resource 'compiler-rt' do
      url 'http://llvm.org/releases/3.3/compiler-rt-3.3.src.tar.gz'
      sha1 '745386ec046e3e49742e1ecb6912c560ccd0a002'
    end

    resource 'polly' do
      url 'http://llvm.org/releases/3.3/polly-3.3.src.tar.gz'
      sha1 'eb75f5674fedf77425d16c9c0caec04961f03e04'
    end

    resource 'libcxx' do
      url 'http://llvm.org/releases/3.3/libcxx-3.3.src.tar.gz'
      sha1 '7bea00bc1031bf3bf6c248e57c1f4e0874c18c04'
    end
  end

  head do
    url 'http://llvm.org/git/llvm.git', :branch => 'release_33'

    resource 'clang' do
      url 'http://llvm.org/git/clang.git', :branch => 'release_33'
    end

    resource 'clang-tools-extra' do
      url 'http://llvm.org/git/clang-tools-extra.git', :branch => 'release_33'
    end

    resource 'compiler-rt' do
      url 'http://llvm.org/git/compiler-rt.git', :branch => 'release_33'
    end

    resource 'polly' do
      url 'http://llvm.org/git/polly.git', :branch => 'release_33'
    end

    resource 'libcxx' do
      url 'http://llvm.org/git/libcxx.git', :branch => 'release_33'
    end
  end


  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
    revision 1
    sha1 'e694e0a3315f0351ec0343ef8ae26dfc487d638d' => :lion
    sha1 'c33c68a1f0381ddb8319788028fa731f126cb0cb' => :mavericks
    sha1 'c326a227f238421e8e7832d90fa285849c2a1a2b' => :mountain_lion
  end

  if MacOS.version <= :snow_leopard
    # Not tarball release for libc++abi yet. Using latest branch.
    resource 'libcxxabi' do
      url 'http://llvm.org/git/libcxxabi.git', :branch => 'release_32'
    end

    resource 'clang-unwind-patch' do
      url 'http://llvm.org/viewvc/llvm-project/cfe/trunk/lib/Headers/unwind.h?r1=172666&r2=189535&view=patch', :using => :nounzip
      sha1 'b40f6dba4928add36945c50e5b89ca0988147cd2'
    end
  end

  option :universal
  option 'with-libcxx', 'Build libc++ standard library support'
  option 'with-clang', 'Build Clang C/ObjC/C++ frontend'
  option 'with-asan', 'Include support for -faddress-sanitizer (from compiler-rt)'
  option 'disable-shared', "Don't build LLVM as a shared library"
  option 'all-targets', 'Build all target backends'
  option 'rtti', 'Build with C++ RTTI'
  option 'disable-assertions', 'Speeds up LLVM, but provides less debug information'

  depends_on :python => :recommended
  depends_on 'staticfloat/julia/gmp4-julia'
  depends_on 'staticfloat/julia/isl011-julia'
  depends_on 'staticfloat/julia/cloog018-julia'
  depends_on 'libffi' => :recommended

  def ver; '3.3'; end # version suffix

  def install
    # LLVM installs its own standard library which confuses stdlib checking.
    cxxstdlib_check :skip

    if build.with? "python" and build.include? 'disable-shared'
      raise 'The Python bindings need the shared library.'
    end

    if build.with? 'libcxx' and build.without? 'clang'
      raise '"--with-libcxx" requires "--with-clang".'
    end

    if build.with? 'libcxx' and not build.include? 'rtti'
      raise '"--with-libcxx" requires "rtti".'
    end

    polly_buildpath = buildpath/'tools/polly'
    clang_buildpath = buildpath/'tools/clang'
    clang_tools_extra_buildpath = buildpath/'tools/clang/tools/extra'
    compiler_rt_buildpath = buildpath/'projects/compiler-rt'
    libcxx_buildpath = buildpath/'projects/libcxx'
    libcxxabi_buildpath = buildpath/'libcxxabi' # build failure if put in projects due to no Makefile

    polly_buildpath.install resource('polly')
    clang_buildpath.install resource('clang') if build.with? 'clang'
    clang_tools_extra_buildpath.install resource('clang-tools-extra') if build.with? 'clang'
    compiler_rt_buildpath.install resource('compiler-rt') if build.with? 'asan'
    libcxx_buildpath.install resource('libcxx') if build.with? 'libcxx'

    # On Snow Leopard and below libc++abi is not shipped but needed for libc++.
    if MacOS.version <= :snow_leopard and build.with? 'libcxx'
      libcxxabi_buildpath.install resource('libcxxabi')
      buildpath.install resource('clang-unwind-patch')
      cd clang_buildpath do
        system "patch -p2 -N < #{buildpath}/unwind.h"
      end
    end

    if build.universal?
      ENV.permit_arch_flags
      ENV['UNIVERSAL'] = '1'
      ENV['UNIVERSAL_ARCH'] = Hardware::CPU.universal_archs.join(' ')
    end

    ENV['REQUIRES_RTTI'] = '1' if build.include? 'rtti'

    install_prefix = lib/"llvm-#{ver}"

    args = [
      "--prefix=#{install_prefix}",
      "--enable-optimized",
      # As of LLVM 3.1, attempting to build ocaml bindings with Homebrew's
      # OCaml 3.12.1 results in errors.
      "--disable-bindings",
      "--with-gmp=#{Formula["gmp4"].opt_prefix}",
      "--with-isl=#{Formula["isl011"].opt_prefix}",
      "--with-cloog=#{Formula["cloog018"].opt_prefix}"
    ]

    if build.include? 'all-targets'
      args << '--enable-targets=all'
    else
      args << '--enable-targets=host'
    end

    args << "--enable-shared" unless build.include? 'disable-shared'

    args << "--disable-assertions" if build.include? 'disable-assertions'

    args << "--enable-libffi" if build.with? 'libffi'

    system './configure', *args
    system 'make', 'VERBOSE=1'
    system 'make', 'VERBOSE=1', 'install'

    # Snow Leopard is not shipped with libc++abi. Manually build here.
    cd libcxxabi_buildpath/'lib' do
      # Set rpath to save user from setting DYLD_LIBRARY_PATH
      inreplace libcxxabi_buildpath/'lib/buildit', '-install_name /usr/lib/libc++abi.dylib', "-install_name #{install_prefix}/usr/lib/libc++abi.dylib"

      ENV['CC'] = "#{install_prefix}/bin/clang"
      ENV['CXX'] = "#{install_prefix}/bin/clang++"
      ENV['TRIPLE'] = "*-apple-*"
      system "./buildit"
      # Install libs.
      (install_prefix/'usr/lib/').install libcxxabi_buildpath/'lib/libc++abi.dylib'
      # Install headers.
      cp libcxxabi_buildpath/'include/cxxabi.h', install_prefix/'lib/c++/v1/'
    end if MacOS.version <= :snow_leopard and build.with? 'libcxx'

    # Putting libcxx in projects only ensures that headers are installed.
    # Manually "make install" to actually install the shared libs.
    cd libcxx_buildpath do
      if MacOS.version <= :snow_leopard
        # Snow Leopard make rules hardcode libc++ and libc++abi path.
        # Change to Cellar path here.
        inreplace libcxx_buildpath/'lib/buildit', '-install_name /usr/lib/libc++.1.dylib', "-install_name #{install_prefix}/usr/lib/libc++.1.dylib"
        inreplace libcxx_buildpath/'lib/buildit', '-Wl,-reexport_library,/usr/lib/libc++abi.dylib', "-Wl,-reexport_library,#{install_prefix}/usr/lib/libc++abi.dylib"
      end

      libcxx_make_args = [
        # Use the built clang for building
        "CC=#{install_prefix}/bin/clang",
        "CXX=#{install_prefix}/bin/clang++",
        # Properly set deployment target, which is needed for Snow Leopard
        "MACOSX_DEPLOYMENT_TARGET=#{MacOS.version}",
        # The following flags are needed so it can be installed correctly.
        "DSTROOT=#{install_prefix}",
        "SYMROOT=#{libcxx_buildpath}"
      ]

      # On Snow Leopard and older system libc++abi is not shipped but
      # needed here. It is hard to tweak environment settings to change
      # include path as libc++ uses a custom build script, so just
      # symlink the needed header here.
      ln_s libcxxabi_buildpath/'include/cxxabi.h', libcxx_buildpath/'include' if MacOS.version <= :snow_leopard

      system 'make', 'install', *libcxx_make_args
    end if build.with? 'libcxx'

    # Install Clang tools
    (share/"clang-#{ver}/tools").install clang_buildpath/'tools/scan-build', clang_buildpath/'tools/scan-view' if build.with? 'clang'

    if build.with? "python"
      # Install llvm python bindings.
      mv buildpath/'bindings/python/llvm', buildpath/"bindings/python/llvm-#{ver}"
      (lib+'python2.7/site-packages').install buildpath/"bindings/python/llvm-#{ver}"
      # Install clang tools and bindings if requested.
      if build.with? 'clang'
        mv clang_buildpath/'bindings/python/clang', clang_buildpath/"bindings/python/clang-#{ver}"
        (lib+'python2.7/site-packages').install clang_buildpath/"bindings/python/clang-#{ver}"
      end
    end

    # Link executables to bin and add suffix to avoid conflicts
    Dir.glob(install_prefix/'bin/*') do |exec_path|
      basename = File.basename(exec_path)
      bin.install_symlink exec_path => "#{basename}-#{ver}"
    end

    # Also link man pages
    Dir.glob(install_prefix/'share/man/man1/*') do |manpage|
      basename = File.basename(manpage, ".1")
      man1.install_symlink manpage => "#{basename}-#{ver}.1"
    end
  end

  def test
    system "#{bin}/llvm-config-#{ver}", "--version"
  end

  def caveats
    s = ''

    if build.with? 'clang'
      s += "Extra tools are installed in #{HOMEBREW_PREFIX/"share/clang-#{ver}"}."
    end

    if build.with? 'libcxx'
      include_path = HOMEBREW_PREFIX/"lib/llvm-#{ver}/lib/c++/v1"
      libs_path = HOMEBREW_PREFIX/"lib/llvm-#{ver}/usr/lib"
      s += <<-EOS.undent

      To link to libc++ built here, please adjust your environment as follow:

        CXX="clang++-#{ver} -stdlib=libc++"
        CXXFLAGS="${CXXFLAGS} -nostdinc++ -I#{include_path}"
        LDFLAGS="${LDFLAGS} -L#{libs_path}"
      EOS
    end
    s
  end
end
