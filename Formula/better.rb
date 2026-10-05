class Better < Formula
  desc "Agent-native source control for high-parallelism software work"
  homepage "https://github.com/logesh45/better-source-control"

  if OS.mac? && Hardware::CPU.arm?
    target = "aarch64-apple-darwin"
    sha = "65b52d1317e85270067eca64c1c0c6584cdb7e28650e208c897a4d045cea563f"
  elsif OS.mac?
    target = "x86_64-apple-darwin"
    sha = "5954afa4e1a9591510cc94e241cbd34736d828299a72ddbf45170e9507b4ae6e"
  elsif OS.linux? && Hardware::CPU.arm?
    target = "aarch64-unknown-linux-gnu"
    sha = "b9394b694ad550f1a1124dfda18581e33e1de3af0bef1344e8fb10ca3927ad58"
  elsif OS.linux?
    target = "x86_64-unknown-linux-gnu"
    sha = "45856bf1ff1a3f6b55574d5a90654844c7c4d77860f0c9e1dfc6a84669cf2fc8"
  else
    odie "Unsupported platform for Better"
  end

  url "https://github.com/logesh45/better-source-control/releases/download/v0.5.0/better-0.5.0-#{target}.tar.gz"
  sha256 sha
  license any_of: ["MIT", "Apache-2.0"]

  def install
    bin.install "bin/better"
    bin.install "bin/better-remote"
  end

  test do
    system "#{bin}/better", "--version"
  end
end
