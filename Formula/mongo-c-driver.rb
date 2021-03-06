class MongoCDriver < Formula
  desc "C driver for MongoDB"
  homepage "https://github.com/mongodb/mongo-c-driver"
  url "https://github.com/mongodb/mongo-c-driver/releases/download/1.10.0/mongo-c-driver-1.10.0.tar.gz"
  sha256 "65bec96b37333046679252d607a6bde7629854356f9a314666392a1d809abf12"

  bottle do
    cellar :any
    sha256 "561298b74eedc7b412150dc4c35f47d497c5006488592810f14e17063bafe83f" => :high_sierra
    sha256 "3684ba8626dd4d2c672515de3a6fb8c99d56292bf57bbe558405fa6173cec901" => :sierra
    sha256 "487a1fac617a0399fec27925b51b48283f4a9abd9fe92de430e1fa0892fe474c" => :el_capitan
    sha256 "e0cc98a7ccd68bd0d8203ed1269a4d64880cfce3d41c93dc5cf05918311a9fa6" => :x86_64_linux
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "sphinx-doc" => :build
  unless OS.mac?
    depends_on "openssl"
    depends_on "zlib"
  end

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
    (pkgshare/"libbson").install "src/libbson/examples"
    (pkgshare/"libmongoc").install "src/libmongoc/examples"
  end

  test do
    system ENV.cc, "-o", "test", pkgshare/"libbson/examples/json-to-bson.c",
      "-I#{include}/libbson-1.0", "-L#{lib}", "-lbson-1.0"
    (testpath/"test.json").write('{"name": "test"}')
    assert_match "\u0000test\u0000", shell_output("./test test.json")

    system ENV.cc, "-o", "test", pkgshare/"libmongoc/examples/mongoc-ping.c",
      "-I#{include}/libmongoc-1.0", "-I#{include}/libbson-1.0",
      "-L#{lib}", "-lmongoc-1.0", "-lbson-1.0"
    assert_match "No suitable servers", shell_output("./test mongodb://0.0.0.0 2>&1", 3)
  end
end
