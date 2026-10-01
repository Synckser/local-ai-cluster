# local-ai-cluster

One local LLM split across 2–3 machines on the home LAN with llama.cpp RPC. Free, no cloud.

| Machine | IP | Role |
|---|---|---|
| Mac mini M4 16GB #1 | 192.168.1.146 | main: runs `llama-server` |
| Mac mini M4 16GB #2 | 192.168.1.121 | helper: `ggml-rpc-server` |
| Lenovo i9 + RTX 3080 Laptop 16GB | 192.168.1.188 | helper: `rpc-server` (CUDA) |

All nodes must run the same llama.cpp release: **b11322**.

## Install

**Lenovo (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/Synckser/local-ai-cluster/main/install-lenovo.ps1 | iex
```

**Mac mini #2 (Terminal):**
```sh
curl -fsSL https://raw.githubusercontent.com/Synckser/local-ai-cluster/main/install-mac-helper.sh | zsh
```

## Run

1. Start helpers (Lenovo: desktop "AI Helper"; Mac #2: `~/llama.cpp/build/bin/ggml-rpc-server -H 0.0.0.0 -p 50052 -c`).
2. Main Mac: `./start-cluster.sh` — uses whichever helpers are up.
3. Claude Code on local model: `./claude-local.sh`

Model: `Qwen3-Coder-30B-A3B-Instruct-Q4_K_M.gguf` (unsloth, ~17 GB) in `~/models/`.

**Security:** rpc-server has no auth. LAN only — never port-forward 50052.

## Measured (all 3 nodes, Qwen3-Coder-30B Q4_K_M, 1GbE)
- Generation: ~22 tok/s
- Prompt read: ~260 tok/s → first Claude Code turn ~70 s (17k-token system prompt), later turns faster via cache
- Reload with helper cache (`-c`): ~30 s

## Gotchas
- Main Mac must use `--load-mode none`; default mmap maps the whole model into Metal and OOMs a 16 GB Mac.
- Lenovo helper auto-starts at login via scheduled task `llama-rpc`.
