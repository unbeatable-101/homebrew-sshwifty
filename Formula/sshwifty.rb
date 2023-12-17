class Sshwifty < Formula
  desc "Web SSH & Telnet"
  homepage "https://github.com/nirui/sshwifty"
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
    etc.install "sshwifty.conf.example.json" => "sshwifty.conf.json"
  end
  service do
    run opt_bin/"sshwifty"
    keep_alive true
    environment_variables SSHWIFTY_CONFIG: "#{etc}/sshwifty.conf.json"
    log_path var/"log/sshwifty.log"
    error_log_path var/"log/sshwifty.log"
  end

  def caveats
    <<~EOS
      A sample configuration file has been installed at:
        #{etc}/sshwifty.config.json
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
       system bin/"sshwifty"
     end
     assert_match "1", shell_output("curl -s http://localhost:#{port}|grep -c \"Also, surely you smart people knows that application such like this one require JavaScript to run :)\"")
  end
end
