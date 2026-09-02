# Architecture

## Overview

The project defines two complementary paths for introducing AI into HPC.

## Level 1: User-governed AI

```text
Researcher
    |
    v
AI coding assistant
    |
    v
Project/site Markdown instructions
    |
    v
Existing shell / Slurm / Spack workflow
```

Examples of client instruction files include:

- `CLAUDE.md`
- `AGENTS.md`
- `GEMINI.md`
- `.github/copilot-instructions.md`

The canonical project policy is `policy/HPC-AI-INSTRUCTIONS.md`.

This layer is intentionally lightweight. It can teach the agent to:

- avoid sustained computation on login nodes;
- generate Slurm scripts for compute-intensive work;
- request approval before consequential actions;
- protect credentials and unrelated files;
- prefer site-supported software;
- use GPU and PSI evidence when diagnosing performance.

It does **not** create a security boundary.

## Level 2: Institution-governed AI

```text
Researcher
    |
    v
AI client
    |
    +------ Markdown behavioral guidance
    |
    v
MCP gateway
    |
    +------ authentication
    +------ authorization
    +------ input validation
    +------ approval enforcement
    +------ audit logging
    |
    +------ Slurm
    +------ software inventory / Spack
    +------ documentation
    +------ GPU telemetry
    +------ PSI telemetry
    +------ storage
```

The MCP service exposes narrow capabilities rather than an unrestricted shell.

Examples:

```text
job_status()
job_history()
job_details(job_id)
software_find(query)
gpu_utilization(job_id)
pressure_summary(job_id)
validate_job(job_spec)
submit_job(job_spec, approval_token)
```

## Authority model

The layers have different roles:

| Layer | Role | Strength |
|---|---|---|
| Markdown instructions | Behavioral guidance | Advisory |
| AI client permissions | Local tool restrictions | Client-side |
| MCP gateway | Tool and policy enforcement | Enforced |
| Slurm / Linux / storage ACLs | Resource and identity authority | Authoritative |
| Human approval | Governance for consequential actions | Explicit control |

The core principle is that the AI model is never the ultimate security or scheduling authority.

## Future Level 3: specialized agents / A2A

A2A is optional and follows the governed MCP layer.

```text
Researcher
    |
    v
Primary research assistant
    |
    +---- Software specialist
    +---- Slurm/workflow specialist
    +---- Performance specialist
    +---- Data-management specialist
             |
             v
        governed MCP services
```

A2A coordinates agents; it does not replace the MCP authorization and capability boundary. See [`ai-clients-mcp-a2a.md`](ai-clients-mcp-a2a.md).
