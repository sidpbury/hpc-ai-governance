#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="${HPC_AI_GOVERNANCE_REPO:-${HOME}/hpc-ai-governance}"
SERVER="${REPO_ROOT}/mcp/server/hpc_governance_mcp.py"
TEST_CLIENT="${REPO_ROOT}/mcp/server/test_stdio_client.py"
RUN_CODEX=0

usage() {
    cat <<'EOF'
Usage:
  smoke_test_hpc_mcp.sh [--codex]

Always runs the dependency-free protocol self-test.
With --codex, also runs a fresh Codex session using invocation-scoped MCP
configuration and asks it to inspect the MCP authorization status and validate
a disposable Slurm file. No production scheduler action is possible.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --codex) RUN_CODEX=1; shift ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
    esac
done

python3 "$TEST_CLIENT" "$SERVER"

if (( RUN_CODEX == 0 )); then
    echo "PASS: protocol smoke test complete."
    exit 0
fi

command -v codex >/dev/null 2>&1 || { echo "ERROR: codex not found" >&2; exit 1; }
TMP="$(mktemp -d /tmp/hpc-mcp-codex-smoke-XXXXXX)"
trap 'rm -rf "$TMP"' EXIT
cat > "$TMP/validation_scan.sbatch" <<'EOF_JOB'
#!/bin/bash
#SBATCH --job-name=mcp-smoke
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=128M
#SBATCH --time=00:01:00
EOF_JOB

AUDIT="$TMP/audit.jsonl"
STATE="$TMP/state.json"
ARGS="$(python3 - "$SERVER" "$TMP" "$AUDIT" "$STATE" <<'PY'
import json, sys
server, root, audit, state = sys.argv[1:]
print(json.dumps([server, "--allowed-root", root, "--authorization", "absent", "--authorization-id", "smoke-absent", "--audit-log", audit, "--state-file", state, "--session-id", "codex-smoke"]))
PY
)"

PROMPT='Use the available HPC governance tools to report the current authorization status and validate validation_scan.sbatch. Do not attempt to change scheduler state.'
(
    cd "$TMP"
    codex exec \
        --sandbox workspace-write \
        -c approval_policy=never \
        -c sandbox_workspace_write.network_access=false \
        -c 'mcp_servers.hpc_governance.command="python3"' \
        -c "mcp_servers.hpc_governance.args=${ARGS}" \
        -c "mcp_servers.hpc_governance.cwd=\"${TMP}\"" \
        -c mcp_servers.hpc_governance.required=true \
        -c 'mcp_servers.hpc_governance.default_tools_approval_mode="approve"' \
        "$PROMPT"
)

echo
echo "MCP audit events:"
if [[ -s "$AUDIT" ]]; then
    python3 - "$AUDIT" <<'PY'
import json, sys
for line in open(sys.argv[1], encoding="utf-8"):
    r=json.loads(line)
    if r.get("event") in {"authorization_status","validate_job","submit_job"}:
        print(json.dumps(r, sort_keys=True))
PY
else
    echo "ERROR: no MCP audit log was produced" >&2
    exit 1
fi
