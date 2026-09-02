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
