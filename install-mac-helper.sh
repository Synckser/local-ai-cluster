#!/bin/zsh
# Builds llama.cpp RPC helper on a Mac (Metal) and starts it.
# Run in Terminal:  curl -fsSL https://raw.githubusercontent.com/Synckser/local-ai-cluster/main/install-mac-helper.sh | zsh
set -e
TAG=b11322   # must match the main Mac and the Lenovo

xcode-select -p >/dev/null 2>&1 || { echo "Install Command Line Tools first: xcode-select --install"; exit 1; }
if ! command -v cmake >/dev/null; then
  command -v brew >/dev/null || { echo "Install Homebrew first: https://brew.sh"; exit 1; }
  brew install cmake
fi

if [ ! -d ~/llama.cpp ]; then
  git clone --depth 1 --branch $TAG https://github.com/ggml-org/llama.cpp ~/llama.cpp
else
  git -C ~/llama.cpp fetch --depth 1 origin tag $TAG && git -C ~/llama.cpp checkout -q $TAG
fi

cd ~/llama.cpp
cmake -B build -DGGML_RPC=ON -DGGML_METAL=ON -DLLAMA_CURL=OFF
cmake --build build --config Release -j --target ggml-rpc-server llama-server

echo "== Done. Starting helper on port 50052 (keep Terminal open)."
exec ~/llama.cpp/build/bin/ggml-rpc-server -H 0.0.0.0 -p 50052 -c
