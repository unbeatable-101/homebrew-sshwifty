require "language/node"

class Sshwifty < Formula
  desc "Web SSH & Telnet"
  homepage "https://github.com/nirui/sshwifty"
  url "https://github.com/nirui/sshwifty.git",
      tag:      "0.4.2-beta-release",
      revision: "f3e550d4358f8ad3959c8cc2b77ce28b0d74c954"
  license "AGPL-3.0-or-later"

  livecheck do
    url :url
    regex(/(\d+(?:\.\d+)+-beta-release)/i)
  end

  depends_on "go" => :build
  depends_on "node" => :build

  def install
    # Patch config search path into Homebrew's etc
    inreplace "application/configuration/loader_file.go",
              "/etc/sshwifty.conf.json",
              "#{etc}/sshwifty/sshwifty.conf.json"

    # Build frontend (formerly using std_npm_args)
    system "npm", "install"
    system "npm", "run", "build"

    # Build Go backend
    system "go", "build", *std_go_args(ldflags: "-s -w"), "./cmd/sshwifty"

    # Install config
    (etc/"sshwifty").mkpath
    etc.install "sshwifty.conf.example.json" => "sshwifty/sshwifty.conf.json"
  end

  service do
    run opt_bin/"sshwifty"
    keep_alive true
    environment_variables SSHWIFTY_CONFIG: "#{etc}/sshwifty/sshwifty.conf.json"
    log_path var/"log/sshwifty.log"
    error_log_path var/"log/sshwifty.log"
  end

  def caveats
    <<~EOS
      A sample configuration file has been installed at:
        #{etc}/sshwifty/sshwifty.conf.json

      Edit this file to configure your installation.
      See https://github.com/nirui/sshwifty for documentation.
    EOS
  end

  test do
    port = free_port
    (testpath/"sshwifty.conf.json").write <<~EOS
      {
        "HostName": "localhost",
        "SharedKey": "Password",
        "Servers": [
          {
            "ListenInterface": "127.0.0.1",
            "ListenPort": #{port},
            "InitialTimeout": 3,
            "ReadTimeout": 60,
            "WriteTimeout": 60,
            "HeartbeatTimeout": 20,
            "ReadDelay": 10,
            "WriteDelay": 10,
            "ServerMessage": "It Works!"
          }
        ]
      }
    EOS

    fork do
      ENV["SSHWIFTY_CONFIG"] = testpath/"sshwifty.conf.json"
      exec bin/"sshwifty"
    end

    sleep 5
    assert_match "1", shell_output(
      "curl -s http://localhost:#{port} | grep -c \"require JavaScript to run\""
    )
  end
end
