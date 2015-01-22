class Folly < Formula
  homepage "https://github.com/facebook/folly#readme"
  url "https://github.com/facebook/folly.git", :revision => "ba2a9e1b552f65cbc615fe4ec051e9624ca4e3c2"
  version "22:0"
  # head "https://github.com/facebook/folly.git"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "scons" => :build

  depends_on "glog"
  depends_on "gflags"
  depends_on "boost"
  depends_on "libevent"
  depends_on "double-conversion"

  option "with-tests"

  resource("gtest") do
    url "https://googletest.googlecode.com/files/gtest-1.7.0.zip"
    sha1 "f85f6d2481e2c6c4a18539e391aa4ea8ab0394af"
  end

  def install
    cd "folly" do
      system "autoreconf", "-i"
      system "./configure", "--disable-dependency-tracking",
                            "--disable-silent-rules",
                            "--prefix=#{prefix}"
      if build.with? "tests"
        # @TODO broken for poorly-understood reasons
        # stage gtest
        system "make", "check"
      end
      system "make", "install"
    end
  end
end
