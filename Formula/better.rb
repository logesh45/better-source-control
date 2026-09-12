class Better < Formula
  desc "Agent-native source control for high-parallelism software work"
  homepage "https://github.com/logesh45/better-source-control"

  if OS.mac? && Hardware::CPU.arm?
    target = "aarch64-apple-darwin"
    sha = "07294d31c4af4366bad60d14d6b7509abb71973efcd8bfc28b5f824d91d7c7da"
  elsif OS.mac?
    target = "x86_64-apple-darwin"
    sha = "7b6b00f7a0ea5b2423ac0d132bfd3b2ab7ca55bb77736eff3ff802d680283635"
  elsif OS.linux? && Hardware::CPU.arm?
    target = "aarch64-unknown-linux-gnu"
    sha = "2f99031b82d22239d45fbfad4cd279c4d06680a63f92f60651c73e744f1db5c8"
  elsif OS.linux?
    target = "x86_64-unknown-linux-gnu"
    sha = "2218c97d89cc164f2d7804e3cd16d1a61d8d4814d444689a20dcfcedbc9bf85b"
  else
    odie "Unsupported platform for Better"
  end

  url "https://github.com/logesh45/better-source-control/releases/download/v0.3.5/better-0.3.5-#{target}.tar.gz"
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
