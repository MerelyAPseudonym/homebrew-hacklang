require 'formula'

class Hhvm < Formula
  homepage 'http://hhvm.com/'
  stable do
    url 'https://github.com/facebook/hhvm/archive/HHVM-3.4.0.tar.gz'
    sha1 '7f5ddb96c0099480b3172aadf2945b5f99b43e16'
    resource 'third-party' do
      url 'https://github.com/hhvm/hhvm-third-party.git', :revision => "38af35db27a4d962adaefde343dc6dcfc495c8b5"
    end
    resource 'folly' do
      url 'https://github.com/facebook/folly.git', :revision => "acc54589227951293f8d3943911f4311468605c9"
    end
    resource 'thrift' do
      url 'https://github.com/facebook/fbthrift.git', :revision => "378e954ac82a00ba056e6fccd5e1fa3e76803cc8"
    end
  end

  devel do
    url 'https://github.com/facebook/hhvm.git', :branch => "HHVM-3.4"
    version 'hhvm-3.4dev'
    resource 'third-party' do
      url 'https://github.com/hhvm/hhvm-third-party.git', :revision => "38af35db27a4d962adaefde343dc6dcfc495c8b5"
    end
    resource 'folly' do
      url 'https://github.com/facebook/folly.git', :revision => "acc54589227951293f8d3943911f4311468605c9"
    end
    resource 'thrift' do
      url 'https://github.com/facebook/fbthrift.git', :revision => "378e954ac82a00ba056e6fccd5e1fa3e76803cc8"
    end
  end

  head do
    url 'https://github.com/facebook/hhvm.git'
    resource 'third-party' do
      url 'https://github.com/hhvm/hhvm-third-party.git'
    end
  end

  option 'with-cotire', 'Speed up the build by precompiling headers'
  option 'with-debug', 'Enable debug build (default Release)'
  option 'with-gcc', 'Build with gcc-4.9 compiler'
  option 'with-mariadb', 'Use mariadb as mysql package'
  option 'with-minsizerel', 'Enable minimal size release build'
  option 'with-percona-server', 'Use percona-server as mysql package'
  option 'with-release-debug', 'Enable release with debug build'
  option 'with-system-mysql', 'Try to use the mysql package installed on your system'
  option 'with-libressl', 'To use an alternate version of SSL (LibreSSL)'

  depends_on 'cmake' => :build
  depends_on 'libtool' => :build
  depends_on 'autoconf' => :build
  depends_on 'automake' => :build
  depends_on 'pkg-config' => :build
  depends_on 'gcc' => :optional
  depends_on 'libressl' => :optional
  depends_on 'openssl' if build.without? 'libressl'

  # Standard packages
  depends_on 'boost' if build.without? 'gcc'
  depends_on 'boostfb' if build.with? 'gcc'
  depends_on 'binutilsfb'
  depends_on 'curl'
  depends_on 'freetype'
  depends_on 'gd'
  depends_on 'gettext'
  depends_on 'glog' if build.without? 'gcc'
  depends_on 'glogfb' if build.with? 'gcc'
  depends_on 'icu4c'
  depends_on 'imagemagick'
  depends_on 'imap-uw'
  depends_on 'jemallocfb'
  depends_on 'jpeg'
  depends_on 'libdwarf'
  depends_on 'libelf'
  depends_on 'libevent'
  depends_on 'libmemcached'
  depends_on 'libpng'
  depends_on 'libssh2'
  depends_on 'libvpx'
  depends_on 'libxslt'
  depends_on 'libzip'
  depends_on 'lz4'
  depends_on 'mcrypt'
  depends_on 'objective-caml'
  depends_on 'oniguruma'
  depends_on 'pcre'
  depends_on 're2c'
  depends_on 'readline'
  depends_on 'sqlite'
  depends_on 'tbb'
  depends_on 'unixodbc'

  #MySQL packages
  if build.with? 'mariadb'
    depends_on 'mariadb'
  elsif build.with? 'percona-server'
    depends_on 'percona-server'
  elsif build.without? 'system-mysql'
    depends_on 'mysql'
    depends_on 'mysql-connector-c++'
  end

  # Hotfix patches
  if build.stable? or build.devel? or build.head?
    if build.stable? or build.devel?
      # Support openssl replacements which don't export RAND_egd()
      patch do
        url "https://github.com/facebook/hhvm/commit/df1ac0a7371c818d3d4b5c85859905e373145446.diff"
        sha1 "d2f5235da22e5c80c9570dfb7fe2db94bb5d11d5"
      end
      # Improve segaddr fixing for 32-bit destructors
      patch do
        url "https://github.com/facebook/hhvm/commit/d65448c.diff"
        sha1 "d735bb7012c748fed65fdebfe9d2e9ee9bf19649"
      end
    end

    # FB broken selectable path http://git.io/EqkkMA
    patch do
      url "https://github.com/facebook/hhvm/pull/3517.diff"
      sha1 "ba8c3dbf1e75957b6733aaf52207d4e55f1d286a"
    end
  end

  def install
    args = [
      ".",
      "-DCCLIENT_INCLUDE_PATH=#{Formula['imap-uw'].opt_prefix}/include/imap",
      "-DCMAKE_INCLUDE_PATH=\"#{HOMEBREW_PREFIX}/include:/usr/include\"",
      "-DCMAKE_INSTALL_PREFIX=#{prefix}",
      "-DCMAKE_LIBRARY_PATH=\"#{HOMEBREW_PREFIX}/lib:/usr/lib\"",
      "-DCURL_INCLUDE_DIR=#{Formula['curl'].opt_prefix}/include",
      "-DCURL_LIBRARY=#{Formula['curl'].opt_prefix}/lib/libcurl.dylib",
      "-DFREETYPE_INCLUDE_DIRS=#{Formula['freetype'].opt_prefix}/include/freetype2",
      "-DFREETYPE_LIBRARIES=#{Formula['freetype'].opt_prefix}/lib/libfreetype.dylib",
      "-DICU_DATA_LIBRARY=#{Formula['icu4c'].opt_prefix}/lib/libicudata.dylib",
      "-DICU_I18N_LIBRARY=#{Formula['icu4c'].opt_prefix}/lib/libicui18n.dylib",
      "-DICU_INCLUDE_DIR=#{Formula['icu4c'].opt_prefix}/include",
      "-DICU_LIBRARY=#{Formula['icu4c'].opt_prefix}/lib/libicuuc.dylib",
      "-DJEMALLOC_INCLUDE_DIR=#{Formula['jemallocfb'].opt_prefix}/include",
      "-DJEMALLOC_LIB=#{Formula['jemallocfb'].opt_prefix}/lib/libjemalloc.dylib",
      "-DLBER_LIBRARIES=/usr/lib/liblber.dylib",
      "-DLDAP_INCLUDE_DIR=/usr/include",
      "-DLDAP_LIBRARIES=/usr/lib/libldap.dylib",
      "-DLIBDWARF_INCLUDE_DIRS=#{Formula['libdwarf'].opt_prefix}/include",
      "-DLIBDWARF_LIBRARIES=#{Formula['libdwarf'].opt_prefix}/lib/libdwarf.3.dylib",
      "-DLIBELF_INCLUDE_DIRS=#{Formula['libelf'].opt_prefix}/include/libelf",
      "-DLIBEVENT_INCLUDE_DIR=#{Formula['libevent'].opt_prefix}/include",
      "-DLIBEVENT_LIB=#{Formula['libevent'].opt_prefix}/lib/libevent.dylib",
      "-DLIBINTL_INCLUDE_DIR=#{Formula['gettext'].opt_prefix}/include",
      "-DLIBINTL_LIBRARIES=#{Formula['gettext'].opt_prefix}/lib/libintl.dylib",
      "-DLIBJPEG_INCLUDE_DIRS=#{Formula['jpeg'].opt_prefix}/include",
      "-DLIBMAGICKWAND_INCLUDE_DIRS=#{Formula['imagemagick'].opt_prefix}/include/ImageMagick-6",
      "-DLIBMAGICKWAND_LIBRARIES=#{Formula['imagemagick'].opt_prefix}/lib/libMagickWand-6.Q16.dylib",
      "-DLIBMEMCACHED_INCLUDE_DIR=#{Formula['libmemcached'].opt_prefix}/include",
      "-DLIBODBC_INCLUDE_DIRS=#{Formula['unixodbc'].opt_prefix}/include",
      "-DLIBPNG_INCLUDE_DIRS=#{Formula['libpng'].opt_prefix}/include",
      "-DLIBSQLITE3_INCLUDE_DIR=#{Formula['sqlite'].opt_prefix}/include",
      "-DLIBSQLITE3_LIBRARY=#{Formula['sqlite'].opt_prefix}/lib/libsqlite3.0.dylib",
      "-DLIBVPX_INCLUDE_DIRS=#{Formula['libvpx'].opt_prefix}/include",
      "-DLIBVPX_LIBRARIES=#{Formula['libvpx'].opt_prefix}/lib/libvpx.a",
      "-DLIBZIP_INCLUDE_DIR_ZIP=#{Formula['libzip'].opt_prefix}/include",
      "-DLIBZIP_INCLUDE_DIR_ZIPCONF=#{Formula['libzip'].opt_prefix}/lib/libzip/include",
      "-DLIBZIP_LIBRARY=#{Formula['libzip'].opt_prefix}/lib/libzip.dylib",
      "-DLZ4_INCLUDE_DIR=#{Formula['lz4'].opt_prefix}/include",
      "-DLZ4_LIBRARY=#{Formula['lz4'].opt_prefix}/lib/liblz4.dylib",
      "-DMcrypt_INCLUDE_DIR=#{Formula['mcrypt'].opt_prefix}/include",
      "-DOCAMLC_EXECUTABLE=#{Formula['objective-caml'].opt_prefix}/bin/ocamlc",
      "-DOCAMLC_OPT_EXECUTABLE=#{Formula['objective-caml'].opt_prefix}/bin/ocamlc.opt",
      "-DONIGURUMA_INCLUDE_DIR=#{Formula['oniguruma'].opt_prefix}/include",
      "-DREADLINE_INCLUDE_DIR=#{Formula['readline'].opt_prefix}/include",
      "-DREADLINE_LIBRARY=#{Formula['readline'].opt_prefix}/lib/libreadline.dylib",
      "-DSYSTEM_PCRE_INCLUDE_DIR=#{Formula['pcre'].opt_prefix}/include",
      "-DSYSTEM_PCRE_LIBRARY=#{Formula['pcre'].opt_prefix}/lib/libpcre.dylib",
      "-DTBB_INCLUDE_DIRS=#{Formula['tbb'].opt_prefix}/include",
      "-DTEST_TBB_INCLUDE_DIR=#{Formula['tbb'].opt_prefix}/include",
    ]

    if build.with? 'gcc'
      gcc = Formula["gcc"]
      # Force compilation with gcc-4.9
      ENV['CC'] = "#{gcc.opt_prefix}/bin/gcc-#{gcc.version_suffix}"
      ENV['LD'] = "#{gcc.opt_prefix}/bin/gcc-#{gcc.version_suffix}"
      ENV['CXX'] = "#{gcc.opt_prefix}/bin/g++-#{gcc.version_suffix}"
      # Compiler complains about link compatibility with otherwise
      ENV.delete('CFLAGS')
      ENV.delete('CXXFLAGS')

      # Support GCC/LLVM stack-smashing protection: http://git.io/5Kzu3A
      # Preprocessor gcc performance regressions: http://git.io/4r7VCQ
      args << "-DCMAKE_C_FLAGS=-ftrack-macro-expansion=0 -fno-builtin-memcmp -pie -fPIC -fstack-protector-strong --param=ssp-buffer-size=4"
      args << "-DCMAKE_CXX_FLAGS=-ftrack-macro-expansion=0 -fno-builtin-memcmp -pie -fPIC -fstack-protector-strong --param=ssp-buffer-size=4"

      args << "-DCMAKE_CXX_COMPILER=#{gcc.opt_prefix}/bin/g++-#{gcc.version_suffix}"
      args << "-DCMAKE_C_COMPILER=#{gcc.opt_prefix}/bin/gcc-#{gcc.version_suffix}"
      args << "-DCMAKE_ASM_COMPILER=#{gcc.opt_prefix}/bin/gcc-#{gcc.version_suffix}"
      args << "-DBFD_LIB=#{Formula['binutilsfb'].opt_prefix}/lib/libbfd.a"
      args << "-DBOOST_INCLUDEDIR=#{Formula['boostfb'].opt_prefix}/include"
      args << "-DBOOST_LIBRARYDIR=#{Formula['boostfb'].opt_prefix}/lib"
      args << "-DCMAKE_INCLUDE_PATH=#{Formula['binutilsfb'].opt_prefix}/include"
      args << "-DLIBGLOG_INCLUDE_DIR=#{Formula['glogfb'].opt_prefix}/include"
      args << "-DLIBIBERTY_LIB=#{Formula['binutilsfb'].opt_prefix}/lib/x86_64/libiberty.a"
    else
      args << "-DBFD_LIB=#{Formula['binutilsfb'].opt_prefix}/lib/libbfd.a"
      args << "-DBOOST_INCLUDEDIR=#{Formula['boost'].opt_prefix}/include"
      args << "-DBOOST_LIBRARYDIR=#{Formula['boost'].opt_prefix}/lib"
      args << "-DCMAKE_INCLUDE_PATH=#{Formula['binutilsfb'].opt_prefix}/include"
      args << "-DLIBGLOG_INCLUDE_DIR=#{Formula['glog'].opt_prefix}/include"
      args << "-DLIBIBERTY_LIB=#{Formula['binutilsfb'].opt_prefix}/lib/x86_64/libiberty.a"
    end

    if build.with? 'cotire'
      args << "-DENABLE_COTIRE=ON"
    end

    if build.with? 'debug'
      args << '-DCMAKE_BUILD_TYPE=Debug'
    elsif build.with? 'release-debug'
      args << '-DCMAKE_BUILD_TYPE=RelWithDebInfo'
    elsif build.with? 'minsizerel'
      args << '-DCMAKE_BUILD_TYPE=MinSizeRel'
    end

    if build.with? 'mariadb'
      args << "-DMYSQL_INCLUDE_DIR=#{Formula['mariadb'].opt_prefix}/include/mysql"
      args << "-DMYSQL_LIB_DIR=#{Formula['mariadb'].opt_prefix}/lib"
    elsif build.with? 'percona-server'
      args << "-DMYSQL_INCLUDE_DIR=#{Formula['percona-server'].opt_prefix}/include/mysql"
      args << "-DMYSQL_LIB_DIR=#{Formula['percona-server'].opt_prefix}/lib"
    elsif build.without? 'system-mysql'
      args << "-DMYSQL_INCLUDE_DIR=#{Formula['mysql'].opt_prefix}/include/mysql"
      args << "-DMYSQL_LIB_DIR=#{Formula['mysql'].opt_prefix}/lib"
    end

    if build.with? 'libressl'
      args << "-DOPENSSL_SSL_LIBRARY=#{Formula['libressl'].opt_prefix}/lib/libssl.dylib"
      args << "-DOPENSSL_INCLUDE_DIR=#{Formula['libressl'].opt_prefix}/include"
      args << "-DOPENSSL_CRYPTO_LIBRARY=#{Formula['libressl'].opt_prefix}/lib/libcrypto.dylib"
    else
      args << "-DOPENSSL_SSL_LIBRARY=#{Formula['openssl'].opt_prefix}/lib/libssl.dylib"
      args << "-DOPENSSL_INCLUDE_DIR=#{Formula['openssl'].opt_prefix}/include"
      args << "-DOPENSSL_CRYPTO_LIBRARY=#{Formula['openssl'].opt_prefix}/lib/libcrypto.dylib"
    end

    #Custome packages
    rm_rf 'third-party'
    third_party_buildpath = buildpath/'third-party'
    third_party_buildpath.install resource('third-party')
    if build.stable? or build.devel?
      rm_rf 'third-party/folly/src'
      folly_buildpath = buildpath/'third-party/folly/src'
      folly_buildpath.install resource('folly')
      rm_rf 'third-party/thrift/src'
      thrift_buildpath = buildpath/'third-party/thrift/src'
      thrift_buildpath.install resource('thrift')
    end

    # Fix Traits.h std::* declarations conflict with libc++
    # https://github.com/facebook/folly/pull/81
    if build.without? 'gcc'
      inreplace third_party_buildpath/'folly/src/folly/Traits.h',
        "FOLLY_NAMESPACE_STD_BEGIN",
        "#if 0\nFOLLY_NAMESPACE_STD_BEGIN"
      inreplace third_party_buildpath/'folly/src/folly/Traits.h',
        "FOLLY_NAMESPACE_STD_END",
        "FOLLY_NAMESPACE_STD_END\n#else\n#include <utility>\n#include <string>\n#include <vector>\n#include <deque>\n#include <list>\n#include <set>\n#include <map>\n#include <memory>\n#endif\n"
    end

    src = prefix + "src"
    src.install Dir['*']

    ENV['HPHP_HOME'] = src

    cd src do
      system "cmake", *args
      system "make", "-j#{ENV.make_jobs}"
      system "make install"
    end

    install_config
  end

  def install_config
    ini_php = etc + "hhvm/php.ini"
    ini_php.write default_php_ini unless File.exists? ini_php
    ini_server = etc + "hhvm/server.ini"
    ini_server.write default_server_ini unless File.exists? ini_server
  end

  # https://gist.github.com/denji/1a2ff183a671efcabedf
  def default_php_ini
    <<-EOS.undent
      ; php options
      session.save_handler = files
      session.save_path = /tmp
      session.gc_maxlifetime = 1440

      ; hhvm specific
      hhvm.log.level = Warning
      hhvm.log.always_log_unhandled_exceptions = true
      hhvm.log.runtime_error_reporting_level = 8191
      hhvm.mysql.typed_results = false
    EOS
  end

  def default_server_ini
    <<-EOS.undent
      ; php options
      pid = #{var}/run/hhvm/pid

      ; hhvm specific
      hhvm.server.port = 9000
      hhvm.server.type = fastcgi
      hhvm.server.default_document = index.php
      hhvm.log.use_log_file = true
      hhvm.log.file = #{var}/log/hhvm/error.log
      hhvm.repo.central.path = #{var}/run/hhvm/hhvm.hhbc
    EOS
  end

  def caveats; <<-EOS.undent
    If you have XQuartz (X11) installed,
    to temporarily remove a symbolic link at '/usr/X11R6'
    in order to successfully install HHVM.
      $ sudo rm /usr/X11R6
      $ sudo ln -s /opt/X11 /usr/X11R6

    The php.ini file can be found in:
      #{etc}/hhvm/php.ini
    EOS
  end

  plist_options :manual => "hhvm"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>KeepAlive</key>
        <true/>
        <key>ProgramArguments</key>
        <array>
            <string>#{opt_bin}/hhvm</string>
            <string>-m daemon</string>
            <string>--config=#{etc}/hhvm/server.ini</string>
            <string>-c #{etc}/hhvm/php.ini</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>WorkingDirectory</key>
        <string>#{HOMEBREW_PREFIX}</string>
        <key>StandardErrorPath</key>
        <string>/dev/null</string>
        <key>StandardOutPath</key>
        <string>/dev/null</string>
      </dict>
    </plist>
    EOS
  end
end
