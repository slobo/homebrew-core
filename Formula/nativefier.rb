require "language/node"

class Nativefier < Formula
  desc "Wrap web apps natively"
  homepage "https://github.com/jiahaog/nativefier"
  url "https://registry.npmjs.org/nativefier/-/nativefier-7.6.3.tgz"
  sha256 "8af3505840e2b6562adbb6fbcc5497d1f2ae506f5560c988a2c1b5685fa47098"

  bottle do
    cellar :any_skip_relocation
    sha256 "adf3d341d9e7cfd79ed3ba6b0e6a7149f07edb73b66ecfa6452a9b0ba26c906c" => :high_sierra
    sha256 "b48e332714a4598c2a4b6380545ec520538fcfa65878ec3ab2cceae4ee931d4d" => :sierra
    sha256 "0fb9d888ac4baa5f60fb70c9e0b75e23dc104b904cee7a457e09edb5dea7c4e3" => :el_capitan
    sha256 "494d9bba288ffe8f558bef3664a5a9e19e4cf51f52b0c6f3f30d1fa7ee264296" => :x86_64_linux
  end

  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    system bin/"nativefier", "--version"
  end
end
