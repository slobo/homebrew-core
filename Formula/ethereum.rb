class Ethereum < Formula
  desc "Official Go implementation of the Ethereum protocol"
  homepage "https://ethereum.github.io/go-ethereum/"
  url "https://github.com/ethereum/go-ethereum/archive/v1.8.8.tar.gz"
  sha256 "3072ff8090c948648d365f6f2c0144e10f2e74be1fee85046d952d089c5765cb"
  head "https://github.com/ethereum/go-ethereum.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "847127f67fdf3bc3d5dcf2fd4dcbbf1d8ad5a2fb1a01c8c0a29d06b28f6bc7a0" => :high_sierra
    sha256 "871085fd22d545378815b4ffa1eb270a160f97bef3e76b82c1204280be011acb" => :sierra
    sha256 "7b64e2e02c0d2622875befe881fc739596af08b835ef6c58999450a66ad463d3" => :el_capitan
    sha256 "38c859c2b28eb942d61651e50aa6e01209804e85f8a4577e3efbcb752034fa10" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    system "make", "all"
    bin.install Dir["build/bin/*"]
  end

  test do
    (testpath/"genesis.json").write <<~EOS
      {
        "config": {
          "homesteadBlock": 10
        },
        "nonce": "0",
        "difficulty": "0x20000",
        "mixhash": "0x00000000000000000000000000000000000000647572616c65787365646c6578",
        "coinbase": "0x0000000000000000000000000000000000000000",
        "timestamp": "0x00",
        "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
        "extraData": "0x",
        "gasLimit": "0x2FEFD8",
        "alloc": {}
      }
    EOS
    system "#{bin}/geth", "--datadir", "testchain", "init", "genesis.json"
    assert_predicate testpath/"testchain/geth/chaindata/000001.log", :exist?,
                     "Failed to create log file"
  end
end
