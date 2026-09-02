#!/usr/bin/env bash
set -euo pipefail

[[ $# -eq 1 ]] || { echo "Usage: $0 /path/to/IO-01B/runtime/result-dir" >&2; exit 2; }
RESULT_DIR="$(cd "$1" && pwd)"
JOBIDS="$RESULT_DIR/jobids.tsv"
[[ -f "$JOBIDS" ]] || { echo "ERROR: $JOBIDS not found" >&2; exit 1; }
command -v sacct >/dev/null 2>&1 || { echo "ERROR: sacct not found" >&2; exit 1; }

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNTIME_DIR="$REPO_ROOT/experiments/io-01b/runtime"
EVIDENCE_DIR="$RESULT_DIR/evidence"
mkdir -p "$EVIDENCE_DIR/runs"

mapfile -t ids < <(awk 'NR>1 {print $3}' "$JOBIDS")
joined="$(IFS=,; echo "${ids[*]}")"

# Refuse to freeze the evidence packet while jobs are still active.
active="$(squeue -h -j "$joined" -o '%i %T' 2>/dev/null || true)"
if [[ -n "$active" ]]; then
    echo "ERROR: some jobs are still active:" >&2
    echo "$active" >&2
    exit 1
fi

cp "$RESULT_DIR/experiment-metadata.txt" "$EVIDENCE_DIR/"
cp "$JOBIDS" "$EVIDENCE_DIR/"
cp "$RESULT_DIR/dataset-metadata.json" "$EVIDENCE_DIR/" 2>/dev/null || true

# Prefer the broad accounting fields; fall back if the site does not expose all.
if ! sacct -n -P -j "$joined" \
    --format=JobID,JobName,State,ExitCode,Elapsed,Timelimit,AllocCPUS,ReqMem,MaxRSS,MaxVMSize,CPUTime,TotalCPU,MaxDiskRead,MaxDiskWrite,NodeList \
    > "$EVIDENCE_DIR/sacct.psv" 2>"$EVIDENCE_DIR/sacct.err"; then
    sacct -n -P -j "$joined" \
        --format=JobID,JobName,State,ExitCode,Elapsed,AllocCPUS,ReqMem,MaxRSS,CPUTime,TotalCPU,NodeList \
        > "$EVIDENCE_DIR/sacct.psv"
fi

for run_dir in "$RESULT_DIR"/run-[0-9][0-9]; do
    [[ -d "$run_dir" ]] || continue
    dest="$EVIDENCE_DIR/runs/$(basename "$run_dir")"
    mkdir -p "$dest"
    for f in workload.json time-v.txt psi.csv run-metadata.txt evidence-summary.md; do
        [[ -f "$run_dir/$f" ]] && cp "$run_dir/$f" "$dest/"
    done
    python3 "$RUNTIME_DIR/summarize_evidence.py" \
        "$run_dir" --output "$dest/evidence-summary.md"
done

cat > "$EVIDENCE_DIR/README.md" <<'EOF'
# IO-01B Phase 2 Evidence Packet

This directory contains measured evidence only. It is intended to be supplied
unchanged to both the baseline and Markdown-governed AI conditions.

Contents:

- `experiment-metadata.txt` — submission configuration and source commit.
- `jobids.tsv` — preparation and sequential measurement job IDs.
- `sacct.psv` — scheduler accounting for the jobs/steps available at collection time.
- `dataset-metadata.json` — immutable dataset count, byte count, and checksum.
- `runs/run-XX/workload.json` — verified workload result.
- `runs/run-XX/time-v.txt` — `/usr/bin/time -v` evidence.
- `runs/run-XX/psi.csv` — raw CPU/memory/I/O PSI samples.
- `runs/run-XX/evidence-summary.md` — neutral summary of that run.

Do not add recommendations or optimized implementations to this packet before
the Phase 2 A/B analysis is complete.
EOF

BUNDLE="${RESULT_DIR}/IO-01B-Phase2-evidence.tar.gz"
tar -czf "$BUNDLE" -C "$RESULT_DIR" evidence

echo "Evidence directory: $EVIDENCE_DIR"
echo "Evidence bundle:    $BUNDLE"
