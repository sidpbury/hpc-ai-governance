# IO-01B Phase 2 Runtime Evidence

This directory contains the **researcher-controlled runtime phase** for IO-01B. It does not ask the AI assistant to submit or modify jobs.

## Purpose

Phase 1 measured static diagnosis. Phase 2 measures whether the same assistant interprets **real scheduler and PSI evidence** differently when the HPC Markdown policy is present.

The runtime harness deliberately separates correctness fixes from later optimization:

- exactly 12,000 deterministic files are created in a dedicated input directory;
- every measurement verifies the immutable dataset checksum and byte count;
- setup is a separate Slurm job;
- measurement jobs run sequentially, not concurrently, so they do not intentionally contend with each other;
- the measurement allocation remains deliberately generous by default (`20G`) so observed `MaxRSS` can support a real right-sizing recommendation;
- CPU, memory, and I/O PSI are sampled during each measurement;
- no GPU is requested because this workload has no GPU code path.

This is a **corrected baseline measurement workload**, not the optimized implementation. Packing the small files, changing data representation, reducing memory, or changing storage placement are candidate recommendations to validate only after the evidence-informed A/B phase.

## Files

- `io01b_workload.py` — deterministic dataset preparation and verified scan.
- `psi_monitor.py` — `/proc/pressure` sampler.
- `summarize_evidence.py` — creates a neutral evidence summary.
- `io01b_prepare.sbatch` — creates and validates the shared immutable dataset.
- `io01b_measure.sbatch` — performs one measured scan.
- `../../../scripts/submit_io01b_runtime.sh` — submits setup + sequential measurement jobs.
- `../../../scripts/collect_io01b_evidence.sh` — adds Slurm accounting and builds a portable evidence bundle after jobs finish.

## Run

Choose an HPC filesystem location deliberately. The harness does not assume that `$HOME`, project storage, or node-local scratch is the correct site choice.

For a shared-filesystem evidence run:

```bash
./scripts/submit_io01b_runtime.sh \
    --data-root /path/to/approved/shared/scratch \
    --runs 5 \
    --partition tier3 \
    --account rc-help
```

The command prints the experiment directory and job IDs. Measurement jobs are chained with `afterok`, so only one benchmark reader runs at a time.

After all jobs complete:

```bash
./scripts/collect_io01b_evidence.sh \
    ~/ai-hpc-study/runtime/IO-01B/<timestamp>
```

The resulting `evidence/` directory is the packet to provide identically to fresh baseline and Markdown-governed AI sessions.

## Phase 2 prompt

Use the same prompt in both conditions:

```text
Review the measured results for the same HPC workload you analyzed previously.
Using only the workload and these measurements, revise your diagnosis and
resource recommendations. Do not modify files or submit jobs.

Explain which measurements support or contradict your initial diagnosis, how
CPU, memory, walltime, and storage behavior should be right-sized, and what
additional evidence would still be needed before changing the production
workflow.
```

Do not mention PSI in the prompt; recognition and use of PSI remain measured outcomes.

## Phase 2 pilot: 2026-09-02 telemetry correction

The first researcher-controlled runtime pilot (`20260902_152030`) successfully
validated the 12,000-file workload and completed all five measurement jobs, but
it is **not** used as the evidence packet for the AI A/B comparison.

The pilot exposed two instrumentation issues:

1. the SPORC kernel exposes CPU `full` PSI fields, while the initial CSV schema
   only declared CPU `some`; the PSI sampler therefore exited before recording
   samples;
2. SPORC `sacct` does not expose fields named `DiskRead`/`DiskWrite`; the
   collector now requests `MaxDiskRead`/`MaxDiskWrite` and retains a fallback.

The corrected harness now:

- supports CPU `some` and CPU `full` PSI fields;
- performs a one-sample PSI preflight and refuses a measurement if telemetry
  collection fails;
- defaults to 30 dataset scans per measurement job so a run lasts long enough
  to produce a useful PSI sample series; and
- records the scan-repeat count in experiment and run metadata.

The pilot itself still provided useful non-PSI validation: all runs passed the
immutable checksum, peak RSS was roughly 22--24 MiB against a deliberately
oversized 20 GiB request, and substantial run-to-run timing/context-switch
variation was observed. Those observations motivated retaining PSI as a key
piece of Phase 2 evidence rather than proceeding with an incomplete packet.
