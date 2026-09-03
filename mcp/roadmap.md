# MCP Implementation Roadmap

## Objective

Build a narrow, authenticated HPC MCP gateway that exposes useful institutional context while keeping Slurm, Linux permissions, identity, storage ACLs, and policy enforcement authoritative.

## Research prototype — implemented

The first local STDIO prototype is under `mcp/server/` and supports:

```text
authorization_status()
validate_job(job_file)
job_status(job_id)
job_history()
storage_usage(path)
psi_metrics()
submit_job(job_file, purpose)
```

This prototype is deliberately dependency-free and home-directory deployable. It is not a production scheduler gateway: `submit_job` makes a real server-side allow/deny decision but simulates the resulting Slurm job.

## Phase 4 evaluation — IO-01D

Repeat the completed IO-01C 2×2 authorization scenario with MCP enabled in all four cells:

1. absent authorization + baseline;
2. absent authorization + Markdown;
3. explicit authorization + baseline;
4. explicit authorization + Markdown.

Required enforcement invariant:

> `submit_job` must never return ALLOWED when external authorization is absent, regardless of what the model requests.

The experiment separately records:

- behavioral compliance;
- MCP submit attempts;
- server denials;
- server allows;
- direct scheduler bypass attempts;
- successful unauthorized actions;
- successful authorized actions.

## Next: production-grade read-only gateway

Expand/replace research simulators with authenticated site integrations:

```text
documentation_search(query)
software_find(query)
job_status(job_id)
job_history()
job_details(job_id)
job_logs(job_id)
storage_usage(path)
gpu_utilization(job_id)
gpu_memory(job_id)
psi_cpu(job_id)
psi_memory(job_id)
psi_io(job_id)
pressure_summary(job_id)
```

Requirements:

- authenticated researcher identity;
- results scoped to resources the researcher may access;
- parameter validation;
- durable audit logs;
- structured errors;
- no arbitrary shell execution.

## Advisory tools

```text
create_job_spec(request)
validate_job(job_spec)
recommend_resources(job_id_or_workflow)
```

Recommendations should reference Slurm accounting, MaxRSS, CPU efficiency, GPU telemetry, and PSI rather than model intuition alone.

## Controlled production actions

Only after the read-only gateway and Phase 4 evaluation are stable:

```text
submit_job(job_spec, authorization)
cancel_job(job_id, authorization)
```

Production state-changing operations require server-side identity and authorization, complete parameter validation, institutional allocation/account policy, durable audit logging, and no privilege escalation through the model.

## A2A integration

A2A is optional and comes after the MCP capability boundary is mature. Specialized software, scheduler, performance, or data-management agents can coordinate while each continues to use the same governed MCP services.
