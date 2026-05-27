class Better < Formula
  desc "Agent-native source control for high-parallelism software work"
  homepage "https://github.com/logesh45/better-source-control"

  if OS.mac? && Hardware::CPU.arm?
    target = "aarch64-apple-darwin"
    sha = "5141d7b958228b0e6dcaf1fd54d3ee255b4e91102a9f54d0c597dc90c211925d"
  elsif OS.mac?
    target = "x86_64-apple-darwin"
    sha = "9dd2d4b0ac3f751c5bea05eb40f946afd0a370a49eebc244f11dafb6f9c166cb"
  elsif OS.linux? && Hardware::CPU.arm?
    target = "aarch64-unknown-linux-gnu"
    sha = "f98ff99eec62227670cf12a3dedd32f62d7cbea2be32269d54ecf16089155cbd"
  elsif OS.linux?
    target = "x86_64-unknown-linux-gnu"
    sha = "64336fa827498e57b132de7554f03ddd6b017af043c85fcd41782a96943abc5a"
  else
    odie "Unsupported platform for Better"
  end

  url "https://github.com/logesh45/better-source-control/releases/download/v0.1.0-rc.1/better-0.1.0-rc.1-#{target}.tar.gz"
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
