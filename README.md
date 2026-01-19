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
6.  **Default Model:** Automatically defaults to `glm-4.7`.

---

## Prerequisites

You need a ZAI API Key to run this fork.

```bash
export ZAI_API_KEY="your_api_key_here"
```

---

## Building from Source

You need **Rust** installed (stable toolchain).

```bash
# Navigate to the rust code directory
cd codex-rs

# Build the CLI
cargo build -p codex-cli
```

To build a release binary (faster, smaller):

```bash
cargo build --release -p codex-cli
```

The binary will be located at `codex-rs/target/debug/codex` (or `target/release/codex`).

---

## Running the Benchmark

You can run the agent directly using `cargo run`.

### 1. Standard Benchmark (Thinking Enabled)
Uses GLM-4.7 with Preserved Thinking enabled. This is the primary test case for agentic reasoning.

```bash
cargo run -p codex-cli -- -c model_provider=zai
```

### 2. Control Group (Thinking Disabled)
Forces the model to skip the reasoning phase and answer immediately.

```bash
cargo run -p codex-cli -- -c model_provider=zai --no-thinking
```

### 3. Web Search Capability
Enables ZAI's native web search tool. The model can browse the web to answer questions.

```bash
# With Thinking + Web Search
cargo run -p codex-cli -- -c model_provider=zai --search

# Without Thinking + Web Search
cargo run -p codex-cli -- -c model_provider=zai --no-thinking --search
```

### 4. Headless Execution (for Scripts)
Use the `exec` mode to run without the UI, useful for automated pipelines.

```bash
# Example: Pipe a prompt into the agent
echo "Calculate the 10th Fibonacci number" | cargo run -p codex-cli -- exec -c model_provider=zai --full-auto
```

---

## Deployment for Pipelines

If you need to run this on Linux CI/CD runners (e.g., GitHub Actions, GitLab CI), **do not commit the macOS binary**.

Instead, use the **Releases** feature:
1.  Push a tag (e.g., `v0.1`) to this repository.
2.  The GitHub Action workflow will automatically build a Linux binary.
3.  Download the binary from the **Releases** page in your pipeline script.

```bash
# Example pipeline step
wget -O codex https://github.com/YOUR_USERNAME/YOUR_REPO/releases/download/v0.1/codex
chmod +x codex
./codex ...
```