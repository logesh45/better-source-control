class Better < Formula
  desc "Agent-native source control for high-parallelism software work"
  homepage "https://github.com/logesh45/better-source-control"

  if OS.mac? && Hardware::CPU.arm?
    target = "aarch64-apple-darwin"
    sha = "69cdd69dd714da6b77a04ce7c251c5bbf3b90f5d6ba8ea3bfff5524aae6e3f37"
  elsif OS.mac?
    target = "x86_64-apple-darwin"
    sha = "f62669a7a6e31391a2b8a34be5ff2dc9b9386d421a5007a3d3794a6b3b09c5a6"
  elsif OS.linux? && Hardware::CPU.arm?
    target = "aarch64-unknown-linux-gnu"
    sha = "fe52e9472761070507c594bcb012304bce222bc4a6607c281a05474ef9d2f5c9"
  elsif OS.linux?
    target = "x86_64-unknown-linux-gnu"
    sha = "b8d1c825118f43329d4598fb96e3c7d8b8e679a6de2625bd199fe9125c6b183c"
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
