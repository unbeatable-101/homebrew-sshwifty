class Sshwifty < Formula
  desc "Web SSH & Telnet"
  homepage "https://github.com/nirui/sshwifty"
  url "https://github.com/nirui/sshwifty.git",
    tag:      "0.3.5-beta-release",
    revision: "22e6c7c0e55e3a9d9697d00e972a8c8fb84babe8"
  license "AGPL-3.0-or-later"

  depends_on "go" => :build
  depends_on "node" => :build

  def install
    inreplace "application/configuration/loader_file.go", "/etc/sshwifty.conf.json", "#{etc}/sshwifty/sshwifty.conf" \
                                                                                     ".json"
    system "npm", "install"
    system "npm", "run", "build"
    bin.install "sshwifty"
    mkdir "#{etc}/sshwifty"
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
