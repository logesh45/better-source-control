class Better < Formula
  desc "Agent-native source control for high-parallelism software work"
  homepage "https://github.com/logesh45/better-source-control"

  if OS.mac? && Hardware::CPU.arm?
    target = "aarch64-apple-darwin"
    sha = "7ba8c511f33bf60429ec83ae87ae15a252ab85feadfb411f34a1dbf7b07ff978"
  elsif OS.mac?
    target = "x86_64-apple-darwin"
    sha = "3e64ac067beca9d4f79d1935990e0e836c5d6c486efec72d5cc6a9d798eeefee"
  elsif OS.linux? && Hardware::CPU.arm?
    target = "aarch64-unknown-linux-gnu"
    sha = "be3a702d4d5f77aff35846d2db9397fdd34b53d124402ac2e9d4141d23858d60"
  elsif OS.linux?
    target = "x86_64-unknown-linux-gnu"
    sha = "f7bd760e48490067c28c1ee0d523be32a2d225e40df86d1e1a775c75982e88e4"
  else
    odie "Unsupported platform for Better"
  end

  url "https://github.com/logesh45/better-source-control/releases/download/v0.1.0-rc.2/better-0.1.0-rc.2-#{target}.tar.gz"
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
