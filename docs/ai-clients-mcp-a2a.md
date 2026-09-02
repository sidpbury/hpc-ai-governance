# Integrating AI Clients, MCP, and A2A into HPC

This document captures the broader integration path for tools such as Claude Code, Codex, Gemini CLI, and GitHub Copilot in an HPC environment.

## Core principle

AI should sit **around** the HPC workflow, not replace its authoritative controls.

```text
Researcher
    |
    v
AI client (Claude / Codex / Gemini / Copilot)
    |
    +---- project/site Markdown guidance
    |
    v
HPC capabilities
    |
    +---- documentation / software inventory
    +---- Slurm job information
    +---- logs and accounting
    +---- GPU telemetry
    +---- CPU / memory / I/O PSI
    +---- storage information
```

Slurm, Linux permissions, allocation/account policy, storage ACLs, identity, and institutional security controls remain authoritative.

## User-installed AI clients

An institution does not need to provide a monolithic `ai-tool` module for researchers to experiment with coding assistants. A user can install a supported client in a home-directory environment and apply site guidance through the instruction filename the client understands.

Examples:

```text
Claude Code       CLAUDE.md
Codex             AGENTS.md
Gemini CLI        GEMINI.md
GitHub Copilot    .github/copilot-instructions.md
```

The canonical source in this repository is `policy/HPC-AI-INSTRUCTIONS.md`.

These files are behavioral guidance. They can improve decisions but are not an enforcement boundary.

## MCP: agent-to-capability integration

Model Context Protocol (MCP) provides the institution-governed path. The MCP service should expose narrow capabilities rather than an unrestricted shell.

Initial read-only examples:

```text
documentation_search(query)
software_find(query)
job_status()
job_history()
job_details(job_id)
job_logs(job_id)
storage_usage()
gpu_utilization(job_id)
psi_cpu(job_id)
psi_memory(job_id)
psi_io(job_id)
```

Advisory examples:

```text
create_job_spec(request)
validate_job(job_spec)
recommend_resources(job_id_or_workflow)
```

Later, controlled state-changing tools may include:

```text
submit_job(job_spec, approval)
cancel_job(job_id, approval)
```

Do not begin with arbitrary `execute_shell`. State-changing actions should be authorized outside the model, validated server-side, logged, and gated by explicit human approval.

## A2A: agent-to-agent integration

A2A is complementary to MCP rather than a replacement for it:

> **MCP connects an agent to tools and data. A2A connects an agent to other agents.**

A2A is a later-stage option and is not required for the initial HPC AI implementation.

A possible future multi-agent design is:

```text
Research assistant
       |
       +---- Software agent
       |       +---- Spack / module / environment knowledge
       |
       +---- HPC workflow agent
       |       +---- Slurm / job geometry / validation
       |
       +---- Performance agent
       |       +---- accounting / GPU / PSI evidence
       |
       +---- Data movement agent
               +---- storage / transfer guidance
```

Each specialist may use MCP to access constrained institutional capabilities. A2A coordinates the specialists.

## Progressive trust model

| Level | Capability | Example |
|---|---|---|
| 0 | Advisory only | Explain scripts and suggest changes |
| 1 | Read-only HPC context | Query jobs, docs, software, metrics |
| 2 | Validated recommendations | Produce and validate a job specification |
| 3 | Controlled action | Submit/cancel only after explicit approval |
| 4 | Multi-agent coordination | Specialized agents coordinate through A2A |

The important boundary is between **recommendation** and **state change**. The model should not grant itself authority.

## Recommended roadmap

### Phase 1 — User assistant

- Support user-installed Claude/Codex/Gemini/Copilot workflows.
- Distribute canonical HPC Markdown guidance.
- Evaluate behavior with blinded benchmark scenarios.

### Phase 2 — Read-only HPC MCP

- Documentation search.
- Software discovery.
- Slurm status/history/logs.
- Storage information.
- GPU and PSI telemetry.

### Phase 3 — Evidence-informed performance assistance

- Join Slurm accounting with CPU, memory, I/O, GPU, and PSI evidence.
- Right-size resource requests.
- Validate recommendations experimentally.

### Phase 4 — Controlled actions

- Server-side authorization and validation.
- Explicit approval tokens or equivalent confirmation.
- Audit logging.
- Narrow `submit_job` / `cancel_job` capabilities.

### Phase 5 — Specialized agents / A2A

- Introduce agent-to-agent coordination only when independent specialist roles provide measurable value.
- Preserve the same MCP authorization boundary underneath each agent.

## Relationship to this research project

The evaluation path in this repository is deliberately progressive:

```text
A. General AI without site-specific HPC policy
              |
              v
B. AI + project/site Markdown governance
              |
              v
C. AI + Markdown + institutional MCP + telemetry
              |
              v
Future: specialized agents coordinated through A2A
```

This makes it possible to separate the behavioral effect of Markdown guidance from the enforceable effect of MCP and the orchestration effect of later multi-agent designs.
