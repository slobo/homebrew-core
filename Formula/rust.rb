class Rust < Formula
  desc "Safe, concurrent, practical language"
  homepage "https://www.rust-lang.org/"

  stable do
    url "https://static.rust-lang.org/dist/rustc-1.26.0-src.tar.gz"
    sha256 "4fb09bc4e233b71dcbe08a37a3f38cabc32219745ec6a628b18a55a1232281dd"

    resource "cargo" do
      url "https://github.com/rust-lang/cargo.git",
          :tag => "0.26.0",
          :revision => "41480f5cc50863600e05aa17d13264c88070436a"
    end

    resource "racer" do
      url "https://github.com/racer-rust/racer/archive/2.0.12.tar.gz"
      sha256 "1fa063d90030c200d74efb25b8501bb9a5add7c2e25cbd4976adf7a73bf715cc"
    end
  end

  bottle do
    sha256 "b1ee221f371483a48eedefa452dac301e02009475331e72cf3a81d5ac4e6618c" => :high_sierra
    sha256 "b86cd54762e9bb5442c5a7fd34c47b6971c68160c915e7ea0aae7c4b79afae9f" => :sierra
    sha256 "bf9ca0637fcb3fa8079d7623db3cc160fb4d931b8a67027a98df947ca11f73c3" => :el_capitan
    sha256 "cc60e4013964ae748be6df0dd10c20ad3b8800811d5aa642788a551f2cbed67b" => :x86_64_linux
  end

  head do
    url "https://github.com/rust-lang/rust.git"

    resource "cargo" do
      url "https://github.com/rust-lang/cargo.git"
    end

    resource "racer" do
      url "https://github.com/racer-rust/racer.git"
    end
  end

  option "with-llvm", "Build with brewed LLVM. By default, Rust's LLVM will be used."

  depends_on "cmake" => :build
  depends_on "pkg-config"
  depends_on "llvm" => :optional
  depends_on "openssl"
  depends_on "libssh2"

  unless OS.mac?
    depends_on "binutils"
    depends_on "curl"
    depends_on "python@2"
    depends_on "zlib"
  end

  conflicts_with "cargo-completion", :because => "both install shell completion for cargo"

  # According to the official readme, GCC 4.7+ is required
  fails_with :gcc_4_0
  fails_with :gcc
  ("4.3".."4.6").each do |n|
    fails_with :gcc => n
  end

  resource "cargobootstrap" do
    if OS.mac?
      # From https://github.com/rust-lang/rust/blob/#{version}/src/stage0.txt
      url "https://static.rust-lang.org/dist/2018-03-29/cargo-0.26.0-x86_64-apple-darwin.tar.gz"
      sha256 "cab6adf58e9dea7ac217b1882312eff3487005cf32dcde099327669aac6e37de"
    elsif OS.linux?
      # From: https://github.com/rust-lang/rust/blob/#{version}/src/stage0.txt
      url "https://static.rust-lang.org/dist/2018-03-29/cargo-0.26.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "9ba227f2364f618dc9415dacf3a5dce17458e1cb9f6d4fe860416cb68db894e4"
    end
  end

  def install
    # Reduce memory usage below 4 GB for Circle CI.
    ENV["MAKEFLAGS"] = "-j1 -l2.0" if ENV["CIRCLECI"]

    # Fix build failure for compiler_builtins "error: invalid deployment target
    # for -stdlib=libc++ (requires OS X 10.7 or later)"
    ENV["MACOSX_DEPLOYMENT_TARGET"] = MacOS.version if OS.mac?

    # Prevent cargo from linking against a different library (like openssl@1.1)
    # from libssh2 and causing segfaults
    ENV["OPENSSL_INCLUDE_DIR"] = Formula["openssl"].opt_include
    ENV["OPENSSL_LIB_DIR"] = Formula["openssl"].opt_lib

    # Fix build failure for cmake v0.1.24 "error: internal compiler error:
    # src/librustc/ty/subst.rs:127: impossible case reached" on 10.11, and for
    # libgit2-sys-0.6.12 "fatal error: 'os/availability.h' file not found
    # #include <os/availability.h>" on 10.11 and "SecTrust.h:170:67: error:
    # expected ';' after top level declarator" among other errors on 10.12
    ENV["SDKROOT"] = MacOS.sdk_path if OS.mac?

    args = ["--prefix=#{prefix}"]
    args << "--disable-rpath" if build.head?
    args << "--llvm-root=#{Formula["llvm"].opt_prefix}" if build.with? "llvm"
    if build.head?
      args << "--release-channel=nightly"
    else
      args << "--release-channel=stable"
    end
    system "./configure", *args
    system "make"
    system "make", "install"

    resource("cargobootstrap").stage do
      system "./install.sh", "--prefix=#{buildpath}/cargobootstrap"
    end
    ENV.prepend_path "PATH", buildpath/"cargobootstrap/bin"

    resource("cargo").stage do
      ENV["RUSTC"] = bin/"rustc"
      system "cargo", "build", "--release", "--verbose"
      bin.install "target/release/cargo"
    end

    resource("racer").stage do
      ENV.prepend_path "PATH", bin
      cargo_home = buildpath/"cargo_home"
      cargo_home.mkpath
      ENV["CARGO_HOME"] = cargo_home
      system bin/"cargo", "build", "--release", "--verbose"
      (libexec/"bin").install "target/release/racer"
      (bin/"racer").write_env_script(libexec/"bin/racer", :RUST_SRC_PATH => pkgshare/"rust_src")
    end

    # Remove any binary files; as Homebrew will run ranlib on them and barf.
    rm_rf Dir["src/{llvm,llvm-emscripten,test,librustdoc,etc/snapshot.pyc}"]
    (pkgshare/"rust_src").install Dir["src/*"]

    rm_rf prefix/"lib/rustlib/uninstall.sh"
    rm_rf prefix/"lib/rustlib/install.log"
  end

  def post_install
    Dir["#{lib}/rustlib/**/*.dylib"].each do |dylib|
      chmod 0664, dylib
      MachO::Tools.change_dylib_id(dylib, "@rpath/#{File.basename(dylib)}")
      chmod 0444, dylib
    end
  end

  test do
    system "#{bin}/rustdoc", "-h"
    (testpath/"hello.rs").write <<~EOS
      fn main() {
        println!("Hello World!");
      }
    EOS
    system "#{bin}/rustc", "hello.rs"
    assert_equal "Hello World!\n", `./hello`
    system "#{bin}/cargo", "new", "hello_world", "--bin"
    assert_equal "Hello, world!",
                 (testpath/"hello_world").cd { `#{bin}/cargo run`.split("\n").last }
  end
end
