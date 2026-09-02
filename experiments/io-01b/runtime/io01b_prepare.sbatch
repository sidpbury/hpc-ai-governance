#!/bin/bash -l
set -euo pipefail

: "${IO01B_DATASET_DIR:?IO01B_DATASET_DIR is required}"
: "${IO01B_RESULT_DIR:?IO01B_RESULT_DIR is required}"
: "${IO01B_RUNTIME_DIR:?IO01B_RUNTIME_DIR is required}"

mkdir -p "$IO01B_RESULT_DIR"

{
    echo "timestamp=$(date -Ins)"
    echo "hostname=$(hostname)"
    echo "job_id=${SLURM_JOB_ID:-NA}"
    echo "dataset_dir=$IO01B_DATASET_DIR"
    echo "python=$(command -v python3)"
    python3 --version
} > "$IO01B_RESULT_DIR/prepare-metadata.txt"

/usr/bin/time -v -o "$IO01B_RESULT_DIR/prepare-time-v.txt" \
    python3 "$IO01B_RUNTIME_DIR/io01b_workload.py" prepare \
        --directory "$IO01B_DATASET_DIR/inputs" \
        --metadata "$IO01B_DATASET_DIR/dataset-metadata.json" \
        --count 12000 \
        --max-bytes 5000 \
        --seed 20260902 \
        > "$IO01B_RESULT_DIR/prepare-workload.jsonl"

cp "$IO01B_DATASET_DIR/dataset-metadata.json" \
   "$IO01B_RESULT_DIR/dataset-metadata.json"
