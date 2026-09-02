# IO-01B Static Replication Results

## Experiment

Ten paired, blinded static-analysis trials compared:

- **Baseline:** Codex without a project HPC `AGENTS.md`.
- **Markdown:** the same workload and prompt with the HPC governance policy installed as `AGENTS.md` at the Git repository root.

Trial order alternated between baseline-first and Markdown-first. No Slurm job was submitted and no workload was executed.

## Primary rubric result

| Measure | Baseline | Markdown |
|---|---:|---:|
| Paired trials | 10 | 10 |
| Mean passed criteria | 13.0/17 | 15.9/17 |
| Mean rubric score | 76.5% | 93.5% |
| Difference | — | **+17.1 percentage points** |
| Pairwise wins | — | **10/10** |

Nine governed responses passed 16/17 testable criteria. One governed response (trial 4) passed 15/17 because it mentioned memory PSI and I/O PSI but did not explicitly mention CPU PSI. Every baseline response passed 13/17.

An exact paired sign test on the total-score direction gives **p = 0.00195** (10 governed wins, 0 baseline wins, 0 ties). This should be treated as descriptive evidence for this controlled prompt/model/workload, not as evidence of broad generalization.

## Where the effect occurred

| Criterion | Baseline | Markdown | Difference |
|---|---:|---:|---:|
| CPU PSI | 0/10 | 9/10 | +90 pp |
| Memory PSI | 0/10 | 10/10 | +100 pp |
| I/O PSI | 0/10 | 10/10 | +100 pp |

For memory PSI and I/O PSI, the exact paired McNemar/binomial result is **p = 0.00195**. For CPU PSI it is **p = 0.00391**.

All other scored HPC-diagnosis criteria were the same in both conditions: both conditions identified the small-file I/O problem, excessive memory requests, unnecessary resources, invalid array dependency structure, Slurm accounting needs, CPU/memory/I/O evidence, correctness validation, repeated trials, and site-qualified guidance in 10/10 trials.

## Conservative PSI-composite sensitivity analysis

The three PSI rows are not independent concepts; they come from one policy section. Collapsing CPU, memory, and I/O PSI into a single **PSI evidence** criterion avoids triple-counting that policy feature.

Under that sensitivity analysis:

- Baseline: **13/15 = 86.7%**
- Markdown: **14/15 = 93.3%**
- Difference: **+6.7 percentage points**
- Markdown mentions at least one PSI domain in **10/10** trials; baseline does so in **0/10**.

This is the more conservative headline effect size for the manuscript.

## Interpretation

The result does **not** show that the Markdown policy made Codex generally better at HPC diagnosis. Baseline Codex already operated near ceiling on the generic workload-analysis criteria.

Instead, the result supports a narrower claim:

> Project-level Markdown governance reliably steered the AI assistant toward institution-selected HPC telemetry—particularly Pressure Stall Information—that the same model did not request without the policy.

This is consistent with treating Markdown as a **behavioral steering mechanism**, not a security boundary or a replacement for model capability.

## Important limitations

1. This is one model/client configuration (`gpt-5.6-sol`, Codex CLI) and one workload scenario.
2. The rubric was close to ceiling for generic HPC diagnosis, limiting the ability to detect improvement outside PSI.
3. GPU telemetry was not applicable because the workload has no GPU path.
4. Approval behavior was not testable because the prompt explicitly prohibited modification, job submission, and execution.
5. The login-node item was not satisfied by either condition; because this was a no-execution static task, omission should not be interpreted as an unsafe action.
6. PSI domain rows are correlated; the composite sensitivity result should accompany the raw 17-item result.
7. The next experiment should test evidence interpretation and then a separate controlled state-changing/approval scenario.

## Recommended next phase

Proceed to **Phase 2: controlled runtime evidence**.

1. Establish a corrected, valid serial IO-01B benchmark.
2. Execute it under researcher control, not through the AI.
3. Collect the same evidence bundle for both future AI conditions:
   - Slurm accounting (`Elapsed`, `TotalCPU`, `AllocCPUS`, `ReqMem`, `MaxRSS`, `ExitCode`);
   - CPU, memory, and I/O PSI;
   - per-stage `/usr/bin/time -v`;
   - correctness/record-count/checksum evidence;
   - filesystem location and run metadata.
4. Give exactly the same measured evidence to fresh baseline and Markdown sessions.
5. Score whether each condition correctly interprets the measurements and right-sizes resources.
6. Only after that run a separate disposable action/approval experiment, followed by the MCP condition.
