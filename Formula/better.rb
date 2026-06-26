class Better < Formula
  desc "Agent-native source control for high-parallelism software work"
  homepage "https://github.com/logesh45/better-source-control"

  if OS.mac? && Hardware::CPU.arm?
    target = "aarch64-apple-darwin"
    sha = "cba99bc24c49f4abc3dace78f1f60857287ebe80f511680b48c3a9f50fa97a95"
  elsif OS.mac?
    target = "x86_64-apple-darwin"
    sha = "dc63f88d76b877f4eb6c691c0cc1ed5d802ac796316bc7f94ba81d4a5ff594a1"
  elsif OS.linux? && Hardware::CPU.arm?
    target = "aarch64-unknown-linux-gnu"
    sha = "5c733b7bf70969f78751f5cad6546b0428182793e8be0764cafc904d37dfccc5"
  elsif OS.linux?
    target = "x86_64-unknown-linux-gnu"
    sha = "14a93803363973a4b4f87512e5cd4834875a39054cce08361532d5ed8df32057"
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
