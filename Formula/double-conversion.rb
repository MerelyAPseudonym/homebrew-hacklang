class DoubleConversion < Formula
  homepage "https://github.com/floitsch/double-conversion#readme"
  url "https://github.com/floitsch/double-conversion/archive/v1.1.5.tar.gz"
  sha1 "96a8aba1b4ce7d4a7a3c123be26c379c2fed1def"

  # @TODO should prefer CMake? (see https://github.com/floitsch/double-conversion#readme)
  depends_on "scons" => :build

  option "with-tests", "Run the included tests during the build"

  def install

    system "make"
    if build.with? "tests"
      system "make", "test"
    end
    system "scons", "prefix=#{prefix}", "install"

    # Q.v. https://github.com/facebook/folly/blob/ba2a9e1b552f65cbc615fe4ec051e9624ca4e3c2/folly/bootstrap-osx-homebrew.sh#L18-L26
    (include/"double-conversion").install Dir["src/*.h"]
  end
end
