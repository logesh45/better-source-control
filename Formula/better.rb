class Better < Formula
  desc "Agent-native source control for high-parallelism software work"
  homepage "https://github.com/logesh45/better-source-control"

  if OS.mac? && Hardware::CPU.arm?
    target = "aarch64-apple-darwin"
    sha = "96da226c85e98b5ccc4ab792da7f29cdff2cd978c45346485717d6da7d60b819"
  elsif OS.mac?
    target = "x86_64-apple-darwin"
    sha = "48f45f40349f74393ddbbe9aad6a034df62d7dc35df859854af2880a00e0a9b5"
  elsif OS.linux? && Hardware::CPU.arm?
    target = "aarch64-unknown-linux-gnu"
    sha = "dc8d1fc442a5e13cc3098509d331b8de0bb00c0fbaae63d98e16cfc34eea3bdd"
  elsif OS.linux?
    target = "x86_64-unknown-linux-gnu"
    sha = "8a8f7c911ef27b69129ddcdbf2028b44dbe913d50b19760ed3477cae969e0266"
  else
    odie "Unsupported platform for Better"
  end

  url "https://github.com/logesh45/better-source-control/releases/download/v0.1.0-rc.3/better-0.1.0-rc.3-#{target}.tar.gz"
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
