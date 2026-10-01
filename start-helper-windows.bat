@echo off
REM Run on the Lenovo. Lends the RTX 3080 to the cluster over the LAN.
cd /d C:\llama
if exist ggml-rpc-server.exe (
  ggml-rpc-server.exe -H 0.0.0.0 -p 50052 -c
) else (
  rpc-server.exe -H 0.0.0.0 -p 50052 -c
)
pause
