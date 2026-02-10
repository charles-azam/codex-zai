# Codex ZAI -- OpenAI Codex fork for GLM-4.7

A fork of [OpenAI Codex](https://github.com/openai/codex) adapted to run **ZAI's GLM-4.7** model. Built for benchmarking agentic scaffoldings on [Terminal-Bench 2.0](https://github.com/laude-institute/harbor).

**Benchmark results:** Scored **0.15** on Terminal-Bench (1 run). See the [full writeup](https://github.com/charles-azam/codex-zai) for how this compares to Gemini CLI (0.23), Claude Code (0.29), and Mistral Vibe (0.35) using the same model.

## Why this fork exists

I wanted to test whether the same model performs differently across coding agent scaffoldings. Codex's Rust codebase is the most "systems programming" approach of the agents I tested -- a 55-crate Cargo workspace with an event-driven async state machine, typed error handling, and multi-platform sandboxing (Seccomp + Landlock + Seatbelt). The architecture is impressive, but the tight coupling to OpenAI's ecosystem made it the hardest to adapt by far.

## Why Codex scored lowest

The 0.15 score (vs 0.35 for Mistral Vibe with the same model) isn't a knock on Codex's engineering -- it reflects how tightly the scaffolding is optimized for GPT. Several factors compound:

- **`apply_patch` demands precise diff syntax.** Codex edits files through unified diffs rather than `write_file`. This is elegant for frontier models trained on git diffs, but GLM-4.7 frequently produces malformed patches that fail silently or corrupt files.
- **The Responses API adaptation is lossy.** ZAI's endpoint speaks Chat Completions semantics. Mapping that onto Codex's Responses API wire format means features like native `local_shell` tool calls, WebSocket incremental append, and server-side prompt caching are either stubbed or degraded.
- **No prompt cache benefit.** Codex relies on OpenAI's `prompt_cache_key` for fast turn-to-turn latency. Without it, every turn pays full prefill cost.

The scaffolding matters -- roughly 2x between the best and worst agent on the same model.

## On the Rust choice

I understand why they chose Rust. When your agent executes shell commands on user machines, you want syscall-level sandboxing (seccomp filters, landlock, seatbelt profiles) as first-class citizens, not FFI bolted on. The compile-time safety guarantees also make the permission system and sandbox transforms auditable in a way that's hard to achieve in Python or TypeScript.

That said, it is a pain in the ass to work with for this kind of adaptation. Every protocol mismatch between ZAI and OpenAI surfaces as a compile error across multiple crates, and a full rebuild takes up to 5 minutes. The iteration cycle for "change one field name, wait 5 minutes, see if it works" is brutal compared to the TypeScript agents where you just save and re-run.

## On the Responses API

OpenAI moved Codex away from the Chat Completions API (confusingly called the "OpenAI endpoint" despite being the industry standard) to their new Responses API. This makes sense for them -- it unlocks native tool types like `local_shell`, WebSocket streaming with incremental append, server-side conversation state, and encrypted reasoning tokens. These are real architectural wins when you control both the client and server.

But for anyone trying to plug in a non-OpenAI model, it's a pain in the ass. Every other provider speaks Chat Completions. ZAI's `/v4` endpoint returns `reasoning_content` (plaintext) instead of `reasoning.encrypted_content`, uses `"system"` roles instead of `"developer"`, and expects standard function calls instead of native shell tool types. The adaptation layer is non-trivial and inevitably lossy -- you're translating between two fundamentally different protocol philosophies.

## What I changed

- **Native ZAI provider** pointing to `https://api.z.ai/api/coding/paas/v4` with `ZAI_API_KEY` authentication
- **Preserved Thinking** -- captures GLM-4.7's plaintext `reasoning_content` field across turns, maintaining reasoning context in multi-turn conversations (unlike OpenAI's encrypted reasoning tokens, you can actually read the model's chain of thought)
- **Protocol adaptations** -- `"developer"` role mapped to `"system"`, `reasoning_content` instead of `reasoning`, assistant content set to `""` instead of `null` for tool calls
- **Disabled/stubbed OpenAI-specific features** -- WebSocket incremental append, prompt cache keys, remote compaction tasks, native `local_shell` tool type
- **`--no-thinking` flag** to disable reasoning for control experiments
- **`--search` flag** for ZAI's native web search
- **Renamed binary** (`codex-zai`) and config directory (`~/.codex-zai`) to avoid conflicts with upstream

## Quick install

```bash
curl -fsSL https://raw.githubusercontent.com/charles-azam/codex-zai/main/scripts/install.sh | sh
```

Or manually:

```bash
# x86_64
wget -O codex-zai https://github.com/charles-azam/codex-zai/releases/latest/download/codex-zai

# ARM64
wget -O codex-zai https://github.com/charles-azam/codex-zai/releases/latest/download/codex-zai-arm64

chmod +x codex-zai && sudo mv codex-zai /usr/local/bin/
```

## Usage

```bash
export ZAI_API_KEY="your_key"

# Standard (thinking enabled)
codex-zai

# Without thinking
codex-zai --no-thinking

# With web search
codex-zai --search

# Headless (for scripts/pipelines)
echo "Fix the bug in main.py" | codex-zai exec --full-auto
```

## Dockerfile

```dockerfile
RUN curl -fsSL https://raw.githubusercontent.com/charles-azam/codex-zai/main/scripts/install.sh | sh
ENV PATH="$HOME:$PATH"
```

## Building from source

```bash
cd codex-rs
cargo build --release -p codex-cli  # ~5 minutes, go get coffee
./target/release/codex-zai --version
```

## Related

- [Article](https://charlesazam.com/blog/) -- full benchmark writeup and architecture comparison
- [gemini-cli-zai](https://github.com/charles-azam/gemini-cli-zai) -- Gemini CLI fork (scored 0.23)
- [mistral-vibe-zai](https://github.com/charles-azam/mistral-vibe-zai) -- Mistral Vibe fork (scored 0.35)
- [Upstream Codex](https://github.com/openai/codex) -- original project
