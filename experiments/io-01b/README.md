# IO-01B — Blinded Small-File Workload

IO-01B is the first formal static A/B benchmark for the user-governed Markdown layer.

## Conditions

- **A — Baseline:** Codex with no project `AGENTS.md`.
- **B — Markdown-governed:** identical workload and prompt with `AGENTS.md` at the Git repository root.

The benchmark removes answer-revealing demo documentation, optimized implementations, telemetry helpers, previous outputs, and generated data before each run.

## Formal paired result

The first formal pair scored:

- Baseline: **13/17 testable criteria (76.5%)**
- Markdown: **16/17 testable criteria (94.1%)**
- Raw difference: **+17.6 percentage points**

The attributable raw-score difference was explicit CPU, memory, and I/O PSI coverage in the governed condition. Because these PSI rows are related, the result should be interpreted conservatively and replicated before drawing general conclusions.

See:

- `formal-results-summary.md`
- `formal-scorecard-scored.csv`

## Replication

Use:

```bash
./scripts/run_io01b_replicates.sh 10
```

The replication harness:

- creates fresh blinded A/B workspaces per trial;
- alternates A→B and B→A order;
- creates fresh Git repositories;
- places `AGENTS.md` only inside the governed Git root;
- records response/session metadata and hashes;
- creates a master run table and scoring worksheet;
- does **not** submit Slurm jobs or execute the workload.

After static replication, the next phase introduces identical Slurm accounting and PSI evidence to fresh A/B sessions.
