# MCP System Layer

This directory contains the design for the institution-governed MCP implementation.

## Design goals

- do not expose arbitrary shell execution;
- authenticate the requesting researcher;
- apply the researcher's existing authorization;
- validate all tool parameters;
- expose only narrowly scoped HPC capabilities;
- log state-changing requests;
- require explicit approval for consequential operations;
- preserve Slurm/Linux/storage policy as authoritative.

## Proposed first-release tools

Read-only:

```text
documentation_search(query)
software_find(query)
job_status()
job_history()
job_details(job_id)
job_logs(job_id)
storage_usage()
gpu_utilization(job_id)
gpu_memory(job_id)
psi_cpu(job_id)
psi_memory(job_id)
psi_io(job_id)
pressure_summary(job_id)
```

Advisory/validation:

```text
create_job_spec(request)
validate_job(job_spec)
recommend_resources(job_id_or_workflow)
```

Later state-changing tools:

```text
submit_job(job_spec, approval)
cancel_job(job_id, approval)
```

State-changing functionality is intentionally outside the initial implementation scope.

## MCP and A2A

MCP and A2A solve different problems:

- **MCP:** agent → tools/data/capabilities.
- **A2A:** agent → agent coordination.

The initial architecture requires MCP but does not require A2A. Multi-agent/A2A work is a later phase after the institutional capability boundary is stable and measurable.

See [`roadmap.md`](roadmap.md) and [`../docs/ai-clients-mcp-a2a.md`](../docs/ai-clients-mcp-a2a.md).
