# IO-01B Phase 2 Corrected Runtime Evidence — 2026-09-02

## Disposition

The corrected Phase 2 runtime collection (`20260902_155610`) is suitable to freeze as the measured evidence source for the next baseline-versus-Markdown AI comparison.

The run used the corrected researcher-controlled IO-01B small-file measurement harness with:

- 12,000 deterministic files;
- 30 scans per measurement job;
- five sequential measurement jobs;
- one CPU per job;
- a deliberately generous 20 GiB memory request;
- CPU, memory, and I/O PSI sampling from `/proc/pressure`;
- `/usr/bin/time -v`;
- Slurm accounting;
- checksum validation.

All five measurement jobs completed with exit code `0:0`, and every workload result reported `correctness=PASS`.

## Dataset

- Files: **12,000**
- Logical bytes per scan: **30,045,829**
- Logical bytes processed per measurement: **901,374,870**
- Dataset checksum: `a2885e4ffa9e2e487e5656674d320d8f00fc14881456b9ba306f60db801faf11`

## Five-run summary

| Run | Scan seconds | Effective MiB/s | Peak RSS (KiB) | CPU | PSI samples |
|---:|---:|---:|---:|---:|---:|
| 1 | 11.511 | 74.677 | 21,844 | 99% | 25 |
| 2 | 11.566 | 74.321 | 21,840 | 99% | 25 |
| 3 | 11.593 | 74.147 | 21,844 | 99% | 25 |
| 4 | 11.542 | 74.477 | 21,776 | 99% | 25 |
| 5 | 11.512 | 74.673 | 21,844 | 99% | 25 |

Aggregate:

- Median scan time: **11.542 s**
- Mean scan time: **11.545 s**
- Scan-time coefficient of variation: **0.31%**
- Median effective logical throughput: **74.477 MiB/s**
- Largest `/usr/bin/time -v` RSS: **21,844 KiB**
- Slurm measurement memory request: **20 GiB**
- Requested memory / largest measured process RSS: approximately **960x**

The resource evidence strongly supports memory right-sizing, while the one-CPU allocation is already well matched to the serial workload.

## PSI observations

Each run contains 25 valid PSI samples.

### CPU

- `cpu some avg10` mean across runs: approximately **8.95%**
- maximum observed `cpu some avg10`: **9.02%**
- CPU `full` remained **0**
- each workload process still received **99% CPU**

The sampler reads `/proc/pressure`, so this pressure is node-level rather than uniquely attributable to the benchmark process. The combination of nonzero CPU `some`, zero CPU `full`, and 99% process CPU makes this a useful interpretation test: the signal should be acknowledged but not treated as proof that the job needs additional CPUs.

### Memory

Memory `some` and `full` PSI remained zero throughout the measurement windows. This is consistent with the very small observed RSS and argues against memory pressure.

### I/O

I/O PSI was effectively zero. Cumulative deltas were tiny, and `avg10` was zero or at most 0.01 in the sampled runs.

`/usr/bin/time -v` reported zero filesystem inputs for the repeated scans. Because the same small dataset was scanned 30 times on the same node after preparation, these results should not be interpreted as a clean measurement of physical Ceph read bandwidth. They are still valid evidence about the corrected small-file scan behavior under warm/page-cache conditions.

## Interpretation target for the AI experiment

The next experiment should test whether the assistant can:

1. identify the extreme 20 GiB memory over-request;
2. keep the workload at one CPU rather than reacting to node-level CPU PSI by adding CPUs;
3. use zero memory PSI as supporting evidence for memory right-sizing;
4. use near-zero I/O PSI without claiming that shared-storage performance has been fully characterized;
5. recognize that zero filesystem inputs and repeated scans limit physical-storage conclusions;
6. preserve checksum/correctness requirements;
7. recommend additional cold-cache/first-pass or storage-specific evidence before changing production storage strategy;
8. make site-qualified rather than absolute resource recommendations.

## Next experiment

Run ten fresh paired evidence-analysis trials:

- **A:** identical corrected measurement harness + identical evidence, no project `AGENTS.md`;
- **B:** identical corrected measurement harness + identical evidence, canonical HPC `AGENTS.md`.

Alternate A→B and B→A order. No job submission or workload execution is permitted during the AI analysis.

The evidence-phase prompt intentionally does not name PSI. Both conditions can inspect the same evidence files; the outcome is whether they select and interpret the measured signals appropriately.
