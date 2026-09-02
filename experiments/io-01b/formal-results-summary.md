# IO-01B Formal Static A/B Result

## Experiment

- Experiment: `IO-01B-formal`
- Host: `chaosmonkey.rc.rit.edu`
- Codex CLI: `0.149.1`
- Prompt SHA-256: `755a5b6a90fbfc7ff8bd839dcb4cab34d27bfff15306242901cbaaf97ca75a37`
- Policy SHA-256: `0dc137c8361c739a21df3064dd5b3503aa14f1e42c47acb782094b601c76419d`
- Group A: no project `AGENTS.md`
- Group B: same workload and prompt with the HPC `AGENTS.md` at the project root

## Score

Two rubric items were excluded from the percentage: GPU telemetry was not applicable to this CPU/I/O workload, and approval behavior was not testable because the prompt itself prohibited state-changing actions.

- Baseline: **13/17 = 76.5%**
- Markdown-governed: **16/17 = 94.1%**
- Raw difference: **+3 criteria / +17.6 percentage points**

All three gained criteria were explicit PSI coverage:

- CPU PSI, including `avg10`, `avg60`, and `avg300`
- memory PSI, including `avg10`, `avg60`, and `avg300`
- I/O PSI, including `avg10`, `avg60`, and `avg300`

The baseline already performed strongly on general HPC diagnosis. Both conditions identified the small-file metadata problem, oversized memory requests, broken Slurm array semantics, inappropriate GPU use, correctness requirements, Slurm accounting, filesystem evidence, and repeated validation. Therefore, this single pair supports a **targeted policy effect**, not a claim that Markdown governance generally transforms HPC reasoning.

Because CPU, memory, and I/O PSI are three closely related rubric items driven by one policy section, the +17.6-point raw improvement should not be interpreted as three independent effects. Collapsing the three PSI rows into one composite criterion gives:

- Baseline: **13/15 = 86.7%**
- Markdown-governed: **14/15 = 93.3%**
- Conservative difference: **+6.7 percentage points**

## Interpretation

This run provides evidence that the site instruction file can inject institution-specific performance observability into an otherwise capable general HPC analysis. The strongest attributable difference is that Group B explicitly incorporated Linux Pressure Stall Information for CPU, memory, and I/O, including the site's preferred `avg10`, `avg60`, and `avg300` windows, whereas Group A did not mention PSI.

The experiment does **not** yet establish statistical significance. It is one paired observation from one Codex version/model configuration. Formal analysis should use repeated fresh sessions with alternating A/B order.

## Next experiment

Run 5-10 fresh paired static trials of IO-01B. Alternate run order (`A→B`, then `B→A`) to reduce temporal/model-order effects. Preserve each response, CLI version, prompt hash, policy hash, and run timestamp. Score each response independently with the same frozen rubric before moving to runtime evidence.

A separate governance scenario is required to test the approval criterion. The static prompt explicitly prohibited file changes and job submission, so this trial cannot measure whether `AGENTS.md` causes Codex to request researcher approval before a consequential action.
