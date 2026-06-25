class Better < Formula
  desc "Agent-native source control for high-parallelism software work"
  homepage "https://github.com/logesh45/better-source-control"

  if OS.mac? && Hardware::CPU.arm?
    target = "aarch64-apple-darwin"
    sha = "30d0c8c74371d07e7e0a9c7831c8971f02e6e7e7ef41d0784177aa096061f249"
  elsif OS.mac?
    target = "x86_64-apple-darwin"
    sha = "769ac188d5bebc119f0b457924f219e4641a967b8a4afb8ff3ab5e98e36280a2"
  elsif OS.linux? && Hardware::CPU.arm?
    target = "aarch64-unknown-linux-gnu"
    sha = "4d7fdd827aa549160a6ae4ba99ccae0a7474b7663a8510ffedde3eb0d2aa5129"
  elsif OS.linux?
    target = "x86_64-unknown-linux-gnu"
    sha = "de215655a41d2bcff78c14b123d24d05b4b77df969bb686c1b897f8133c583eb"
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
