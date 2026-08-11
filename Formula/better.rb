class Better < Formula
  desc "Agent-native source control for high-parallelism software work"
  homepage "https://github.com/logesh45/better-source-control"

  if OS.mac? && Hardware::CPU.arm?
    target = "aarch64-apple-darwin"
    sha = "b472a7f6059d475a03fdc8ba90f442830a9e19959a754bb4c6efedb61820fbbe"
  elsif OS.mac?
    target = "x86_64-apple-darwin"
    sha = "4af933369ec68105c0aa357d84b4dbf1c7ce3c1a15a31438be56719ddcc3306b"
  elsif OS.linux? && Hardware::CPU.arm?
    target = "aarch64-unknown-linux-gnu"
    sha = "8c00477ee2aaff5528e824a0c1364ffde7ec8ce87f5b68f71214b3feee96f896"
  elsif OS.linux?
    target = "x86_64-unknown-linux-gnu"
    sha = "15bd1a348caf045971e22c1aaa125da5d1ba0045243370794db660a59cf469c5"
  else
    odie "Unsupported platform for Better"
  end

  url "https://github.com/logesh45/better-source-control/releases/download/v0.2.0/better-0.2.0-#{target}.tar.gz"
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
