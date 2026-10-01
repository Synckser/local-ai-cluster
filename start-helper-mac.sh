#!/bin/zsh
# Run on Mac mini #2. Lends its GPU to the cluster over the LAN.
# -c caches tensors on local disk so later model loads skip the network.
exec "$HOME/llama.cpp/build/bin/ggml-rpc-server" -H 0.0.0.0 -p 50052 -c
