class Nnn < Formula
  desc "Free, fast, friendly file browser"
  homepage "https://github.com/jarun/nnn"
  url "https://github.com/jarun/nnn/archive/v1.8.tar.gz"
  sha256 "65c364a9797178e40ec7ec653b2cfa8e211e556b75250bf72eb5eea57f5e0cdc"

  bottle do
    cellar :any
    sha256 "90682082109f2ad444092cdb113c648a057de6f5ce14063db4ce3ff0f9365807" => :high_sierra
    sha256 "2ddd0a667b68025c2dca006cfed1e67ef84df8f6be6521d3640f070ffb7e9619" => :sierra
    sha256 "f8ba6cdc1fa14c0e2cfd7539aafe2d15c7d03e74fd070d7bcb024e30806900f8" => :el_capitan
    sha256 "ca26ad3b11ddc463a736e97f1f338057393a62a32119a04821068adbd83cc9cd" => :x86_64_linux
  end

  depends_on "readline"
  depends_on "ncurses" unless OS.mac?

  def install
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    # Test fails on CI: Input/output error @ io_fread - /dev/pts/0
    # Fixing it involves pty/ruby voodoo, which is not worth spending time on
    return if ENV["CIRCLECI"] || ENV["TRAVIS"]
    # Testing this curses app requires a pty
    require "pty"
    PTY.spawn(bin/"nnn") do |r, w, _pid|
      w.write "q"
      assert_match testpath.realpath.to_s, r.read
    end
  end
end
