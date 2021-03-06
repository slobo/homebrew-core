class Fn < Formula
  desc "Command-line tool for the fn project"
  homepage "https://fnproject.github.io"
  url "https://github.com/fnproject/cli/archive/0.4.98.tar.gz"
  sha256 "1d76649b3be7c12756c8399ebf927d2e51a00bda2dbe0a30b79573192ec10d36"

  bottle do
    cellar :any_skip_relocation
    sha256 "a5cd3d928e109c169a45890347feab5b652759e680e628c6dd30bea9d6f9b6dd" => :high_sierra
    sha256 "63172edc1c76fa66965e33dfb8b803a5dcee348ee4cf7f2c49414a6c4d8f7b37" => :sierra
    sha256 "f20185a8074eedec776035275840372c56c19d35a40c8dd8c3a9195b03efdcee" => :el_capitan
    sha256 "c38c788f816755a1f0e4cabdb27e6d0e4bf22af64170911b75d412631487f26e" => :x86_64_linux
  end

  depends_on "dep" => :build
  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    dir = buildpath/"src/github.com/fnproject/cli"
    dir.install Dir["*"]
    cd dir do
      system "dep", "ensure"
      system "go", "build", "-o", "#{bin}/fn"
      prefix.install_metafiles
    end
  end

  test do
    require "socket"
    assert_match version.to_s, shell_output("#{bin}/fn --version")
    system "#{bin}/fn", "init", "--runtime", "go", "--name", "myfunc"
    assert_predicate testpath/"func.go", :exist?, "expected file func.go doesn't exist"
    assert_predicate testpath/"func.yaml", :exist?, "expected file func.yaml doesn't exist"
    server = TCPServer.new("localhost", 0)
    port = server.addr[1]
    pid = fork do
      loop do
        socket = server.accept
        response = '{"route": {"path": "/myfunc", "image": "fnproject/myfunc"} }'
        socket.print "HTTP/1.1 200 OK\r\n" \
                    "Content-Length: #{response.bytesize}\r\n" \
                    "Connection: close\r\n"
        socket.print "\r\n"
        socket.print response
        socket.close
      end
    end
    begin
      ENV["FN_API_URL"] = "http://localhost:#{port}"
      ENV["FN_REGISTRY"] = "fnproject"
      expected = "/myfunc created with fnproject/myfunc"
      # Test fails in circle ci with:
      # ERROR: read tcp 127.0.0.1:47210->127.0.0.1:43523: read: connection reset by peer
      unless ENV["CIRCLECI"]
        output = shell_output("#{bin}/fn routes create myapp myfunc --image fnproject/myfunc:0.0.1")
        assert_match expected, output.chomp
      end
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end
end
