class Packmol < Formula
  desc "Packing optimization for molecular dynamics simulations"
  homepage "https://www.ime.unicamp.br/~martinez/packmol/"
  url "https://github.com/leandromartinez98/packmol/archive/18.104.tar.gz"
  sha256 "a87cb076f82a5ee94206b7534cd790c243fadd2d64bca5b12aa88493d5024f87"
  revision 1
  head "https://github.com/leandromartinez98/packmol.git"

  bottle do
    sha256 "eba9f1cf46eb9313083122b14bfafa975ebc643e0b5ac4600b8067f0e1dc4798" => :x86_64_linux
  end

  depends_on "gcc" # for gfortran

  resource "examples" do
    url "https://www.ime.unicamp.br/~martinez/packmol/examples/examples.tar.gz"
    sha256 "97ae64bf5833827320a8ab4ac39ce56138889f320c7782a64cd00cdfea1cf422"
  end

  def install
    system "./configure"
    system "make"
    bin.install("packmol")
    pkgshare.install "solvate.tcl"
    (pkgshare/"examples").install resource("examples")
  end

  test do
    cp Dir["#{pkgshare}/examples/*"], testpath
    system bin/"packmol < interface.inp"
  end
end
