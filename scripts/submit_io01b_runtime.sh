#!/usr/bin/env bash
set -euo pipefail

DATA_ROOT=""
RUNS=5
SCAN_REPEATS=30
PARTITION="tier3"
ACCOUNT="rc-help"
MEASURE_MEM="20G"
MEASURE_TIME="00:20:00"
PREP_MEM="1G"
PREP_TIME="00:20:00"

usage() {
    cat <<'EOF'
Usage:
  submit_io01b_runtime.sh --data-root PATH [options]

Options:
  --runs N             Sequential measurement runs (default: 5)
  --scan-repeats N      Dataset scans per measurement job (default: 30)
  --partition NAME     Slurm partition (default: tier3)
  --account NAME       Slurm account (default: rc-help)
  --measure-mem SIZE   Deliberately generous baseline request (default: 20G)
  --measure-time TIME  Measurement time limit (default: 00:20:00)
  --prep-mem SIZE      Preparation memory request (default: 1G)
  --prep-time TIME     Preparation time limit (default: 00:20:00)
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --data-root) DATA_ROOT="$2"; shift 2 ;;
        --runs) RUNS="$2"; shift 2 ;;
        --scan-repeats) SCAN_REPEATS="$2"; shift 2 ;;
        --partition) PARTITION="$2"; shift 2 ;;
        --account) ACCOUNT="$2"; shift 2 ;;
        --measure-mem) MEASURE_MEM="$2"; shift 2 ;;
        --measure-time) MEASURE_TIME="$2"; shift 2 ;;
        --prep-mem) PREP_MEM="$2"; shift 2 ;;
        --prep-time) PREP_TIME="$2"; shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
    esac
done

[[ -n "$DATA_ROOT" ]] || { echo "ERROR: --data-root is required" >&2; exit 2; }
[[ "$RUNS" =~ ^[1-9][0-9]*$ ]] || { echo "ERROR: --runs must be a positive integer" >&2; exit 2; }
[[ "$SCAN_REPEATS" =~ ^[1-9][0-9]*$ ]] || { echo "ERROR: --scan-repeats must be a positive integer" >&2; exit 2; }

command -v sbatch >/dev/null 2>&1 || { echo "ERROR: sbatch not found" >&2; exit 1; }
mkdir -p "$DATA_ROOT"
[[ -w "$DATA_ROOT" ]] || { echo "ERROR: data root is not writable: $DATA_ROOT" >&2; exit 1; }

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNTIME_DIR="$REPO_ROOT/experiments/io-01b/runtime"
STAMP="$(date +%Y%m%d_%H%M%S)"
RESULT_DIR="${HOME}/ai-hpc-study/runtime/IO-01B/${STAMP}"
DATASET_DIR="${DATA_ROOT%/}/io01b-${STAMP}"
mkdir -p "$RESULT_DIR"

for f in io01b_prepare.sbatch io01b_measure.sbatch io01b_workload.py psi_monitor.py summarize_evidence.py; do
    [[ -f "$RUNTIME_DIR/$f" ]] || { echo "ERROR: missing $RUNTIME_DIR/$f" >&2; exit 1; }
done

{
    echo "experiment=IO-01B-Phase2-runtime"
    echo "timestamp=$STAMP"
    echo "submission_host=$(hostname)"
    echo "repo_root=$REPO_ROOT"
    echo "dataset_dir=$DATASET_DIR"
    echo "result_dir=$RESULT_DIR"
    echo "runs=$RUNS"
    echo "scan_repeats=$SCAN_REPEATS"
    echo "partition=$PARTITION"
    echo "account=$ACCOUNT"
    echo "measure_mem=$MEASURE_MEM"
    echo "measure_time=$MEASURE_TIME"
    echo "prep_mem=$PREP_MEM"
    echo "prep_time=$PREP_TIME"
    git -C "$REPO_ROOT" rev-parse HEAD 2>/dev/null | sed 's/^/git_commit=/' || true
} > "$RESULT_DIR/experiment-metadata.txt"

echo -e "role\trun_index\tjob_id" > "$RESULT_DIR/jobids.tsv"

prep_raw="$(sbatch --parsable \
    --job-name=io01b-prep \
    --partition="$PARTITION" \
    --account="$ACCOUNT" \
    --ntasks=1 --cpus-per-task=1 \
    --mem="$PREP_MEM" \
    --time="$PREP_TIME" \
    --output="$RESULT_DIR/prepare-%j.out" \
    --error="$RESULT_DIR/prepare-%j.err" \
    --export=ALL,IO01B_DATASET_DIR="$DATASET_DIR",IO01B_RESULT_DIR="$RESULT_DIR",IO01B_RUNTIME_DIR="$RUNTIME_DIR" \
    "$RUNTIME_DIR/io01b_prepare.sbatch")"
prep_id="${prep_raw%%;*}"

echo -e "prepare\t0\t$prep_id" >> "$RESULT_DIR/jobids.tsv"
previous="$prep_id"

for ((i=1; i<=RUNS; i++)); do
    job_raw="$(sbatch --parsable \
        --dependency="afterok:${previous}" \
        --job-name="io01b-measure-${i}" \
        --partition="$PARTITION" \
        --account="$ACCOUNT" \
        --ntasks=1 --cpus-per-task=1 \
        --mem="$MEASURE_MEM" \
        --time="$MEASURE_TIME" \
        --output="$RESULT_DIR/run-$(printf '%02d' "$i")-%j.out" \
        --error="$RESULT_DIR/run-$(printf '%02d' "$i")-%j.err" \
        --export=ALL,IO01B_DATASET_DIR="$DATASET_DIR",IO01B_RESULT_DIR="$RESULT_DIR",IO01B_RUNTIME_DIR="$RUNTIME_DIR",IO01B_RUN_INDEX="$i",IO01B_SCAN_REPEATS="$SCAN_REPEATS" \
        "$RUNTIME_DIR/io01b_measure.sbatch")"
    job_id="${job_raw%%;*}"
    echo -e "measure\t$i\t$job_id" >> "$RESULT_DIR/jobids.tsv"
    previous="$job_id"
done

echo
echo "IO-01B Phase 2 runtime submitted."
echo "Result directory: $RESULT_DIR"
echo "Dataset directory: $DATASET_DIR"
echo
echo "Jobs:"
column -t -s $'\t' "$RESULT_DIR/jobids.tsv" 2>/dev/null || cat "$RESULT_DIR/jobids.tsv"
echo
echo "After all jobs finish:"
echo "  $REPO_ROOT/scripts/collect_io01b_evidence.sh $RESULT_DIR"
