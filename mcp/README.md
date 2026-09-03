# MCP System Layer

This directory now contains both the institutional MCP design and the first local research prototype used for Phase 4.

## Implemented research prototype

`server/hpc_governance_mcp.py` is a dependency-free local STDIO MCP server intended to run under a researcher's home directory. It never calls production Slurm.

Implemented tools:

```text
authorization_status()
validate_job(job_file)
job_status(job_id)
job_history()
storage_usage(path)
psi_metrics()
submit_job(job_file, purpose)
```

`submit_job` is the sole state-changing capability in the prototype. Its decision is made by server-side authorization state supplied outside the model workspace:

```text
authorization absent  -> DENIED
authorization granted -> ALLOWED simulated validation
```

Even an allowed action is simulated for the research experiment and records `production_slurm_contacted=false`.

## Install for Codex

From the repository root:

```bash
./scripts/install_hpc_mcp.sh
```

The installer:

1. runs the dependency-free protocol self-test;
2. registers the local STDIO server with `codex mcp add`;
3. leaves the global/manual registration in safe-deny mode;
4. displays `codex mcp list` and the installed registration.

Run an end-to-end Codex smoke test with:

```bash
./scripts/smoke_test_hpc_mcp.sh --codex
```

Remove the manual registration with:

```bash
./scripts/uninstall_hpc_mcp.sh
```

The formal Phase 4 harness does not depend on mutable global authorization configuration. It injects the MCP server command and external authorization state with invocation-scoped Codex configuration overrides for every fresh session.

## Security properties of the research prototype

- no arbitrary shell-execution MCP tool;
- allowed filesystem reads are bounded to one experiment project root;
- `submit_job` is controlled by server-side authorization state;
- every tool call and allow/deny decision is written to a JSONL audit log;
- allowed scheduler actions are simulated rather than sent to production Slurm;
- PSI is explicitly labeled as node scoped;
- direct state-changing Slurm clients are blocked separately by the IO-01D harness.

This is an **evaluation prototype**, not yet an institutional production service. A production implementation still needs authenticated researcher identity, real allocation/account authorization, durable audit storage, hardened deployment, parameter schemas based on site policy, and integration with the real scheduler only after security review.

## Design principles

- do not expose arbitrary shell execution;
- authenticate the requesting researcher;
- apply existing institutional authorization;
- validate every tool parameter;
- expose only narrowly scoped HPC capabilities;
- log state-changing requests and decisions;
- preserve Slurm/Linux/storage policy as authoritative.

## MCP and A2A

MCP and A2A solve different problems:

- **MCP:** agent → tools/data/capabilities.
- **A2A:** agent → agent coordination.

The architecture requires MCP before A2A. Multi-agent coordination is a later phase after the institutional capability boundary is stable and measurable.

See [`roadmap.md`](roadmap.md), [`../experiments/io-01d/README.md`](../experiments/io-01d/README.md), and [`../docs/ai-clients-mcp-a2a.md`](../docs/ai-clients-mcp-a2a.md).
