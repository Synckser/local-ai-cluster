#!/bin/zsh
# Start llama-server on this Mac, spreading the model across whichever helper nodes are up.
# Helpers run rpc-server (Mac: start-helper-mac.sh, Lenovo: start-helper-windows.bat).

MODEL="${MODEL:-$HOME/models/Qwen3-Coder-30B-A3B-Instruct-Q4_K_M.gguf}"
CTX="${CTX:-32768}"
BIN="$HOME/llama.cpp/build/bin"

# Helper nodes: host:port. Edit LENOVO IP once known.
NODES=(
  "192.168.1.188:50052"   # Lenovo RTX 3080 (CUDA)
  "192.168.1.121:50052"   # Mac mini #2
)
# Share of the model per node (same order as NODES). This Mac keeps a small share
# so it stays usable; the Lenovo GPU takes the most.
MAIN_WEIGHT=1
WEIGHTS=(6 4)

RPC=(); SPLIT=($MAIN_WEIGHT)
for i in {1..${#NODES}}; do
  n=$NODES[$i]
  if nc -z -G 2 ${n%:*} ${n#*:} 2>/dev/null; then
    echo "up:   $n"; RPC+=$n; SPLIT+=$WEIGHTS[$i]
  else
    echo "down: $n (skipped)"
  fi
done

ARGS=(-m "$MODEL" -ngl 99 -c "$CTX" -fa on --jinja -np 1 --load-mode none -ub 512 --host 0.0.0.0 --port 8080 --alias local-coder)
(( ${#RPC} )) && ARGS+=(--rpc "${(j:,:)RPC}" --tensor-split "${(j:,:)SPLIT}")

echo "starting llama-server with ${#RPC} helper(s)"
exec "$BIN/llama-server" $ARGS
