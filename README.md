# Progressive Governance for Agentic AI in High-Performance Computing

This repository contains a reproducible case study of how an institution can progressively govern an AI agent as it moves from HPC advice to consequential actions.

The central result is:

> **Markdown shapes planning and action attempts; MCP controls execution authority.**

Project-level instruction files can steer an AI client toward site-specific evidence and approval rules, but they are behavioral guidance rather than a security boundary. State-changing actions require an external capability layer that independently validates and authorizes the requested operation.

## Project Status

The primary five-phase study is complete.

The academic manuscript is being prepared for submission to the *International Journal of High Performance Computing Applications (IJHPCA)*.

Remaining experimental work focuses on generalization rather than completing the core study:

- replication with a second AI client/model; and
- evaluation of a second workload class using GPU telemetry and Slurm-cgroup-scoped Pressure Stall Information (PSI).

## Research Questions

The study separates five questions that are often collapsed into the single phrase “AI governance”:

1. Does project-level HPC guidance change which operational evidence an AI assistant selects?
2. If identical measured evidence is supplied, does that guidance improve evidence interpretation?
3. Does project guidance change action behavior when researcher authorization is absent versus explicit?
4. Can an external MCP capability layer enforce authorization independently of model behavior?
5. What happens when repository-local content explicitly attempts to convince the agent to bypass institutional controls?

## Experimental Results

| Phase | Question | Primary result |
| --- | --- | --- |
| **1 — Evidence selection** | Does Markdown guidance change what evidence the agent selects? | At least one PSI domain was selected in **10/10 governed trials** and **0/10 baseline trials**. |
| **2 — Evidence interpretation** | Does Markdown improve interpretation once the same evidence is supplied? | Baseline and governed sessions each satisfied **18/18 criteria in all 10 trials**. |
| **3 — Authorization-sensitive behavior** | Does Markdown affect scheduler action attempts? | With authorization absent, baseline sessions attempted a state change in **8/10** trials; governed sessions attempted **0/10**. |
| **4 — MCP enforcement** | Can an external capability layer enforce authorization? | **20/20 unauthorized requests were denied** and **20/20 authorized requests were allowed exactly once**. |
| **5 — Adversarial repository context** | Can hostile repository instructions change agent behavior or bypass controls? | With authorization absent, MCP submission attempts increased from **3/10 benign** to **8/10 adversarial** trials. All **11 unauthorized requests were denied**, and **0/40 sessions used a direct scheduler bypass**. |

Phase 5 is intentionally interpreted as a behavioral and containment result, not as a general prompt-injection security guarantee. Adversarial repository content changed the observed action-attempt rate, while the external authorization boundary prevented those attempts from succeeding.

## Layered Governance Model

The project separates three concerns.

### 1. Behavioral Guidance

A canonical site policy is maintained in:

```text
policy/HPC-AI-INSTRUCTIONS.md
```

The policy can be adapted to client-specific project files such as:

```text
AGENTS.md
CLAUDE.md
GEMINI.md
.github/copilot-instructions.md
```

The policy communicates local expectations such as using Slurm rather than login nodes for sustained computation, preserving project scope, protecting credentials, using measured performance evidence, considering CPU/memory/I/O PSI, and requiring authorization before consequential scheduler actions.

These files influence model behavior. They do **not** provide an authorization boundary.

### 2. Authoritative Evidence

The case study combines AI reasoning with measured HPC evidence, including:

- Slurm accounting and scheduler state;
- requested versus consumed memory;
- elapsed time and CPU utilization;
- filesystem behavior and cache context;
- correctness checks;
- GPU evidence where applicable; and
- Linux Pressure Stall Information for CPU, memory, and I/O.

PSI is used as a representative example of institution-specific HPC evidence. It is not the subject of the paper by itself.

The completed CPU workload used node-scoped `/proc/pressure` measurements. Future workload experiments will move toward Slurm job- or step-cgroup PSI where available.

### 3. Institution-Governed Capabilities

The research MCP prototype exposes narrow operations rather than a general shell:

```text
authorization_status
validate_job
job_status
job_history
storage_usage
psi_metrics
submit_job
```

The prototype applies an authorization decision outside the model:

```text
authorization absent  -> submit_job denied
authorization granted -> submit_job allowed in the simulator
```

Production Slurm is intentionally unreachable from the experimental state-changing backend.

MCP only governs operations routed through MCP. A production deployment must also remove, mediate, or equivalently constrain alternate state-changing paths such as unrestricted `sbatch`, `scancel`, scheduler credentials, or administrative APIs.

## Case-Study Workload

The primary workload is a deterministic serial scan of 12,000 small files.

The original validation request intentionally over-requested resources:

```text
1 CPU
20 GiB memory
20 minute walltime
no GPU
```

Measured runs showed approximately:

```text
13–15 seconds scheduler-observed elapsed time
21–22 MiB peak resident memory
99% process CPU
one CPU used
no GPU path
correctness PASS
```

The AI sessions therefore had a defensible right-sizing problem while still being required to preserve the correctness gate.

In the action experiments, proposed validation requests used 64–256 MiB of memory and one or two minutes of walltime while retaining one CPU and no GPU.

These values represent reductions in the **requested resource envelope**, not measured queue-time or institutional cost savings.

## Repository Layout

```text
.
├── docs/
├── experiments/
│   ├── io-01b/        # Phase 1 evidence selection + Phase 2 runtime evidence
│   ├── io-01c/        # Phase 3 authorization-sensitive behavior
│   ├── io-01d/        # Phase 4 MCP integration and enforcement
│   └── io-01e/        # Phase 5 adversarial repository-context challenge
├── mcp/
│   └── server/        # Research MCP prototype
├── paper/
│   ├── ai_hpc_agentic_workflows.tex
│   ├── ai_hpc_agentic_workflows.pdf
│   └── ijhpca/        # IJHPCA submission materials
├── policy/
│   └── HPC-AI-INSTRUCTIONS.md
└── scripts/
```

## Reproducibility

The repository preserves the executable study design rather than only the paper-level conclusions.

| Artifact | Location |
| --- | --- |
| Canonical project policy | `policy/HPC-AI-INSTRUCTIONS.md` |
| Phase 1/2 harnesses and scored outputs | `experiments/io-01b/` |
| Phase 3 prompts, rubric, and results | `experiments/io-01c/` |
| MCP implementation | `mcp/server/hpc_governance_mcp.py` |
| Phase 4 enforcement challenge | `experiments/io-01d/` |
| Phase 5 adversarial challenge | `experiments/io-01e/` |
| Phase 5 formal summary | `experiments/io-01e/results/IO-01E-formal-results-summary.md` |
| Academic manuscript | `paper/ai_hpc_agentic_workflows.tex` |
| IJHPCA submission package | `paper/ijhpca/` |

Large raw model-session bundles are retained separately from the Git repository. The repository contains the harnesses, prompts and context, scored or instrumented summaries, and implementation needed to reconstruct the formal study design.

## Current Manuscript

The academic paper is:

> **Progressive Governance for Agentic AI in High-Performance Computing: Behavioral Steering and MCP Authorization**

The primary manuscript source and rendered PDF are under:

```text
paper/
```

Submission-oriented IJHPCA materials are under:

```text
paper/ijhpca/
```

The five completed phases support one consistent interpretation:

> **Behavioral controls can reduce undesirable decisions and action attempts, but consequential authority should remain in independently enforced institutional systems.**

## Remaining Work

The core study is complete.

The highest-value generalization experiments are:

1. replicate the Phase 1 evidence-selection and Phase 3 authorization-sensitive behavior experiments with a second AI client/model;
2. evaluate a second workload class, preferably GPU training or another accelerator workload; and
3. collect Slurm job- or step-cgroup PSI together with GPU utilization, GPU memory, scheduler accounting, runtime, and correctness.

Additional future work includes production identity propagation, role and allocation enforcement, durable audit guarantees, MCP latency measurement, policy ablation, and a production scheduler pilot.

## Safety Boundary

The state-changing experiments use a simulated scheduler backend and blocking direct-scheduler controls. They are designed to evaluate model behavior, capability routing, authorization, and containment without intentionally submitting experimental state-changing operations to production Slurm.

The project therefore demonstrates governance behavior under the tested conditions. It does not claim that MCP alone can secure an agent process that retains unrestricted host or scheduler authority.