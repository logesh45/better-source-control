class Better < Formula
  desc "Agent-native source control for high-parallelism software work"
  homepage "https://github.com/logesh45/better-source-control"

  if OS.mac? && Hardware::CPU.arm?
    target = "aarch64-apple-darwin"
    sha = "67d312025535b741ba753bae63c5f49bc26073b1b5cc00f0013b91467a7aba96"
  elsif OS.mac?
    target = "x86_64-apple-darwin"
    sha = "910b7f5de74051c658ef475fb519baa6f80f9e40ea26c41060921cd6db52e6d3"
  elsif OS.linux? && Hardware::CPU.arm?
    target = "aarch64-unknown-linux-gnu"
    sha = "e093a76f170dc0e7c2fbee6f7a18a6c62e4ab89b58d37de7a128e0c67f9719e9"
  elsif OS.linux?
    target = "x86_64-unknown-linux-gnu"
    sha = "f7a7ff430c910cff46d075fbc4eaa2e7d34a5a12c6ff9f84a177fff861974c39"
  else
    odie "Unsupported platform for Better"
  end

  url "https://github.com/logesh45/better-source-control/releases/download/v0.1.1/better-0.1.1-#{target}.tar.gz"
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
