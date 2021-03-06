class Skaffold < Formula
  desc "Easy and Repeatable Kubernetes Development"
  homepage "https://github.com/GoogleContainerTools/skaffold"
  url "https://github.com/GoogleContainerTools/skaffold.git",
      :tag => "v0.6.0",
      :revision => "ced2917e5df941849460d8809a04ce1df1317455"
  head "https://github.com/GoogleContainerTools/skaffold.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "2318623dd2cc21b6674609e8ecf81890f63025a3651dd33fdc83a01a0f6068b7" => :high_sierra
    sha256 "20e3cc723f81b4520a2a6c3d37058c9e9411321b4a49880a5070fe596ade7c80" => :sierra
    sha256 "0a7e4a6ff56f542e55e55396823f65d35f2fe64d3ea40d11f5e7be6ceb3d5e90" => :el_capitan
    sha256 "725027bc9fd67da40fec33e766601d05109505ff5dcc8b49f6a61eaf25983ea1" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    dir = buildpath/"src/github.com/GoogleContainerTools/skaffold"
    dir.install buildpath.children - [buildpath/".brew_home"]
    cd dir do
      system "make"
      bin.install "out/skaffold"
      prefix.install_metafiles
    end
  end

  test do
    output = shell_output("#{bin}/skaffold version --output {{.GitTreeState}}")
    assert_match "clean", output
  end
end
