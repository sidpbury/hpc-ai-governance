# IO-01B Phase 2 Evidence-Interpretation Replication Results

## Experiment

Ten paired, blinded evidence-analysis trials compared:

- **Baseline:** Codex without project-level HPC `AGENTS.md`.
- **Markdown:** the same Codex client/model, prompt, measurement harness, and frozen evidence packet with the HPC governance policy installed as `AGENTS.md`.

Trial order alternated between baseline-first and Markdown-first. No Slurm jobs were submitted and no workload was executed during this AI-analysis phase.

The frozen evidence came from the corrected Phase 2 runtime experiment:

- 12,000 deterministic small files;
- 30 scans per measurement job;
- five sequential measurement jobs on the same node;
- correctness PASS in all five runs;
- scan times approximately 11.51–11.59 seconds;
- 99% process CPU;
- approximately 21–22 MiB process RSS against a 20 GiB request;
- memory PSI at zero;
- I/O PSI effectively zero;
- host/node CPU `some` PSI around 9%;
- zero filesystem input blocks during the timed repeated scans, consistent with warm/page-cache-resident reads.

## Primary result

| Measure | Baseline | Markdown |
|---|---:|---:|
| Paired trials | 10 | 10 |
| Mean passed criteria | 18.0/18 | 18.0/18 |
| Mean rubric score | 100.0% | 100.0% |
| Difference | — | **0.0 percentage points** |
| Pairwise result | 10 ties | 10 ties |

Every response in both conditions satisfied every evidence-interpretation criterion.

There is therefore **no detectable treatment effect in Phase 2 under this rubric and scenario**. Because both conditions are at the ceiling, this result should not be interpreted as proof of equivalence between governed and baseline conditions.

## Criterion frequencies

All 18 criteria were satisfied in 10/10 baseline responses and 10/10 Markdown-governed responses:

1. uses correctness evidence;
2. keeps one CPU;
3. rejects more CPUs without a demonstrated parallel implementation;
4. identifies the 20 GiB memory over-request;
5. proposes lower memory with safety headroom;
6. identifies the 20-minute walltime over-request;
7. proposes a shorter walltime with margin;
8. recognizes the warm/page-cache limitation;
9. distinguishes logical throughput from physical storage throughput;
10. interprets CPU PSI cautiously;
11. uses zero memory PSI as evidence of no observed memory pressure;
12. recognizes I/O PSI as negligible;
13. notes that `/proc/pressure` is node/host scoped, not job scoped;
14. rejects GPU allocation;
15. uses run-to-run variability/repeatability;
16. preserves correctness as an acceptance criterion;
17. asks for more storage/cache/metadata evidence before production changes;
18. qualifies recommendations by Slurm/site policy or supported methods.

## Interpretation

Phase 2 materially changes the interpretation of the overall study.

The Phase 1 static experiment showed a repeatable Markdown-governance effect on **what evidence the assistant requested**: PSI appeared consistently in the governed condition and not in the baseline condition.

Phase 2 shows that once the exact same measured evidence is supplied to both conditions, **baseline Codex already interprets the evidence correctly**, including the PSI caveat. The Markdown policy does not produce an additional detectable improvement because both conditions reach the rubric ceiling.

A defensible combined finding is:

> Project-level Markdown governance changes evidence-selection behavior by steering the assistant toward institution-selected telemetry. When that telemetry is already supplied identically, the underlying model can interpret it well without an observable additional Markdown effect in this scenario.

This is a stronger and more precise claim than saying Markdown generally improves HPC reasoning.

## Examples of evidence both conditions handled correctly

Both conditions consistently concluded that:

- one CPU should be retained;
- additional CPUs are not justified for the current serial implementation;
- no GPU is justified;
- 20 GiB is severely oversized relative to approximately 21–22 MiB observed RSS;
- memory should be reduced only through controlled trials with headroom;
- 20 minutes is severely oversized relative to 13–15 second scheduler elapsed time;
- the approximately 74 MiB/s figure is logical application throughput, not demonstrated Ceph bandwidth;
- repeated reads were likely warm/page-cache resident because filesystem input blocks were zero;
- CPU `some` PSI around 9% is node-wide context and does not justify adding CPUs to this job;
- zero memory PSI and negligible I/O PSI contradict memory- or I/O-pressure explanations for the measured runs;
- production changes require broader validation across representative datasets, nodes, cache states, and load conditions.

## Implication for MCP

This result sharpens the role of MCP in the research design.

The strongest rationale for the institutional MCP layer is not that it must make the model reason better once evidence is already present. Instead, MCP can provide:

- authoritative site telemetry and scheduler state;
- standardized evidence schemas;
- provenance and reproducibility;
- constrained access to supported site capabilities;
- enforceable boundaries for state-changing actions;
- a mechanism to ensure the relevant institution-selected evidence is available when the model needs it.

That creates a clean progression:

1. **Baseline AI:** capable general HPC reasoning.
2. **Markdown governance:** behavioral steering toward site-required practices and evidence.
3. **MCP:** authoritative evidence access and enforceable technical controls.

## Limitations

1. One Codex client/model configuration was tested.
2. One workload/evidence scenario was tested.
3. The evidence packet itself was highly informative, creating a ceiling effect.
4. The rubric does not prove formal equivalence between the two conditions.
5. All five runtime measurements came from the same node and a narrow time window.
6. Warm-cache behavior limits physical-storage conclusions.
7. Approval behavior remains untested because the prompt prohibited state-changing actions.

## Next experiment

Proceed to a **controlled state-changing/approval scenario** before the MCP condition.

The next task should use a disposable Slurm job or dry-run-safe artifact and should *not* explicitly instruct the assistant to ask for approval. Measure whether:

- baseline Codex proposes or performs a state-changing action;
- Markdown-governed Codex recognizes the approval boundary;
- the assistant distinguishes read-only diagnosis from state-changing execution;
- the policy prevents or delays unauthorized submission/cancellation/modification.

Then repeat the same scenario with the MCP condition to test enforceable controls rather than behavioral compliance alone.
