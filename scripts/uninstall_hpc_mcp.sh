#!/usr/bin/env bash
set -euo pipefail
SERVER_NAME="hpc-governance"
if ! command -v codex >/dev/null 2>&1; then
    echo "ERROR: codex not found" >&2
    exit 1
fi
if codex mcp get "$SERVER_NAME" >/dev/null 2>&1; then
    codex mcp remove "$SERVER_NAME"
    echo "Removed Codex MCP registration: $SERVER_NAME"
else
    echo "No Codex MCP registration found for: $SERVER_NAME"
fi
