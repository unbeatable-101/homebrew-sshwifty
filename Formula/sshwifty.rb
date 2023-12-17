class Sshwifty < Formula
  desc "Web SSH & Telnet"
  homepage "https://github.com/nirui/sshwifty/archive/refs/tags/0.3.4-beta-release.tar.gz"
  url "https://github.com/nirui/sshwifty.git"
  version "0.3.4-beta-release"
  sha256 "446bbeb81da5a0c15a3f24f28a1f335bbff40112d1c6eacd65eafabe2f9f74e4"
  license "AGPL-3.0-or-later"

  depends_on "go" => :build
  depends_on "node" => :build
  depends_on "npm" => :build

  def install
    inreplace "application/configuration/loader_file.go", "/etc/sshwifty.conf.json", "#{etc}/sshwifty.conf.json"
    system "npm", "install"
    system "npm", "run", "build"
    bin.install "sshwifty"
    etc.install "sshwifty.conf.example.json" => "sshwift.conf.json"
  end
  service do
    run opt_bin/"sshwifty"
    keep_alive true
    environment_variables SSHWIFTY_CONFIG: "#{etc}/sshwifty/sshwifty.conf.json"
    log_path var/"log/sshwifty.log"
    error_log_path var/"log/sshwifty.log"
  end
end
