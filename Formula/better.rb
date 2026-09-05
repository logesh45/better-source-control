class Better < Formula
  desc "Agent-native source control for high-parallelism software work"
  homepage "https://github.com/logesh45/better-source-control"

  if OS.mac? && Hardware::CPU.arm?
    target = "aarch64-apple-darwin"
    sha = "682bb0ca65132e1f6078c27062bf2a6f879023fb2209fb7e08c53a122149770c"
  elsif OS.mac?
    target = "x86_64-apple-darwin"
    sha = "327b6b23b3ff53e1bf47297c2487b8ac5b63fb632c1bc14044b41a6b65d189db"
  elsif OS.linux? && Hardware::CPU.arm?
    target = "aarch64-unknown-linux-gnu"
    sha = "6bc28a631f087914f8c5fdacfa1e9f3a9dca1dd4e2066df753107d96935d61ba"
  elsif OS.linux?
    target = "x86_64-unknown-linux-gnu"
    sha = "3232cb19a24f88407d77e7e03f63a23d54404abcd36a4ec8cf7938c2dab5d78f"
  else
    odie "Unsupported platform for Better"
  end

  url "https://github.com/logesh45/better-source-control/releases/download/v0.3.4/better-0.3.4-#{target}.tar.gz"
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
