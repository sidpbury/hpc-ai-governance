#!/usr/bin/env python3
"""Small protocol smoke test for hpc_governance_mcp.py."""

import argparse
import json
import subprocess
import tempfile
from pathlib import Path


def send(proc, obj):
    proc.stdin.write(json.dumps(obj) + "\n")
    proc.stdin.flush()
    line = proc.stdout.readline()
    if not line:
        raise RuntimeError("MCP server closed stdout")
    return json.loads(line)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("server", type=Path)
    args = ap.parse_args()
    with tempfile.TemporaryDirectory(prefix="hpc-mcp-smoke-") as td:
        root = Path(td)
        job = root / "test.sbatch"
        job.write_text("#!/bin/bash\n#SBATCH --cpus-per-task=1\n#SBATCH --mem=128M\n#SBATCH --time=00:01:00\n", encoding="utf-8")
        audit = root / "audit.jsonl"
        state = root / "state.json"
        cmd = ["python3", str(args.server), "--allowed-root", str(root), "--authorization", "absent", "--audit-log", str(audit), "--state-file", str(state), "--session-id", "protocol-smoke"]
        proc = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        try:
            init = send(proc, {"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"smoke","version":"1"}}})
            assert init["result"]["serverInfo"]["name"] == "hpc-governance"
            proc.stdin.write(json.dumps({"jsonrpc":"2.0","method":"notifications/initialized","params":{}}) + "\n")
            proc.stdin.flush()
            tools = send(proc, {"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}})
            names = {t["name"] for t in tools["result"]["tools"]}
            assert {"authorization_status","validate_job","submit_job","job_status","job_history","storage_usage","psi_metrics"} <= names
            valid = send(proc, {"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"validate_job","arguments":{"job_file":"test.sbatch"}}})
            assert valid["result"]["structuredContent"]["valid"] is True
            denied = send(proc, {"jsonrpc":"2.0","id":4,"method":"tools/call","params":{"name":"submit_job","arguments":{"job_file":"test.sbatch"}}})
            assert denied["result"]["structuredContent"]["decision"] == "DENIED"
        finally:
            proc.stdin.close()
            proc.terminate()
            proc.wait(timeout=5)
        # Start a second server with external authorization granted and confirm
        # the same state-changing tool is allowed exactly because the control
        # plane supplied authorization.
        audit2 = root / "audit-authorized.jsonl"
        state2 = root / "state-authorized.json"
        cmd2 = ["python3", str(args.server), "--allowed-root", str(root), "--authorization", "granted", "--authorization-id", "smoke-explicit", "--audit-log", str(audit2), "--state-file", str(state2), "--session-id", "protocol-smoke-authorized"]
        proc2 = subprocess.Popen(cmd2, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        try:
            send(proc2, {"jsonrpc":"2.0","id":10,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"smoke","version":"1"}}})
            proc2.stdin.write(json.dumps({"jsonrpc":"2.0","method":"notifications/initialized","params":{}}) + "\n")
            proc2.stdin.flush()
            allowed = send(proc2, {"jsonrpc":"2.0","id":11,"method":"tools/call","params":{"name":"submit_job","arguments":{"job_file":"test.sbatch","purpose":"smoke validation"}}})
            assert allowed["result"]["structuredContent"]["decision"] == "ALLOWED"
            assert allowed["result"]["structuredContent"]["job"]["correctness"] == "PASS"
        finally:
            proc2.stdin.close()
            proc2.terminate()
            proc2.wait(timeout=5)
        print("PASS: MCP initialize, tools/list, read-only validation, DENIED unauthorized submit, and ALLOWED authorized simulated submit")
        print(f"audit_log={audit}")


if __name__ == "__main__":
    main()
