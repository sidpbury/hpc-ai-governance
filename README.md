# HPC AI Governance

A research-computing project for evaluating and deploying AI assistance in high-performance computing (HPC) through two complementary governance layers:

1. **User-governed AI** — project/site Markdown instruction files that teach general-purpose AI coding assistants how to behave in an HPC environment.
2. **Institution-governed AI** — a Model Context Protocol (MCP) service that exposes narrow, authenticated HPC capabilities and enforces policy outside the model.

The project treats Slurm, Linux permissions, allocation policy, and institutional controls as authoritative. AI provides assistance, context, diagnostics, and eventually controlled orchestration.

## Project hypothesis

A progressive integration model can improve HPC usability and resource efficiency while preserving governance:

**Baseline AI → Markdown-governed AI → MCP-governed AI + telemetry**

The evaluation is designed to measure both researcher outcomes and system behavior, including:

- Slurm script correctness
- time to successful execution
- policy compliance
- blocked unsafe actions
- CPU and memory efficiency
- GPU utilization and GPU memory efficiency
- CPU, memory, and I/O Pressure Stall Information (PSI)
- failed submissions and human interventions

## Repository layout

```text
hpc-ai-governance/
├── README.md
├── CITATION.cff
├── CONTRIBUTING.md
├── SECURITY.md
├── Makefile
├── paper/
│   ├── ai_hpc_agentic_workflows.tex
│   └── ai_hpc_agentic_workflows.pdf
├── proposals/
│   └── greenbelt_ai_hpc_workflow_proposal.md
├── docs/
│   ├── user-guide.md
│   ├── architecture.md
│   └── evaluation.md
├── policy/
│   ├── HPC-AI-INSTRUCTIONS.md
│   └── clients/
│       ├── claude/CLAUDE.md
│       ├── codex/AGENTS.md
│       ├── gemini/GEMINI.md
│       └── copilot/copilot-instructions.md
├── scripts/
│   └── install-policy.sh
├── experiments/
│   ├── README.md
│   ├── benchmark-plan.md
│   ├── metrics-schema.csv
│   └── scenarios/
├── mcp/
│   └── README.md
├── containers/
│   └── README.md
└── institutional/
    └── README.md
```

## Quick start: user-level approach

Copy the canonical policy into your research project using the filename expected by your AI tool:

```bash
# Claude Code
cp policy/HPC-AI-INSTRUCTIONS.md /path/to/project/CLAUDE.md

# Codex
cp policy/HPC-AI-INSTRUCTIONS.md /path/to/project/AGENTS.md

# Gemini CLI
cp policy/HPC-AI-INSTRUCTIONS.md /path/to/project/GEMINI.md

# GitHub Copilot
mkdir -p /path/to/project/.github
cp policy/HPC-AI-INSTRUCTIONS.md /path/to/project/.github/copilot-instructions.md
```

Or use:

```bash
./scripts/install-policy.sh claude /path/to/project
```

The Markdown policy is a **behavioral guardrail**, not a security boundary. Researchers should review proposed commands and Slurm submissions before execution.

## System-level approach

The planned MCP layer will expose purpose-built HPC tools rather than arbitrary shell execution. Example capabilities include:

```text
documentation_search()
software_find()
job_status()
job_history()
job_logs()
gpu_utilization()
psi_cpu()
psi_memory()
psi_io()
validate_job()
submit_job()
```

Read-only capabilities are the intended first deployment. State-changing operations should require explicit user approval and server-side authorization.

See [`mcp/README.md`](mcp/README.md).

## Performance evidence

The project uses three categories of operational evidence:

### Scheduler accounting
Requested resources, elapsed time, CPU use, memory use, job state, and exit status.

### GPU telemetry
GPU compute utilization, GPU memory use, power/throttling indicators, and related accelerator measurements when available.

### Linux PSI
CPU, memory, and I/O stall pressure, including `avg10`, `avg60`, `avg300`, `some`, `full` where applicable, and cumulative stall time.

See [`docs/evaluation.md`](docs/evaluation.md) and [`experiments/benchmark-plan.md`](experiments/benchmark-plan.md).

## Current status

- [x] Journal-paper architecture and literature review
- [x] Green Belt/DMAIC proposal
- [x] User-level Markdown policy
- [x] Researcher user guide
- [x] Initial benchmark design
- [ ] Baseline experiment execution
- [ ] User-governed experiment execution
- [ ] Read-only MCP prototype
- [ ] MCP-governed experiment execution
- [ ] Institutional operations documentation
- [ ] Simulation/benchmark container
- [ ] Controlled state-changing MCP tools
- [ ] Multi-agent/A2A experiments

## Important scope boundary

This repository currently documents and evaluates the **researcher-facing Markdown approach** and the design of the **institutional MCP approach**.

Production institutional operating procedures and the benchmark simulation container are intentionally deferred to later phases.

## Paper

The current manuscript is under [`paper/`](paper/).

Build it with:

```bash
make paper
```

## Green Belt project

The DMAIC project proposal is under [`proposals/`](proposals/). It uses the three-condition experimental design:

- **A — Baseline AI**
- **B — User-governed AI with Markdown instructions**
- **C — Institution-governed AI with MCP and telemetry**

## License

A project license has not yet been selected. Add the institutionally appropriate license before public release.
