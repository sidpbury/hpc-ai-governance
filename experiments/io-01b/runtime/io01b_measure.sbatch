#!/bin/bash -l
set -euo pipefail

: "${IO01B_DATASET_DIR:?IO01B_DATASET_DIR is required}"
: "${IO01B_RESULT_DIR:?IO01B_RESULT_DIR is required}"
: "${IO01B_RUNTIME_DIR:?IO01B_RUNTIME_DIR is required}"
: "${IO01B_RUN_INDEX:?IO01B_RUN_INDEX is required}"

IO01B_SCAN_REPEATS="${IO01B_SCAN_REPEATS:-30}"

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
    echo "scan_repeats=$IO01B_SCAN_REPEATS"
    echo "dataset_dir=$IO01B_DATASET_DIR"
    echo "cuda_visible_devices=${CUDA_VISIBLE_DEVICES:-}"
    echo "python=$(command -v python3)"
    python3 --version
    echo "pressure_files:"
    ls -l /proc/pressure 2>/dev/null || true
} > "$RUN_DIR/run-metadata.txt"

# Fail fast if the PSI parser/schema cannot read this kernel. The first Phase-2
# pilot showed why telemetry health must be part of the measurement validity.
python3 "$IO01B_RUNTIME_DIR/psi_monitor.py" \
    "$RUN_DIR/psi-preflight.csv" --interval 0 --samples 1
rm -f "$RUN_DIR/psi-preflight.csv"

python3 "$IO01B_RUNTIME_DIR/psi_monitor.py" \
    "$RUN_DIR/psi.csv" --interval 0.5 &
psi_pid=$!

cleanup() {
    kill "$psi_pid" 2>/dev/null || true
    wait "$psi_pid" 2>/dev/null || true
}
trap cleanup EXIT

# Confirm the monitor survived startup before beginning the measured workload.
sleep 0.1
if ! kill -0 "$psi_pid" 2>/dev/null; then
    wait "$psi_pid" || true
    echo "ERROR: PSI monitor exited before workload measurement" >&2
    exit 1
fi

/usr/bin/time -v -o "$RUN_DIR/time-v.txt" \
    python3 "$IO01B_RUNTIME_DIR/io01b_workload.py" scan \
        --directory "$IO01B_DATASET_DIR/inputs" \
        --expected-metadata "$IO01B_DATASET_DIR/dataset-metadata.json" \
        --repeats "$IO01B_SCAN_REPEATS" \
        --output "$RUN_DIR/workload.json" \
        > "$RUN_DIR/workload.stdout"

# A telemetry failure invalidates the measurement even if the workload itself
# succeeded. Detect an unexpected monitor exit before the normal cleanup.
if ! kill -0 "$psi_pid" 2>/dev/null; then
    wait "$psi_pid" || true
    echo "ERROR: PSI monitor exited during workload measurement" >&2
    exit 1
fi

cleanup
trap - EXIT

python3 "$IO01B_RUNTIME_DIR/summarize_evidence.py" \
    "$RUN_DIR" --output "$RUN_DIR/evidence-summary.md"
