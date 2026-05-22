class EchoAi < Formula
  desc "Invisible AI assistant for macOS (Cloud Edition)"
  homepage "https://github.com/Pravinghodake153/echo"
  url "https://raw.githubusercontent.com/Pravinghodake153/echo/main/Echo-App-v1.0.4.tar.gz"
  sha256 "942562623d2fb3a46b043e5cd7e63f303108f7a1757d61cd3b79479346431f79"
  version "1.0.4"
  license "MIT"

  depends_on :macos

  def install
    # Install the Echo.app to the prefix (No Python or backend needed!)
    prefix.install "Echo.app"
  end

  def post_install
    # Clear macOS quarantine flag
    system "xattr", "-cr", (prefix/"Echo.app").to_s

    # Create config.json to connect to the remote Hugging Face backend seamlessly
    config_dir = Pathname.new(ENV["HOME"])/".echo"
    config_dir.mkpath
    
    config_file = config_dir/"config.json"
    unless config_file.exist?
      config_file.write <<~EOF
      {
          "backend_url": "https://ghodakepravin153-echo.hf.space",
          "auth_token": "42ce76c05d6fea6fc82caf112140ece6a677a83fc3a6296f01df12acdd562848"
      }
      EOF
    end
  end

  def caveats
    <<~EOS
      ╔═══════════════════════════════════════════════════╗
      ║           Echo AI installed successfully!         ║
      ╚═══════════════════════════════════════════════════╝

      Echo is now connected to your remote Hugging Face backend!
      Zero setup required — no Python, no API keys needed on this Mac.

      Launch Echo:
        open #{prefix}/Echo.app

      First time setup:
        1. Grant Accessibility permission when prompted
        2. Grant Screen Recording permission when prompted

      Uninstall:
        brew uninstall echo-ai
    EOS
  end

  test do
    assert_predicate prefix/"Echo.app/Contents/MacOS/Echo", :exist?
  end
end
