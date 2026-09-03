#!/usr/bin/env bash
set -euo pipefail

SERVER_NAME="hpc-governance"
REPO_ROOT="${HPC_AI_GOVERNANCE_REPO:-${HOME}/hpc-ai-governance}"
SERVER="${REPO_ROOT}/mcp/server/hpc_governance_mcp.py"
TEST_CLIENT="${REPO_ROOT}/mcp/server/test_stdio_client.py"

usage() {
    cat <<'EOF'
Usage:
  install_hpc_mcp.sh [--repo PATH]

Registers the local dependency-free HPC governance MCP STDIO server with Codex.
The globally registered server starts in safe-deny mode: submit_job is denied.
The Phase 4 experiment uses per-session Codex config overrides to provide an
external authorization state without changing the global registration.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --repo) REPO_ROOT="$2"; SERVER="${REPO_ROOT}/mcp/server/hpc_governance_mcp.py"; TEST_CLIENT="${REPO_ROOT}/mcp/server/test_stdio_client.py"; shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
    esac
done

for cmd in python3 codex; do
    command -v "$cmd" >/dev/null 2>&1 || { echo "ERROR: required command not found: $cmd" >&2; exit 1; }
done
[[ -f "$SERVER" ]] || { echo "ERROR: MCP server not found: $SERVER" >&2; exit 1; }
[[ -f "$TEST_CLIENT" ]] || { echo "ERROR: MCP smoke client not found: $TEST_CLIENT" >&2; exit 1; }

chmod 0755 "$SERVER" "$TEST_CLIENT"
mkdir -p "${HOME}/.local/state/hpc-ai-governance-mcp"

printf 'Running protocol self-test...\n'
python3 "$TEST_CLIENT" "$SERVER"

if codex mcp get "$SERVER_NAME" >/dev/null 2>&1; then
    echo "Replacing existing Codex MCP registration: $SERVER_NAME"
    codex mcp remove "$SERVER_NAME" >/dev/null
fi

# Global/manual registration is deliberately fail-closed: no authorization is
# supplied, so submit_job will always be denied. The Phase 4 harness injects
# run-specific authorization and audit paths with invocation-scoped -c values.
codex mcp add "$SERVER_NAME" -- python3 "$SERVER"

echo
echo "Registered MCP servers:"
codex mcp list

echo
echo "Registration details:"
codex mcp get "$SERVER_NAME"

echo
echo "Installed in SAFE-DENY mode."
echo "Manual submit_job calls through this global registration cannot contact production Slurm and will be denied."
echo "Next: ./scripts/smoke_test_hpc_mcp.sh"
