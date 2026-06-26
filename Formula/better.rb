class Better < Formula
  desc "Agent-native source control for high-parallelism software work"
  homepage "https://github.com/logesh45/better-source-control"

  if OS.mac? && Hardware::CPU.arm?
    target = "aarch64-apple-darwin"
    sha = "ff9430831ebe77936999f47b95e11395558afb84c7613a0192db4ac28fdf7aa7"
  elsif OS.mac?
    target = "x86_64-apple-darwin"
    sha = "f5c94edd9396d7ceb2be6ed85e673077f1041584ad246054babd2e1cc470e1f6"
  elsif OS.linux? && Hardware::CPU.arm?
    target = "aarch64-unknown-linux-gnu"
    sha = "51b9f611e64a583a00692e899d9a7e5e8f717752af41076262cc9f13b7cbd421"
  elsif OS.linux?
    target = "x86_64-unknown-linux-gnu"
    sha = "2c2e905f0ce81186f4a9f82298a28c582c8428f00c28f35a4b10ea15fcd951ba"
  else
    odie "Unsupported platform for Better"
  end

  url "https://github.com/logesh45/better-source-control/releases/download/v0.1.0/better-0.1.0-#{target}.tar.gz"
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
