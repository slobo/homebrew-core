class Tippecanoe < Formula
  desc "Build vector tilesets from collections of GeoJSON features"
  homepage "https://github.com/mapbox/tippecanoe"
  url "https://github.com/mapbox/tippecanoe/archive/1.28.0.tar.gz"
  sha256 "2191c3088bb3bca070b78bc1e5a02363194f6a8b3d6730a7c06e39789cbe730e"

  bottle do
    cellar :any_skip_relocation
    sha256 "605efcc7125b53484e3abf8a9e6a224866bb762506bccb62ec2746fc995854f4" => :high_sierra
    sha256 "829ea51ac673a4792076623a59d579c1b686112c409f2c72af870e5b0e50a450" => :sierra
    sha256 "b97317adeaebc59593f76cdcd0ba6a43bb0fe3a31f0e40465b47a9332edd563d" => :el_capitan
    sha256 "7a5afebb6ded04e8cb782ab207936cf5e32c7ec5ee7e82303f7289ccbc04b526" => :x86_64_linux
  end

  unless OS.mac?
    depends_on "sqlite"
    depends_on "zlib"
  end

  def install
    system "make"
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    (testpath/"test.json").write <<~EOS
      {"type":"Feature","properties":{},"geometry":{"type":"Point","coordinates":[0,0]}}
    EOS
    safe_system "#{bin}/tippecanoe", "-o", "test.mbtiles", "test.json"
    assert_predicate testpath/"test.mbtiles", :exist?, "tippecanoe generated no output!"
  end
end
