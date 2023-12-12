# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Sshwifty < Formula
  desc "Web SSH & Telnet (WebSSH & WebTelnet client) 🔮"
  homepage "https://sshwifty-demo.nirui.org"
  url "https://github.com/nirui/sshwifty/archive/refs/tags/0.3.4-beta-release-prebuild.tar.gz"
  sha256 "88a0bf816a1533278c2323da0c208d1aec1554900b212256e029631013a1f6fa"
  license "AGPL-3.0+"

  depends_on "go" => :build
  depends_on "npm" => :build
  depends_on "node" => :build

  def install
  inreplace "application/configuration/loader_file.go", "/etc/sshwifty.conf.json", "#{etc}/sshwifty.conf.json"
  system "npm", "install"
  system "npm", "run", "build"
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test sshwifty`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end
