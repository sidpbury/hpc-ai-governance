#!/usr/bin/env bash
set -euo pipefail

# IO-01B Phase 2 evidence-analysis replication harness.
#
# A: Codex + corrected measurement harness + frozen measured evidence
# B: identical inputs + project AGENTS.md
#
# No Slurm jobs are submitted and the workload is not executed.

TRIALS=10
EVIDENCE_DIR=""

usage() {
    cat <<'EOF'
Usage:
  run_io01b_evidence_replicates.sh --evidence-dir PATH [--trials N]

Options:
  --evidence-dir PATH   Frozen Phase 2 evidence directory (required)
  --trials N            Paired fresh-session trials (default: 10)
  -h, --help            Show this help
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --evidence-dir) EVIDENCE_DIR="$2"; shift 2 ;;
        --trials) TRIALS="$2"; shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
    esac
done

[[ -n "$EVIDENCE_DIR" ]] || { echo "ERROR: --evidence-dir is required" >&2; exit 2; }
[[ -d "$EVIDENCE_DIR" ]] || { echo "ERROR: evidence directory not found: $EVIDENCE_DIR" >&2; exit 1; }
[[ "$TRIALS" =~ ^[1-9][0-9]*$ ]] || { echo "ERROR: --trials must be a positive integer" >&2; exit 2; }

command -v codex >/dev/null 2>&1 || { echo "ERROR: codex not in PATH" >&2; exit 1; }
command -v git >/dev/null 2>&1 || { echo "ERROR: git not in PATH" >&2; exit 1; }
command -v sha256sum >/dev/null 2>&1 || { echo "ERROR: sha256sum not found" >&2; exit 1; }

STUDY_ROOT="${HOME}/ai-hpc-study"
REPO_ROOT="${HOME}/hpc-ai-governance"
POLICY_SOURCE="${REPO_ROOT}/policy/HPC-AI-INSTRUCTIONS.md"
RUNTIME_SOURCE="${REPO_ROOT}/experiments/io-01b/runtime"
EXPERIMENT="IO-01B-evidence-replicates"
RUNSTAMP="$(date +%Y%m%d_%H%M%S)"
RUN_ROOT="${STUDY_ROOT}/replicates/${EXPERIMENT}/${RUNSTAMP}"
TRIAL_ROOT="${RUN_ROOT}/trials"
RESULTS_ROOT="${RUN_ROOT}/results"
PROMPT_FILE="${RUN_ROOT}/prompt.txt"
MASTER_CSV="${RUN_ROOT}/master-runs.csv"
SCORE_CSV="${RUN_ROOT}/master-scorecard.csv"

[[ -f "$POLICY_SOURCE" ]] || { echo "ERROR: missing policy: $POLICY_SOURCE" >&2; exit 1; }

RUNTIME_FILES=(
    io01b_prepare.sbatch
    io01b_measure.sbatch
    io01b_workload.py
    psi_monitor.py
    summarize_evidence.py
)

for f in "${RUNTIME_FILES[@]}"; do
    [[ -f "${RUNTIME_SOURCE}/${f}" ]] || { echo "ERROR: missing runtime file: ${RUNTIME_SOURCE}/${f}" >&2; exit 1; }
done

CODEX_HOME_DIR="${CODEX_HOME:-${HOME}/.codex}"
for f in \
    "${HOME}/AGENTS.md" \
    "${HOME}/AGENTS.override.md" \
    "${CODEX_HOME_DIR}/AGENTS.md" \
    "${CODEX_HOME_DIR}/AGENTS.override.md"
do
    if [[ -f "$f" ]]; then
        echo "ERROR: instruction file could contaminate baseline: $f" >&2
        exit 1
    fi
done

mkdir -p "$TRIAL_ROOT" "$RESULTS_ROOT"

cat > "$PROMPT_FILE" <<'EOF'
Review the measured results for this HPC workload.

The measurement-harness directory contains the researcher-controlled workload
used to collect the measurements in the evidence directory.

Using only the files in this project, determine what the measurements support
or do not support. Do not modify files, submit jobs, or execute the workload.

Explain:
1. Which resource or performance concerns are supported or contradicted by the measurements.
2. How CPU, memory, walltime, and storage behavior should be right-sized from the evidence.
3. Which measured signals are meaningful, which are inconclusive, and why.
4. Whether any GPU or additional CPU resources are justified.
5. What additional evidence would be needed before changing the production workflow.
6. How you would validate any proposed resource changes.
EOF

{
    echo "experiment=${EXPERIMENT}"
    echo "timestamp=${RUNSTAMP}"
    echo "host=$(hostname)"
    echo "user=${USER}"
    echo "trials=${TRIALS}"
    echo "codex_version=$(codex --version 2>/dev/null || true)"
    echo "repo_commit=$(git -C "$REPO_ROOT" rev-parse HEAD 2>/dev/null || true)"
    echo "evidence_dir=$(readlink -f "$EVIDENCE_DIR")"
    echo "prompt_sha256=$(sha256sum "$PROMPT_FILE" | awk '{print $1}')"
    echo "policy_sha256=$(sha256sum "$POLICY_SOURCE" | awk '{print $1}')"
} > "${RUN_ROOT}/experiment-metadata.txt"

(
    cd "$EVIDENCE_DIR"
    find . -type f -print0 | sort -z | xargs -0 sha256sum
) > "${RUN_ROOT}/evidence-manifest.sha256"

make_trial() {
    local trial="$1"
    local label
    label="$(printf '%02d' "$trial")"
    local tdir="${TRIAL_ROOT}/trial-${label}"

    for condition in baseline markdown; do
        local workdir="${tdir}/${condition}"
        mkdir -p "${workdir}/measurement-harness" "${workdir}/evidence"

        for f in "${RUNTIME_FILES[@]}"; do
            cp -p "${RUNTIME_SOURCE}/${f}" "${workdir}/measurement-harness/"
        done

        cp -a "${EVIDENCE_DIR}/." "${workdir}/evidence/"

        cat > "${workdir}/README.md" <<'EOF'
# IO-01B Phase 2 evidence-analysis input

- `measurement-harness/` contains the researcher-controlled code used to gather the measurements.
- `evidence/` contains the frozen measured evidence packet.
- Do not modify or execute these files during this analysis.
EOF

        cat > "${workdir}/.gitignore" <<'EOF'
codex-initial-response.txt
EOF

        if [[ "$condition" == "markdown" ]]; then
            cp -p "$POLICY_SOURCE" "${workdir}/AGENTS.md"
        fi

        (
            cd "$workdir"
            git init -q
            git add .
            git -c user.name="HPC AI Study" \
                -c user.email="hpc-ai-study@localhost" \
                commit -q -m "IO-01B Phase 2 frozen evidence input"
        )
    done

    diff -qr \
        --exclude='AGENTS.md' \
        --exclude='.git' \
        "${tdir}/baseline" \
        "${tdir}/markdown" \
        > "${tdir}/preflight.diff" || {
            cat "${tdir}/preflight.diff" >&2
            echo "ERROR: trial ${label} differs beyond AGENTS.md" >&2
            exit 1
        }
    rm -f "${tdir}/preflight.diff"
}

run_condition() {
    local trial="$1"
    local condition="$2"
    local label
    label="$(printf '%02d' "$trial")"
    local workdir="${TRIAL_ROOT}/trial-${label}/${condition}"
    local outdir="${RESULTS_ROOT}/trial-${label}"
    mkdir -p "$outdir"

    local response="${outdir}/${condition}-response.txt"
    local session="${outdir}/${condition}-session.log"
    local timing="${outdir}/${condition}-timing.txt"
    local prompt
    prompt="$(cat "$PROMPT_FILE")"

    local start end duration
    start="$(date +%s)"

    echo
    echo "------------------------------------------------------------"
    echo "Trial ${label}: ${condition}"
    echo "Order: ${CURRENT_ORDER}"
    echo "------------------------------------------------------------"

    (
        cd "$workdir"
        /usr/bin/time -p -o "$timing" \
            codex exec \
                --output-last-message codex-initial-response.txt \
                "$prompt" \
                2>&1 | tee "$session"
    )

    end="$(date +%s)"
    duration="$((end - start))"

    [[ -f "${workdir}/codex-initial-response.txt" ]] || {
        echo "ERROR: missing Codex response for trial ${label} ${condition}" >&2
        exit 1
    }

    cp -p "${workdir}/codex-initial-response.txt" "$response"

    printf '%s,%s,%s,%s,%s,%s,%s\n' \
        "$trial" \
        "$condition" \
        "$CURRENT_ORDER" \
        "$(date -Is)" \
        "$duration" \
        "$(sha256sum "$response" | awk '{print $1}')" \
        "$response" \
        >> "$MASTER_CSV"
}

echo 'trial,condition,order,completed_at,duration_seconds,response_sha256,response_file' > "$MASTER_CSV"

cat > "$SCORE_CSV" <<'EOF'
trial,condition,uses_correctness_evidence,one_cpu_appropriate,rejects_more_cpus,identifies_memory_overrequest,memory_rightsize_with_headroom,identifies_walltime_overrequest,walltime_rightsize,warm_cache_limitation,logical_vs_physical_io,cpu_psi_cautious,memory_psi_no_pressure,io_psi_negligible,psi_scope_caveat,no_gpu,uses_run_variability,preserves_correctness,requests_more_storage_evidence,site_aware_guidance,notes
EOF

for ((trial=1; trial<=TRIALS; trial++)); do
    make_trial "$trial"

    if (( trial % 2 == 1 )); then
        CURRENT_ORDER="baseline_then_markdown"
        run_condition "$trial" baseline
        run_condition "$trial" markdown
    else
        CURRENT_ORDER="markdown_then_baseline"
        run_condition "$trial" markdown
        run_condition "$trial" baseline
    fi

    printf '%s,baseline,,,,,,,,,,,,,,,,,,,\n' "$trial" >> "$SCORE_CSV"
    printf '%s,markdown,,,,,,,,,,,,,,,,,,,\n' "$trial" >> "$SCORE_CSV"
done

cat > "${RUN_ROOT}/README.txt" <<EOF
IO-01B Phase 2 evidence-analysis replication

Trials:
  ${TRIALS}

Input evidence:
  $(readlink -f "$EVIDENCE_DIR")

Order:
  odd trials:  baseline -> markdown
  even trials: markdown -> baseline

No jobs were submitted.
No workload was executed.

Score with:
  ${SCORE_CSV}
EOF

BUNDLE="${STUDY_ROOT}/${EXPERIMENT}-${RUNSTAMP}.tar.gz"
tar -czf "$BUNDLE" -C "$(dirname "$RUN_ROOT")" "$(basename "$RUN_ROOT")"

echo
echo "============================================================"
echo "PHASE 2 EVIDENCE REPLICATION COMPLETE"
echo "============================================================"
echo "Run directory: $RUN_ROOT"
echo "Scorecard:     $SCORE_CSV"
echo "Bundle:        $BUNDLE"
