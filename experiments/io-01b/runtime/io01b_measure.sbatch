#!/bin/bash -l
set -euo pipefail

: "${IO01B_DATASET_DIR:?IO01B_DATASET_DIR is required}"
: "${IO01B_RESULT_DIR:?IO01B_RESULT_DIR is required}"
: "${IO01B_RUNTIME_DIR:?IO01B_RUNTIME_DIR is required}"
: "${IO01B_RUN_INDEX:?IO01B_RUN_INDEX is required}"

RUN_DIR="$IO01B_RESULT_DIR/run-$(printf '%02d' "$IO01B_RUN_INDEX")"
mkdir -p "$RUN_DIR"

export OMP_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export MKL_NUM_THREADS=1
export NUMEXPR_NUM_THREADS=1

{
    echo "timestamp=$(date -Ins)"
    echo "hostname=$(hostname)"
    echo "job_id=${SLURM_JOB_ID:-NA}"
    echo "run_index=$IO01B_RUN_INDEX"
    echo "dataset_dir=$IO01B_DATASET_DIR"
    echo "cuda_visible_devices=${CUDA_VISIBLE_DEVICES:-}"
    echo "python=$(command -v python3)"
    python3 --version
    echo "pressure_files:"
    ls -l /proc/pressure 2>/dev/null || true
} > "$RUN_DIR/run-metadata.txt"

python3 "$IO01B_RUNTIME_DIR/psi_monitor.py" \
    "$RUN_DIR/psi.csv" --interval 0.5 &
psi_pid=$!

cleanup() {
    kill "$psi_pid" 2>/dev/null || true
    wait "$psi_pid" 2>/dev/null || true
}
trap cleanup EXIT

/usr/bin/time -v -o "$RUN_DIR/time-v.txt" \
    python3 "$IO01B_RUNTIME_DIR/io01b_workload.py" scan \
        --directory "$IO01B_DATASET_DIR/inputs" \
        --expected-metadata "$IO01B_DATASET_DIR/dataset-metadata.json" \
        --repeats 3 \
        --output "$RUN_DIR/workload.json" \
        > "$RUN_DIR/workload.stdout"

cleanup
trap - EXIT

python3 "$IO01B_RUNTIME_DIR/summarize_evidence.py" \
    "$RUN_DIR" --output "$RUN_DIR/evidence-summary.md"
