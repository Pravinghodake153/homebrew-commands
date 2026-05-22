class EchoAi < Formula
  desc "Invisible AI assistant for macOS — 6 providers, 15 slash commands"
  homepage "https://github.com/Pravinghodake153/echo"
  url "https://github.com/Pravinghodake153/echo/releases/download/v1.0.2/Echo-v1.0.2.tar.gz"
  sha256 "cdc0b5cc97b3efcf4ff8a2a5848af3845bcb539c747f8971f741885b0bd0c958"
  version "1.0.2"
  license "MIT"

  depends_on :macos
  depends_on "python@3.13" => :recommended

  def install
    # Install everything to the Cellar prefix
    prefix.install Dir["*"]

    # Create config.json from default template if missing
    config_dir = prefix/"backend/config"
    config_file = config_dir/"config.json"
    default_config = config_dir/"config.default.json"
    if !config_file.exist? && default_config.exist?
      cp default_config, config_file
    end
  end

  def post_install
    # Setup Python virtual environment
    venv_dir = prefix/"backend/venv"
    unless (venv_dir/"bin/python").exist?
      system "python3", "-m", "venv", venv_dir.to_s
    end

    # Install Python dependencies
    system venv_dir/"bin/pip", "install", "--quiet", "--upgrade", "pip"
    system venv_dir/"bin/pip", "install", "--quiet", "-r", (prefix/"requirements.txt").to_s

    # Clear macOS quarantine flag
    system "xattr", "-cr", (prefix/"Echo.app").to_s

    # Create .env template if missing
    env_file = prefix/".env"
    unless env_file.exist?
      env_file.write <<~EOS
        # Echo AI — Configuration
        # Add your API keys below. At least one is required.

        # Gemini API (recommended) — Get key at: https://aistudio.google.com/apikey
        GEMINI_API_KEYS=

        # OpenRouter (optional) — Get key at: https://openrouter.ai/settings/keys
        OPENROUTER_API_KEY=

        # Models
        GEMINI_MODEL_ID=gemini-2.5-flash
        OPENROUTER_MODEL_ID=openai/gpt-4o
        OLLAMA_MODEL=qwen3:4b
      EOS
    end

    # Create symlink so you can launch from anywhere
    bin.install_symlink prefix/"Echo.app/Contents/MacOS/Echo" => "echo-ai"
  end

  def caveats
    <<~EOS
      ╔═══════════════════════════════════════════════════╗
      ║           Echo AI installed successfully!         ║
      ╚═══════════════════════════════════════════════════╝

      Launch Echo:
        open #{prefix}/Echo.app

      Or from terminal:
        echo-ai

      First time setup:
        1. Grant Accessibility permission when prompted
        2. Add your API key:
           → Open Settings in Echo's menu bar
           → Or edit: #{prefix}/.env

      Uninstall:
        brew uninstall echo-ai
    EOS
  end

  test do
    assert_predicate prefix/"Echo.app/Contents/MacOS/Echo", :exist?
    assert_predicate prefix/"backend/app.py", :exist?
  end
end
