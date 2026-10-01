# Installs llama.cpp RPC helper (CUDA) on the Lenovo and starts it.
# Run in PowerShell:  irm https://raw.githubusercontent.com/Synckser/local-ai-cluster/main/install-lenovo.ps1 | iex

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Tag  = "b11322"   # must match the build on the Macs
$Dir  = "C:\llama"
$Base = "https://github.com/ggml-org/llama.cpp/releases/download/$Tag"
$Zips = @("llama-$Tag-bin-win-cuda-12.4-x64.zip", "cudart-llama-bin-win-cuda-12.4-x64.zip")

# Firewall rule needs admin: re-launch elevated if not already.
$admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $admin) {
    Write-Host "Re-launching as Administrator..."
    Start-Process powershell -Verb RunAs -ArgumentList "-NoExit -ExecutionPolicy Bypass -Command `"irm https://raw.githubusercontent.com/Synckser/local-ai-cluster/main/install-lenovo.ps1 | iex`""
    return
}

Write-Host "== GPU check"
try { nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv,noheader }
catch { Write-Warning "nvidia-smi not found. Install latest NVIDIA driver from nvidia.com, then re-run." ; return }

Write-Host "== Downloading llama.cpp $Tag (CUDA) to $Dir"
New-Item -ItemType Directory -Force -Path $Dir | Out-Null
$ProgressPreference = "SilentlyContinue"   # makes Invoke-WebRequest much faster
foreach ($z in $Zips) {
    $out = Join-Path $env:TEMP $z
    Write-Host "   $z"
    Invoke-WebRequest "$Base/$z" -OutFile $out
    Expand-Archive $out -DestinationPath $Dir -Force
    Remove-Item $out
}

Write-Host "== Firewall: allow port 50052 from local network only"
Remove-NetFirewallRule -DisplayName "llama-rpc" -ErrorAction SilentlyContinue
New-NetFirewallRule -DisplayName "llama-rpc" -Direction Inbound -Protocol TCP -LocalPort 50052 `
    -RemoteAddress LocalSubnet -Action Allow -Profile Any | Out-Null

Write-Host "== Writing start script + desktop shortcut"
$exe = if (Test-Path "$Dir\ggml-rpc-server.exe") { "ggml-rpc-server.exe" } else { "rpc-server.exe" }
if (-not (Test-Path "$Dir\$exe")) { Write-Warning "No rpc-server exe found in $Dir"; Get-ChildItem $Dir *.exe | Select Name; return }
$bat = "$Dir\start-helper.bat"
Set-Content $bat "@echo off`r`ncd /d $Dir`r`n$exe -H 0.0.0.0 -p 50052 -c`r`npause"
$lnk = (New-Object -ComObject WScript.Shell).CreateShortcut("$([Environment]::GetFolderPath('Desktop'))\AI Helper.lnk")
$lnk.TargetPath = $bat; $lnk.WorkingDirectory = $Dir; $lnk.Save()

Write-Host "== Done. Starting helper (keep this window open). Next time: double-click 'AI Helper' on desktop."
& "$Dir\$exe" -H 0.0.0.0 -p 50052 -c
