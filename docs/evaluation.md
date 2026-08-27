# Evaluation Framework

## Experimental groups

### Group A — Baseline AI
General-purpose AI assistant without site-specific HPC instructions.

### Group B — User-governed AI
The same assistant with the canonical HPC Markdown policy.

### Group C — Institution-governed AI
Markdown guidance plus an authenticated MCP service that provides site context, telemetry, validation, and enforceable policy.

## Research questions

1. Does Markdown guidance improve HPC-specific behavioral compliance?
2. Does MCP enforcement prevent prohibited actions when the model fails to comply?
3. Does site context improve Slurm and software recommendations?
4. Do scheduler history, GPU telemetry, and PSI improve resource recommendations?
5. Does progressive integration reduce researcher time-to-success and failed submissions?

## Outcome measures

### Correctness
- valid Slurm directives;
- appropriate partition/resource selection;
- correct interpretation of job state and exit code;
- correct software/environment selection.

### Researcher effort
- time to successful execution;
- number of failed attempts;
- number of manual documentation lookups;
- number of staff interventions.

### Allocation efficiency

CPU efficiency:

```text
CPU time consumed / CPU time allocated
```

Memory efficiency:

```text
peak memory used / memory requested
```

GPU memory efficiency:

```text
peak GPU memory used / available GPU memory
```

### GPU measures
- mean GPU utilization;
- median GPU utilization;
- peak GPU utilization;
- peak GPU memory use;
- power utilization where available;
- throttling indicators where available.

### Pressure Stall Information
Collect CPU, memory, and I/O PSI where available:

- `avg10`
- `avg60`
- `avg300`
- cumulative `total`
- `some`
- `full` where reported

Avoid reducing PSI to a single threshold. Preserve both short spikes and sustained pressure.

### Governance and security
- behavioral policy compliance rate;
- number of prohibited actions attempted;
- number of prohibited actions blocked;
- approval bypass attempts;
- unauthorized-resource requests;
- unsafe file/credential access attempts.

A key distinction is:

**Instruction compliance** measures whether the model follows the Markdown policy.

**Enforcement effectiveness** measures whether system controls prevent violations even when the model does not follow policy.
