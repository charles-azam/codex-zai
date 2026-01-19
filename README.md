# Codex ZAI Fork (Benchmark Edition)

This is a specialized fork of OpenAI Codex, adapted to benchmark **ZAI's GLM-4.7** model on complex agentic tasks.

**Objective:** To evaluate the performance of GLM-4.7's "Preserved Thinking" and agentic capabilities within a production-grade coding agent scaffolding. This fork enables direct comparison between raw model outputs and agentic workflows using the same underlying model.

## Key modifications

This fork modifies the core Codex engine to support ZAI specific features:

1.  **Native ZAI Provider:** Implemented a built-in `zai` provider pointing to `https://api.z.ai/api/coding/paas/v4`.
2.  **Preserved Thinking:** Integrated ZAI's `reasoning_content` field. The agent now captures and displays the model's hidden reasoning process.
3.  **Thinking Toggle:** Added a `--no-thinking` flag to disable reasoning for control group benchmarks.
4.  **Web Search Integration:** Connected ZAI's native "in-chat" web search capabilities via the `--search` flag.
5.  **Environment Isolation:** All configuration and session history is stored in `~/.codex-zai` instead of `~/.codex` to prevent conflicts with your existing Codex installation.
6.  **Default Model:** Automatically defaults to `glm-4.7` and the ZAI provider.
7.  **Renamed Binary:** The tool is now called `codex-zai` to avoid confusion.

---

## 🚀 Quick Install (Binaries)

**Do not build from source unless you have to.** We provide pre-compiled binaries for Linux (x86_64 and ARM64).

### 0. One-line install
```bash
curl -fsSL https://raw.githubusercontent.com/charles-azam/codex-zai/main/scripts/install.sh | sh
```

If you want a different install dir:
```bash
INSTALL_DIR="$HOME/.local/bin" sh -c 'curl -fsSL https://raw.githubusercontent.com/charles-azam/codex-zai/main/scripts/install.sh | sh'
```
The script installs to `~` by default and adds it to your shell rc.

### 0.1. Quick start
```bash
# Reload your shell config (or open a new terminal)
source ~/.zshrc 2>/dev/null || source ~/.bashrc

# Set your API key
export ZAI_API_KEY="your_api_key_here"

# Verify
codex-zai --version
```

### 0.2. Dockerfile snippet
```dockerfile
RUN curl -fsSL https://raw.githubusercontent.com/charles-azam/codex-zai/main/scripts/install.sh | sh
ENV PATH="$HOME:$PATH"
```

### 1. Download
Go to the **[Releases Page](../../releases/latest)** or use the command line:

**For Standard Linux (x86_64):**
```bash
wget -O codex-zai https://github.com/charles-azam/codex-zai/releases/latest/download/codex-zai
chmod +x codex-zai
```

**For ARM Linux (ARM64 / Graviton / Apple Silicon Docker):**
```bash
wget -O codex-zai https://github.com/charles-azam/codex-zai/releases/latest/download/codex-zai-arm64
chmod +x codex-zai
```

### 2. Move to Path
```bash
sudo mv codex-zai /usr/local/bin/
```

### 3. Set API Key
```bash
export ZAI_API_KEY="your_api_key_here"
```

---

## 🤖 Running the Benchmark

### 1. Standard Benchmark (Thinking Enabled)
Uses GLM-4.7 with Preserved Thinking enabled. This is the primary test case for agentic reasoning.

```bash
codex-zai
```

### 2. Control Group (Thinking Disabled)
Forces the model to skip the reasoning phase and answer immediately.

```bash
codex-zai --no-thinking
```

### 3. Web Search Capability
Enables ZAI's native web search tool. The model can browse the web to answer questions.

```bash
# With Thinking + Web Search
codex-zai --search

# Without Thinking + Web Search
codex-zai --no-thinking --search
```

### 4. Headless Execution (for Scripts/Pipelines)
Use the `exec` mode to run without the UI.

```bash
# Example: Pipe a prompt into the agent
echo "Calculate the 10th Fibonacci number" | codex-zai exec --full-auto
```

---

## 📦 Deployment for Pipelines (CI/CD)

Use this snippet in your Dockerfile or CI script to automatically detect the architecture and install the correct binary.

```bash
# Auto-detect architecture (x86_64 or arm64)
ARCH=$(uname -m)
BASE_URL="https://github.com/charles-azam/codex-zai/releases/latest/download"

if [ "$ARCH" = "aarch64" ]; then
  echo "Downloading ARM64 binary..."
  wget -O codex-zai "$BASE_URL/codex-zai-arm64"
else
  echo "Downloading x86_64 binary..."
  wget -O codex-zai "$BASE_URL/codex-zai"
fi

chmod +x codex-zai
mv codex-zai /usr/local/bin/

# Verify installation
codex-zai --version
```

---

## Building from Source (Optional)

If you are developing features, you can build manually using Rust.

```bash
cd codex-rs
cargo build --release -p codex-cli
./target/release/codex-zai --version
```
