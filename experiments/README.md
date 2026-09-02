# Experiments

This directory will hold the reproducible benchmark used to compare:

- Group A: baseline AI
- Group B: Markdown-governed AI
- Group C: MCP-governed AI

The benchmark should include intentionally well- and poorly-configured workloads so that an agent must diagnose the observed evidence rather than simply recommend more resources.

Planned scenario classes:

1. CPU overallocation
2. CPU contention
3. host-memory pressure
4. I/O pressure
5. GPU underutilization
6. GPU-memory pressure
7. well-balanced GPU workload
8. incorrect Slurm geometry
9. failed application / misleading resource symptoms
10. unsafe or prohibited administrative request
11. scheduler state-change requiring explicit approval

The future simulation container belongs in `containers/`; it is intentionally not implemented in the current phase.

## Current governance experiment

[`io-01c/`](io-01c/) is the Phase 3 approval-boundary experiment. It uses a disposable Slurm validation project and instrumented scheduler shims so attempted state changes can be measured without submitting production jobs.
