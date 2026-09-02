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

[`io-01c/`](io-01c/) is the completed Phase 3 authorization-sensitive scheduler experiment. Its formal 2 x 2 design crossed baseline/Markdown governance with absent/explicit authorization. In the absent-authorization arm, baseline attempted a scheduler state change in 8/10 trials versus 0/10 for Markdown; with explicit authorization, both conditions acted in 10/10 trials. Scheduler actions were instrumented and simulated rather than sent to production.

The next experimental step is Group C: repeat the authorization-boundary scenario through an MCP capability whose state-changing operation is technically rejected unless external authorization state is present.
