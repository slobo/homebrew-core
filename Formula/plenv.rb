class Plenv < Formula
  desc "Perl binary manager"
  homepage "https://github.com/tokuhirom/plenv"
  url "https://github.com/tokuhirom/plenv/archive/b2ea2fd.tar.gz"
  sha256 "23d30803254cc59dace5c874f4e56ab976b2e1075098ff74151599af9a926c49"
  head "https://github.com/tokuhirom/plenv.git"

  bottle :unneeded

  def install
    prefix.install "bin", "plenv.d", "completions", "libexec"

    # Run rehash after installing.
    system "#{bin}/plenv", "rehash"
  end

  def caveats; <<~EOS
    To enable shims add to your profile:
      if which plenv > /dev/null; then eval "$(plenv init -)"; fi
    With zsh, add to your .zshrc:
      if which plenv > /dev/null; then eval "$(plenv init - zsh)"; fi
    With fish, add to your config.fish
      if plenv > /dev/null; plenv init - | source ; end
    EOS
  end

  test do
    system "#{bin}/plenv", "--version"
  end
end
