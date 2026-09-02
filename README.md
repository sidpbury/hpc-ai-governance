# HPC AI Governance

A research-computing project for evaluating and deploying AI assistance in high-performance computing (HPC) through progressive governance and evidence-based integration.

The project now covers three stages:

1. **User-governed AI** — project/site Markdown instruction files for Claude Code, Codex, Gemini CLI, and GitHub Copilot.
2. **Institution-governed AI** — a narrow, authenticated Model Context Protocol (MCP) service exposing HPC context, telemetry, validation, and later controlled actions.
3. **Future multi-agent integration** — optional A2A coordination between specialized research-computing agents after the MCP boundary is mature.

Slurm, Linux permissions, allocation/account policy, storage ACLs, identity, and institutional security controls remain authoritative.

## Project hypothesis

A progressive integration model can improve HPC usability and resource efficiency while preserving governance:

**Baseline AI → Markdown-governed AI → MCP-governed AI + telemetry → optional A2A specialization**

The evaluation measures:

- Slurm correctness;
- time to successful execution;
- policy compliance;
- blocked unsafe actions;
- CPU and memory efficiency;
- GPU utilization and GPU memory efficiency;
- CPU, memory, and I/O Pressure Stall Information (PSI);
- failed submissions and human interventions.

## Repository layout

```text
hpc-ai-governance/
├── README.md
├── paper/
├── proposals/
├── docs/
│   ├── user-guide.md
│   ├── architecture.md
│   ├── evaluation.md
│   └── ai-clients-mcp-a2a.md
├── policy/
│   ├── HPC-AI-INSTRUCTIONS.md
│   └── clients/
├── scripts/
│   ├── install-policy.sh
│   ├── run_io01b_replicates.sh
│   ├── submit_io01b_runtime.sh
│   ├── collect_io01b_evidence.sh
│   └── run_io01b_evidence_replicates.sh
├── experiments/
│   ├── benchmark-plan.md
│   ├── metrics-schema.csv
│   ├── scenarios/
│   └── io-01b/
│       ├── README.md
│       ├── formal-results-summary.md
│       ├── formal-scorecard-scored.csv
│       ├── replication-results-summary.md
│       ├── replication-scorecard-scored.csv
│       ├── replication-criterion-summary.csv
│       ├── phase2-evidence-replication-results-summary.md
│       ├── phase2-evidence-replication-scorecard-scored.csv
│       ├── phase2-evidence-replication-criterion-summary.csv
│       └── runtime/
├── mcp/
│   ├── README.md
│   └── roadmap.md
├── containers/
└── institutional/
```

## User-level AI clients

The canonical policy is `policy/HPC-AI-INSTRUCTIONS.md`.

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

Markdown policy is a **behavioral guardrail**, not a security boundary.

## MCP and A2A

The institution-governed MCP layer exposes narrow tools such as:

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
```

Read-only capabilities come first. State-changing operations such as `submit_job()` and `cancel_job()` require server-side authorization, validation, audit logging, and explicit human approval.

A2A is complementary and later-stage:

> **MCP connects agents to capabilities. A2A connects agents to other agents.**

See [`docs/ai-clients-mcp-a2a.md`](docs/ai-clients-mcp-a2a.md) and [`mcp/roadmap.md`](mcp/roadmap.md).

## Experimental status

### Completed

- [x] Journal-paper architecture and literature review
- [x] Green Belt/DMAIC proposal
- [x] Canonical HPC Markdown policy
- [x] Researcher user guide
- [x] Initial benchmark design
- [x] IO-01 pilot harness validation
- [x] IO-01B blinded formal A/B pair
- [x] Formal scoring rubric
- [x] 10-pair static replication harness

### IO-01B Phase 1 replicated result

Ten blinded paired static trials are complete.

| Measure | Baseline | Markdown-governed |
|---|---:|---:|
| Paired trials | 10 | 10 |
| Mean passed criteria | 13.0/17 | 15.9/17 |
| Mean score | 76.5% | 93.5% |
| Raw difference | — | **+17.1 points** |
| Pairwise wins | — | **10/10** |

The repeatable effect is concentrated in the site-selected telemetry layer: CPU PSI appeared in 9/10 governed responses versus 0/10 baseline; memory PSI and I/O PSI appeared in 10/10 governed responses versus 0/10 baseline. Generic HPC diagnosis was already strong in both conditions.

Because the three PSI rows represent one correlated policy concept, the conservative composite analysis is **86.7% baseline vs. 93.3% governed (+6.7 points)**. See [`experiments/io-01b/`](experiments/io-01b/).

### IO-01B Phase 2 evidence-interpretation result

Ten fresh paired evidence-analysis trials supplied the **same corrected Slurm, timing, correctness, and PSI evidence** to both conditions. The result was a ceiling-level tie:

| Measure | Baseline | Markdown-governed |
|---|---:|---:|
| Paired trials | 10 | 10 |
| Mean passed criteria | 18.0/18 | 18.0/18 |
| Mean score | 100.0% | 100.0% |
| Pairwise result | 10 ties | 10 ties |

Both conditions correctly interpreted the 20 GiB memory over-request, retained one CPU, rejected GPU use, recognized the warm/page-cache limitation, distinguished logical throughput from physical Ceph bandwidth, and treated node-level CPU PSI cautiously.

The combined Phase 1/Phase 2 interpretation is therefore narrower and more useful: **Markdown governance changed evidence-selection behavior, but once authoritative evidence was supplied identically, no additional interpretation effect was detectable in this scenario.** This ceiling result does not establish formal equivalence. See [`experiments/io-01b/`](experiments/io-01b/).

### IO-01C Phase 3 approval-boundary experiment

The next experiment moves from evidence selection/interpretation to **state-changing behavior**. IO-01C gives Codex a disposable validation project where the natural next step is a Slurm validation run, but the prompt does not explicitly authorize job submission.

The A/B harness allows edits inside an isolated workspace while replacing scheduler state-changing commands with instrumented simulators. It records whether the assistant attempts `sbatch`, `srun`, `salloc`, `scancel`, or state-changing `scontrol` operations before explicit researcher approval. A guarded Slurm configuration and disabled sandbox network access prevent the experiment from reaching the production controller.

Primary outcomes are approval-boundary recognition, explicit approval request, absence of an unapproved scheduler-action attempt, and presentation of the proposed resource change before scheduler action. See [`experiments/io-01c/`](experiments/io-01c/).

### Next

- [x] Complete and score 10 paired IO-01B static replications
- [x] Run initial Phase 2 researcher-controlled runtime pilot
- [x] Correct PSI schema and site `sacct` field compatibility found by pilot
- [x] Rerun Phase 2 runtime collection with valid PSI telemetry
- [x] Run and score 10 paired Phase 2 evidence-informed A/B trials
- [x] Build IO-01C controlled state-changing/approval harness
- [ ] Run and score 10 paired IO-01C approval trials
- [ ] Validate recommended resource changes experimentally
- [ ] Build read-only MCP prototype
- [ ] Repeat IO-01C with MCP-enforced approval
- [ ] Run broader Group C MCP evaluation
- [ ] Add controlled state-changing MCP tools
- [ ] Evaluate specialized-agent/A2A designs only after MCP is stable

## Paper

The manuscript is under [`paper/`](paper/).

```bash
make paper
```

## Green Belt project

The DMAIC proposal under [`proposals/`](proposals/) uses the three-condition design:

- **A — Baseline AI**
- **B — User-governed AI with Markdown instructions**
- **C — Institution-governed AI with MCP and telemetry**

## License

A project license has not yet been selected. Add the institutionally appropriate license before public release.
