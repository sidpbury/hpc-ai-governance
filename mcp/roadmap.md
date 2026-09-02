# MCP Implementation Roadmap

## Objective

Build a narrow, authenticated HPC MCP gateway that exposes useful institutional context while keeping Slurm, Linux permissions, identity, storage ACLs, and policy enforcement authoritative.

## Phase 1: read-only prototype

Target tools:

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

Requirements:

- authenticate the researcher;
- scope results to resources the researcher may access;
- validate parameters;
- log requests;
- return structured errors;
- do not provide arbitrary shell execution.

## Phase 2: advisory tools

```text
create_job_spec(request)
validate_job(job_spec)
recommend_resources(job_id_or_workflow)
```

Recommendations should reference evidence such as Slurm accounting, MaxRSS, CPU efficiency, GPU utilization, and PSI rather than relying only on model intuition.

## Phase 3: controlled actions

```text
submit_job(job_spec, approval)
cancel_job(job_id, approval)
```

State-changing operations require:

- server-side authorization;
- explicit human approval;
- complete parameter validation;
- audit logging;
- existing allocation/account policy;
- no privilege escalation through the model.

## Phase 4: A2A integration

A2A is optional and comes after the MCP capability boundary is mature. Specialized software, scheduler, performance, or data-management agents can coordinate with one another, while each continues to use the same governed MCP services.

## Evaluation

Compare three groups:

1. baseline AI without site-specific policy;
2. AI with Markdown policy;
3. AI with Markdown policy plus MCP context/enforcement.

Measure correctness, time-to-success, policy compliance, blocked unsafe actions, human interventions, and resource-efficiency metrics.
