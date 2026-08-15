class Better < Formula
  desc "Agent-native source control for high-parallelism software work"
  homepage "https://github.com/logesh45/better-source-control"

  if OS.mac? && Hardware::CPU.arm?
    target = "aarch64-apple-darwin"
    sha = "63addcb0823bfd0238ba0e90b6101538cd46bcb934c798827f6c7e54e26821fb"
  elsif OS.mac?
    target = "x86_64-apple-darwin"
    sha = "8b2f17c8991fc9f4b94a8a94fca8d15062155d679c2b4e68a71079abeeeccefd"
  elsif OS.linux? && Hardware::CPU.arm?
    target = "aarch64-unknown-linux-gnu"
    sha = "644dd040bbcb5bebc72d81490f90ef196d3a8cc305f54d9ecacf59e5de252cde"
  elsif OS.linux?
    target = "x86_64-unknown-linux-gnu"
    sha = "2cca2260fa54bf7bc0c9fc45b2450675043112ebd3f81082d559e3adb2bb6ab4"
  else
    odie "Unsupported platform for Better"
  end

  url "https://github.com/logesh45/better-source-control/releases/download/v0.3.0/better-0.3.0-#{target}.tar.gz"
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
