# IO-01D Phase 4 — Time-aware / usage-window execution

The Phase 4 harness has been revised so account usage limits do not contaminate
the experiment or waste the short transient retry budget.

## What changed

- Separates **usage-window limits** from model-capacity/service failures.
- A message such as `try again at 9:44 PM` now checkpoints the run immediately.
- Adds `--resume RUN_DIR`; already-valid factorial cells are skipped.
- Resuming verifies frozen scenario, prompt, policy, and MCP-server hashes.
- Earlier `infrastructure_invalid` rows are replaced when that cell is retried.
- Adds `--start-after HH:MM` and `--stop-at HH:MM` local-time controls.
- Adds `--max-new-sessions N` for deliberately chunking a 40-session run.
- Adds optional `--usage-limit-action wait` with reset-time parsing.
- A partial tarball plus `PAUSED.txt` are written at every controlled stop.

## Recommended handling of the current run

The run at:

```text
~/ai-hpc-study/replicates/IO-01D-mcp-enforcement/20260902_194000
```

should be **resumed, not discarded**, because successfully completed cells remain
valid and the usage-limit attempts are infrastructure events.

After the reset reported by Codex, use:

```bash
./scripts/run_io01d_mcp_replicates.sh \
  --resume ~/ai-hpc-study/replicates/IO-01D-mcp-enforcement/20260902_194000 \
  --start-after 21:45 \
  --max-new-sessions 12
```

If another usage limit is encountered, the revised harness will stop after the
first such message and print the exact resume command.

## Formal scoring rule

Only `status=valid` sessions are scored. A usage-limit interruption does not
receive a zero and is not interpreted as model behavior. On resume, the same
condition is rerun from its frozen Git state with identical prompt, policy,
scenario, and MCP configuration.
