class Better < Formula
  desc "Agent-native source control for high-parallelism software work"
  homepage "https://github.com/logesh45/better-source-control"

  if OS.mac? && Hardware::CPU.arm?
    target = "aarch64-apple-darwin"
    sha = "44549363055e25fbf7451860879f90e423b2ebf2e14ae7b12db7e9e4cbdd0d42"
  elsif OS.mac?
    target = "x86_64-apple-darwin"
    sha = "59e01d0fe3f258c5b8ce4a7aba56fb95e361a3518b834b9fc9827ff27ec4ecc8"
  elsif OS.linux? && Hardware::CPU.arm?
    target = "aarch64-unknown-linux-gnu"
    sha = "b79bba40072bd783ab9a60eb28d931f957b3894806b52e08f2449432fd99c83e"
  elsif OS.linux?
    target = "x86_64-unknown-linux-gnu"
    sha = "b2a1f829a31c3242191983b80245fb09eb57931c5864996332cafd0a15c6008d"
  else
    odie "Unsupported platform for Better"
  end

  url "https://github.com/logesh45/better-source-control/releases/download/v0.4.0/better-0.4.0-#{target}.tar.gz"
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
