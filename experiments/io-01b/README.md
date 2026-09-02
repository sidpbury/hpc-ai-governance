# IO-01B — Blinded Small-File Workload

IO-01B is the first formal benchmark for the user-governed Markdown layer.

## Conditions

- **A — Baseline:** Codex with no project `AGENTS.md`.
- **B — Markdown-governed:** identical workload and prompt with `AGENTS.md` at the Git repository root.

The benchmark removes answer-revealing demo documentation, optimized implementations, telemetry helpers, previous outputs, and generated data before each static run.

## First formal pair

The first valid blinded pair scored:

- Baseline: **13/17 testable criteria (76.5%)**
- Markdown: **16/17 (94.1%)**

That pair motivated replication but is not the primary effect estimate.

See `formal-results-summary.md` and `formal-scorecard-scored.csv`.

## Ten-pair static replication — primary Phase 1 result

Ten fresh paired trials alternated baseline-first and Markdown-first order.

| Measure | Baseline | Markdown-governed |
|---|---:|---:|
| Paired trials | 10 | 10 |
| Mean passed criteria | 13.0/17 | 15.9/17 |
| Mean rubric score | 76.5% | 93.5% |
| Raw difference | — | **+17.1 percentage points** |
| Pairwise wins | — | **10/10** |

The effect was concentrated in the institution-selected PSI evidence layer:

| Criterion | Baseline | Markdown |
|---|---:|---:|
| CPU PSI | 0/10 | 9/10 |
| Memory PSI | 0/10 | 10/10 |
| I/O PSI | 0/10 | 10/10 |

Generic HPC diagnosis was already near ceiling in both conditions. The defensible interpretation is therefore not that Markdown made the model generally better at HPC. Rather, project-level Markdown governance reliably steered the same model toward site-selected telemetry that it otherwise omitted.

Because CPU/memory/I/O PSI are correlated rows from one policy concept, the conservative sensitivity analysis collapses them to one PSI-evidence criterion:

- Baseline: **13/15 (86.7%)**
- Markdown: **14/15 (93.3%)**
- Difference: **+6.7 percentage points**

See:

- `replication-results-summary.md`
- `replication-scorecard-scored.csv`
- `replication-criterion-summary.csv`

## Phase 2 — measured runtime evidence

Phase 2 asks a different question: after receiving **identical real measurements**, does Markdown governance improve evidence interpretation and right-sizing?

The researcher-controlled runtime harness is under [`runtime/`](runtime/). It:

1. creates one validated immutable 12,000-file dataset;
2. runs sequential dependent measurement jobs so benchmark readers do not intentionally contend with one another;
3. preserves a deliberately generous baseline memory request for empirical right-sizing;
4. records `/usr/bin/time -v`, Slurm accounting, correctness, and CPU/memory/I/O PSI;
5. produces a neutral evidence packet for fresh A/B AI sessions.

No AI client submits the runtime jobs in this phase; the researcher controls execution.


### Phase 2 pilot status

The first runtime pilot (`20260902_152030`) completed the corrected workload
and verified checksums in all five measurements, but the PSI collector failed
because the SPORC kernel exposed CPU `full` pressure fields not present in the
initial CSV schema. The pilot is retained for reproducibility but excluded from
the evidence-fed A/B comparison. See `runtime/pilot-20260902.md`.

The corrected harness now validates PSI collection before each measured run,
uses SPORC-compatible `sacct` fields, and defaults to 30 scans per measurement
so the PSI sample series spans a more useful interval.


### Corrected Phase 2 evidence collection

The corrected formal runtime collection (`20260902_155610`) completed five
sequential measurement jobs with valid PSI telemetry and checksum validation.

Key measured facts:

- 30 scans per measurement over 12,000 deterministic files;
- median scan time: **11.542 s**;
- median effective logical throughput: **74.477 MiB/s**;
- peak process RSS: **21,844 KiB** against a **20 GiB** Slurm request;
- approximately **960x** requested-memory to peak-process-RSS ratio;
- process CPU: **99%** in all five runs;
- CPU `some` PSI around **9%**, CPU `full` zero;
- memory PSI zero;
- I/O PSI effectively zero;
- zero filesystem inputs reported by `/usr/bin/time -v`, so physical Ceph
  bandwidth is not established by the repeated warm scans.

See `runtime/corrected-20260902-summary.md`.

The formal evidence-analysis experiment used
`scripts/run_io01b_evidence_replicates.sh` to run fresh paired evidence-analysis
sessions with identical measured evidence and alternating condition order.

## Phase 2 ten-pair evidence-analysis result

Ten paired trials were completed and scored against an 18-item evidence-interpretation rubric.

| Measure | Baseline | Markdown-governed |
|---|---:|---:|
| Paired trials | 10 | 10 |
| Mean passed criteria | 18.0/18 | 18.0/18 |
| Mean rubric score | 100.0% | 100.0% |
| Pairwise result | 10 ties | 10 ties |

All 20 responses correctly handled the measured resource and telemetry evidence, including the severe memory over-request, one-CPU geometry, zero memory pressure, negligible I/O pressure, warm-cache limitation, and the node-level scope of CPU PSI.

The defensible interpretation is **not** that the two conditions have been proven equivalent. The evidence packet was sufficiently informative that both conditions reached the rubric ceiling. The combined result is instead:

> Markdown governance changed what evidence the assistant requested in Phase 1. Once that evidence was supplied identically in Phase 2, baseline Codex could already interpret it correctly, leaving no detectable additional Markdown effect in this scenario.

This result strengthens the rationale for MCP as an authoritative evidence and enforcement layer rather than as a claim that MCP or Markdown must make the underlying model intrinsically better at HPC reasoning.

See:

- `phase2-evidence-replication-results-summary.md`
- `phase2-evidence-replication-scorecard-scored.csv`
- `phase2-evidence-replication-criterion-summary.csv`

The next formal experiment is a controlled **state-changing/approval** scenario, followed by the MCP condition.
