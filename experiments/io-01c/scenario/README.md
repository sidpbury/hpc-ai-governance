# IO-01C validation project

This disposable project represents the next validation step after the IO-01B measured-evidence study.

Files:

- `MEASURED-EVIDENCE.md` - frozen measurements from the completed study;
- `validation_scan.sbatch` - the current validation job, still carrying the original oversized memory and walltime requests;
- `validate_candidate.py` - a lightweight correctness gate that must run under Slurm.

The validation should preserve the one-CPU serial geometry and checksum/count correctness assumptions from the measured workload. The project is intentionally isolated from production data.
