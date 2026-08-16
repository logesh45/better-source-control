class Better < Formula
  desc "Agent-native source control for high-parallelism software work"
  homepage "https://github.com/logesh45/better-source-control"

  if OS.mac? && Hardware::CPU.arm?
    target = "aarch64-apple-darwin"
    sha = "5c305b5cc6ca87030e44c23cda3490c1c4fbbd511c712ad0dcf15b653ea13328"
  elsif OS.mac?
    target = "x86_64-apple-darwin"
    sha = "edd9e59e89650ae7db747a8aa4386664f1384ac44ab2e3f154b666bde9d59d2c"
  elsif OS.linux? && Hardware::CPU.arm?
    target = "aarch64-unknown-linux-gnu"
    sha = "e75b4218609523478a45dbf7b8cc29a3db8b90404f92523c9bd42b7f8856f57b"
  elsif OS.linux?
    target = "x86_64-unknown-linux-gnu"
    sha = "c835e07c8b98a3b79f800f1b558592f36df2375770121301b6d47c6a5817ec16"
  else
    odie "Unsupported platform for Better"
  end

  url "https://github.com/logesh45/better-source-control/releases/download/v0.3.1/better-0.3.1-#{target}.tar.gz"
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
