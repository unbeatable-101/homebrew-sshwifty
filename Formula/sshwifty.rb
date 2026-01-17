require "language/node"
class Sshwifty < Formula
  desc "Web SSH & Telnet"
  homepage "https://github.com/nirui/sshwifty"
  url "https://github.com/nirui/sshwifty.git",
    tag:      "0.4.3-beta-release",
    revision: "5206d9964127fc65d994cd124a84a09aa0fe893c"
  license "AGPL-3.0-or-later"

  livecheck do
    skip "Beta-only upstream; livecheck disabled for tap"
  end


  depends_on "go" => :build
  depends_on "node" => :build

  def install
    inreplace "application/configuration/loader_file.go",
              "/etc/sshwifty.conf.json",
              "#{etc}/sshwifty/sshwifty.conf.json"

    system "npm", "ci"
    system "npm", "run", "build"

    system "go", "build",
           "-ldflags",
           "-s -w -X github.com/nirui/sshwifty/application.version=#{version}"

    bin.install "sshwifty"

    (etc/"sshwifty").install "sshwifty.conf.example.json" => "sshwifty.conf.json"
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
      Please edit this file in order to properly configure your installation, see https://github.com/nirui/sshwifty for more info on the settings available.
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
      system bin/"sshwifty"
    end
    sleep 5
    assert_match "1", shell_output("curl -s http://localhost:#{port}|grep -c \"Also, surely you smart people " \
                                   "knows that application such like this one require JavaScript to run :)\"")
  end
end
