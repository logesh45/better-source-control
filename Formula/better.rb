class Better < Formula
  desc "Agent-native source control for high-parallelism software work"
  homepage "https://github.com/logesh45/better-source-control"

  if OS.mac? && Hardware::CPU.arm?
    target = "aarch64-apple-darwin"
    sha = "a152aca4c0d0012ad68f64b0852c6bf3186abbb4ddb79dcf8a99ef017358c47f"
  elsif OS.mac?
    target = "x86_64-apple-darwin"
    sha = "ceb8955308425e7f7e4b4db69ef76b3a518cc569b5ed7d0cc2ae1c92725fdcdd"
  elsif OS.linux? && Hardware::CPU.arm?
    target = "aarch64-unknown-linux-gnu"
    sha = "d14b18d044cc5df8247eccac8feac6b7258b53640c350adf91936acfbe5a4d51"
  elsif OS.linux?
    target = "x86_64-unknown-linux-gnu"
    sha = "ef4ebaf99310af55f51e2184e512ed88ea02b6fa82e2c7822ebe4d4555b87e87"
  else
    odie "Unsupported platform for Better"
  end

  url "https://github.com/logesh45/better-source-control/releases/download/v0.3.2/better-0.3.2-#{target}.tar.gz"
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
