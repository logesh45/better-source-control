class Better < Formula
  desc "Agent-native source control for high-parallelism software work"
  homepage "https://github.com/logesh45/better-source-control"

  if OS.mac? && Hardware::CPU.arm?
    target = "aarch64-apple-darwin"
    sha = "c38393a982d853646be212d8f0989a65cc7d378aa023f9f4a74b5c2037187cba"
  elsif OS.mac?
    target = "x86_64-apple-darwin"
    sha = "69c3904166c9a7e1eda2433ac3acc2c2b9ff805c546a10c3b55c9981ef74fcfe"
  elsif OS.linux? && Hardware::CPU.arm?
    target = "aarch64-unknown-linux-gnu"
    sha = "7ff86bcf5e0d7b26f8c246f16b870fa8800d630b7a4e0c7e2cd7f0d6f4f4fd94"
  elsif OS.linux?
    target = "x86_64-unknown-linux-gnu"
    sha = "839b241360ff49781ebb0c862e3afe9e3ad00a3e47d922e166f0c9dd38c280be"
  else
    odie "Unsupported platform for Better"
  end

  url "https://github.com/logesh45/better-source-control/releases/download/v0.1.2/better-0.1.2-#{target}.tar.gz"
  sha256 sha
  license "MIT"

  def install
    bin.install "bin/better"
    bin.install "bin/better-remote"
  end

  test do
    system "#{bin}/better", "--version"
  end
end
