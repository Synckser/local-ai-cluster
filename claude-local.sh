#!/bin/zsh
# Launch Claude Code against the local cluster instead of Anthropic.
export ANTHROPIC_BASE_URL="http://192.168.1.146:8080"
export ANTHROPIC_AUTH_TOKEN="local"
export ANTHROPIC_MODEL="local-coder"
export ANTHROPIC_SMALL_FAST_MODEL="local-coder"
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
exec claude "$@"
