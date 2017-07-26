# OCaml does not preserve binary compatibility across compiler releases,
# so when updating it you should ensure that all dependent packages are
# also updated by incrementing their revisions.
#
# Specific packages to pay attention to include:
# - camlp4
# - opam
#
# Applications that really shouldn't break on a compiler update are:
# - mldonkey
# - coq
# - coccinelle
# - unison
class Ocaml < Formula
  desc "General purpose programming language in the ML family"
  homepage "https://ocaml.org/"
  url "https://caml.inria.fr/pub/distrib/ocaml-4.05/ocaml-4.05.0.tar.xz"
  sha256 "04a527ba14b4d7d1b2ea7b2ae21aefecfa8d304399db94f35a96df1459e02ef9"
  head "https://caml.inria.fr/svn/ocaml/trunk", :using => :svn

  pour_bottle? do
    # The ocaml compilers embed prefix information in weird ways that the default
    # brew detection doesn't find, and so needs to be explicitly blacklisted.
    default_prefix = OS.linux? ? "/home/linuxbrew/.linuxbrew" : "/usr/local"
    reason "The bottle needs to be installed into #{default_prefix}."
    satisfy { HOMEBREW_PREFIX.to_s == default_prefix }
  end

  bottle do
    cellar :any_skip_relocation
    sha256 "ff80b1cdf978f332ba63a6d7503c4eb68866809750298fb5854caf56f43771ff" => :x86_64_linux
  end

  option "with-x11", "Install with the Graphics module"
  option "with-flambda", "Install with flambda support"

  depends_on :x11 => :optional

  def install
    ENV.deparallelize # Builds are not parallel-safe, esp. with many cores

    # the ./configure in this package is NOT a GNU autoconf script!
    args = ["-prefix", HOMEBREW_PREFIX.to_s, "-with-debug-runtime", "-mandir", man]
    args << "-no-graph" if build.without? "x11"
    args << "-flambda" if build.with? "flambda"
    system "./configure", *args

    system "make", "world.opt"
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    output = shell_output("echo 'let x = 1 ;;' | #{bin}/ocaml 2>&1")
    assert_match "val x : int = 1", output
    assert_match HOMEBREW_PREFIX.to_s, shell_output("#{bin}/ocamlc -where")
  end
end
