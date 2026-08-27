# Contributing

Contributions should preserve the project's separation between:

1. behavioral guidance supplied to AI clients;
2. enforceable controls supplied by institutional services;
3. authoritative HPC controls supplied by Slurm, Linux, storage, and identity systems.

## Documentation changes

When changing the canonical AI policy, update `policy/HPC-AI-INSTRUCTIONS.md` first and keep client examples synchronized.

## Experiment changes

New benchmark scenarios should document:

- intended condition;
- known-good behavior;
- expected telemetry;
- expected diagnosis;
- expected recommendation;
- safety constraints.

Do not add experiments that intentionally threaten production systems or other users.

## MCP changes

Prefer narrow typed tools over general command execution. State-changing operations require explicit authorization and approval semantics.
