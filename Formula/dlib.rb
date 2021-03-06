class Dlib < Formula
  desc "C++ library for machine learning"
  homepage "http://dlib.net/"
  url "http://dlib.net/files/dlib-19.12.tar.bz2"
  sha256 "e6a9a20e8350b237e0bc0a8dbc6cb75714f8358e86e7964b5ad8b551f6eb8fef"
  head "https://github.com/davisking/dlib.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "917770d3e39e931557813077c9d952d012a792a24c6a659ad43452de5cac0113" => :high_sierra
    sha256 "05c38de8edf52c3e2ad60c5e0e176f0702c300c739abdf0baaf0c6570f0bca6f" => :sierra
    sha256 "3bd99bdd8253b71dc4cabd6c173e3839593227a1af810327f2b125ab39aa7b25" => :el_capitan
    sha256 "1b4dcd6ac865333a213fdc99493f297a75d0e57d66ca02ffc909f0c5730e8938" => :x86_64_linux
  end

  depends_on :macos => :el_capitan # needs thread-local storage

  depends_on "cmake" => :build
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "openblas" => :optional
  depends_on :x11 => :optional if OS.mac?
  depends_on "linuxbrew/xorg/xorg" => :optional unless OS.mac?

  needs :cxx11

  def install
    # Reduce memory usage below 4 GB for Circle CI.
    ENV["MAKEFLAGS"] = "-j16" if ENV["CIRCLECI"]

    ENV.cxx11

    args = std_cmake_args + %w[-DDLIB_USE_BLAS=ON -DDLIB_USE_LAPACK=ON]
    args << "-DDLIB_NO_GUI_SUPPORT=ON" if build.without? "x11"

    if build.with? "openblas"
      args << "-Dcblas_lib=#{Formula["openblas"].opt_lib}/libopenblas.dylib"
      args << "-Dlapack_lib=#{Formula["openblas"].opt_lib}/libopenblas.dylib"
    else
      args << "-Dcblas_lib=/usr/lib/libcblas.dylib"
      args << "-Dlapack_lib=/usr/lib/liblapack.dylib"
    end

    mkdir "dlib/build" do
      system "cmake", "..", *args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <dlib/logger.h>
      dlib::logger dlog("example");
      int main() {
        dlog.set_level(dlib::LALL);
        dlog << dlib::LINFO << "The answer is " << 42;
      }
    EOS
    system ENV.cxx, *("-pthread" unless OS.mac?), "-std=c++11", "test.cpp", "-o", "test", "-I#{include}",
                    "-L#{lib}", "-ldlib"
    assert_match /INFO.*example: The answer is 42/, shell_output("./test")
  end
end
