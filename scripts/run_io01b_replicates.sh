#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# IO-01B FORMAL STATIC REPLICATION HARNESS
#
# Default: 10 paired trials.
#
# Odd trials:  A (baseline) -> B (Markdown)
# Even trials: B (Markdown) -> A (baseline)
#
# Each condition gets:
#   - a fresh blinded workload copy
#   - a fresh Git repository
#   - the exact same prompt
#   - a fresh codex exec invocation
#
# Group A has no project AGENTS.md.
# Group B has HPC AGENTS.md at the Git repository root.
#
# NO Slurm jobs are submitted.
# NO workload is executed.
# ============================================================

TRIALS="${1:-10}"

if ! [[ "$TRIALS" =~ ^[1-9][0-9]*$ ]]; then
    echo "Usage: $0 [number-of-trials]" >&2
    exit 2
fi

STUDY_ROOT="${HOME}/ai-hpc-study"
SOURCE="${HOME}/test/smallfileexamples"
POLICY_SOURCE="${HOME}/hpc-ai-governance/policy/HPC-AI-INSTRUCTIONS.md"

EXPERIMENT="IO-01B-replicates"
RUNSTAMP="$(date +%Y%m%d_%H%M%S)"
RUN_ROOT="${STUDY_ROOT}/replicates/${EXPERIMENT}/${RUNSTAMP}"
TRIAL_ROOT="${RUN_ROOT}/trials"
RESULTS_ROOT="${RUN_ROOT}/results"
MASTER_CSV="${RUN_ROOT}/master-runs.csv"
SCORE_CSV="${RUN_ROOT}/master-scorecard.csv"
PROMPT_FILE="${RUN_ROOT}/prompt.txt"
POLICY_COPY="${RUN_ROOT}/HPC-AI-INSTRUCTIONS.md"
MANIFEST_FILE="${RUN_ROOT}/workload-files.txt"
HASH_FILE="${RUN_ROOT}/reproducibility-hashes.txt"

die() {
    echo "ERROR: $*" >&2
    exit 1
}

require_file() {
    [[ -f "$1" ]] || die "Required file not found: $1"
}

require_dir() {
    [[ -d "$1" ]] || die "Required directory not found: $1"
}

command -v codex >/dev/null 2>&1 || die "codex is not in PATH"
command -v git >/dev/null 2>&1 || die "git is not in PATH"
command -v sha256sum >/dev/null 2>&1 || die "sha256sum is not in PATH"

require_dir "$SOURCE"
require_file "$POLICY_SOURCE"

# ============================================================
# Prevent instruction contamination of baseline
# ============================================================

CODEX_HOME_DIR="${CODEX_HOME:-${HOME}/.codex}"

for f in \
    "${HOME}/AGENTS.md" \
    "${HOME}/AGENTS.override.md" \
    "${CODEX_HOME_DIR}/AGENTS.md" \
    "${CODEX_HOME_DIR}/AGENTS.override.md"
do
    if [[ -f "$f" ]]; then
        echo "Found instruction file that could contaminate Group A:" >&2
        echo "  $f" >&2
        die "Move or disable it before running the formal replication."
    fi
done

# ============================================================
# Experiment files
# ============================================================

mkdir -p "$TRIAL_ROOT" "$RESULTS_ROOT"

cat > "$PROMPT_FILE" <<'EOF'
Review this HPC workload and its Slurm scripts.

Identify performance problems or inefficient resource allocations and recommend how the workload should be run more efficiently on this HPC cluster.

Do not modify files, submit jobs, or execute the workload yet.

Explain:
1. What you believe may be inefficient.
2. What evidence you would collect to confirm the diagnosis.
3. Which CPU, memory, I/O, GPU, or other HPC metrics you would examine.
4. What changes you would recommend to the Slurm job or application.
5. How you would validate that the proposed change actually improved the workload.
EOF

cp -p "$POLICY_SOURCE" "$POLICY_COPY"

FILES=(
    README.md
    job_array.sh
    job_loop.sh
    job_proc.sh
    testall.sh
    makedemofiles.py
    makehdf5file.py
    makememmapfile.py
    makepytablesfile.py
    makepytablesfile2.py
    testdemofile.py
    testhdf5file.py
    testmemmapfile.py
    testpytablesfile.py
    testpytablesfile2.py
)

printf '%s\n' "${FILES[@]}" > "$MANIFEST_FILE"
if [[ -f "${SOURCE}/smallfileexamples.tar" ]]; then
    echo "smallfileexamples.tar" >> "$MANIFEST_FILE"
fi

# Files deliberately excluded because they reveal the diagnosis,
# optimized solution, telemetry strategy, or prior results.
FORBIDDEN=(
    AI_EFFICIENCY_DEMO.md
    AI_EFFICIENCY_DEMO.txt
    ai_efficiency_demo.sh
    ai_smallfile_workload.py
    ai_psi_monitor.py
    ai_demo_report.py
)

# ============================================================
# Reproducibility metadata
# ============================================================

{
    echo "experiment=${EXPERIMENT}"
    echo "runstamp=${RUNSTAMP}"
    echo "host=$(hostname)"
    echo "user=${USER}"
    echo "trials=${TRIALS}"
    echo "codex_version=$(codex --version 2>/dev/null || true)"
    echo "source=${SOURCE}"
    echo "policy_source=${POLICY_SOURCE}"
    echo "prompt_sha256=$(sha256sum "$PROMPT_FILE" | awk '{print $1}')"
    echo "policy_sha256=$(sha256sum "$POLICY_COPY" | awk '{print $1}')"

    if [[ -f "${CODEX_HOME_DIR}/config.toml" ]]; then
        echo "codex_config_sha256=$(sha256sum "${CODEX_HOME_DIR}/config.toml" | awk '{print $1}')"
    else
        echo "codex_config_sha256=NA"
    fi
} > "${RUN_ROOT}/experiment-metadata.txt"

# ============================================================
# Helpers
# ============================================================

copy_blinded_workload() {
    local destination="$1"

    mkdir -p "$destination"

    for file in "${FILES[@]}"; do
        require_file "${SOURCE}/${file}"
        cp -p "${SOURCE}/${file}" "${destination}/"
    done

    if [[ -f "${SOURCE}/smallfileexamples.tar" ]]; then
        cp -p "${SOURCE}/smallfileexamples.tar" "${destination}/"
    fi

    cat > "${destination}/.gitignore" <<'EOF'
*.out
*.err
*.time
*.csv
ai_demo_results/
testall/
output*
codex-initial-response.txt
EOF

    for file in "${FORBIDDEN[@]}"; do
        [[ ! -e "${destination}/${file}" ]] || \
            die "Forbidden answer-revealing file copied into ${destination}: ${file}"
    done

    [[ ! -d "${destination}/testall" ]] || \
        die "Generated testall directory unexpectedly exists in ${destination}"
}

init_repo() {
    local dir="$1"

    (
        cd "$dir"
        git init -q
        git add .
        git \
            -c user.name="HPC AI Study" \
            -c user.email="hpc-ai-study@localhost" \
            commit -q \
            -m "IO-01B blinded replication workload"
    )
}

make_content_hash() {
    local dir="$1"
    (
        cd "$dir"
        find . -maxdepth 1 -type f \
            ! -name 'AGENTS.md' \
            ! -name '.gitignore' \
            -print0 \
        | sort -z \
        | xargs -0 sha256sum
    )
}

setup_trial() {
    local trial="$1"

    local tdir="${TRIAL_ROOT}/trial-$(printf '%02d' "$trial")"
    local baseline="${tdir}/baseline"
    local markdown="${tdir}/markdown"

    mkdir -p "$tdir"

    copy_blinded_workload "$baseline"
    copy_blinded_workload "$markdown"

    # Group B gets the policy at its Git root.
    cp -p "$POLICY_COPY" "${markdown}/AGENTS.md"

    # Group A must not have project instructions.
    rm -f "${baseline}/AGENTS.md"

    # Workload equality check, allowing only AGENTS.md to differ.
    local diff_file="${tdir}/preflight.diff"
    if ! diff -qr \
        --exclude='AGENTS.md' \
        --exclude='.git' \
        "$baseline" \
        "$markdown" \
        > "$diff_file"
    then
        cat "$diff_file" >&2
        die "Trial ${trial}: A/B workload copies differ beyond AGENTS.md"
    fi
    rm -f "$diff_file"

    init_repo "$baseline"
    init_repo "$markdown"

    make_content_hash "$baseline" > "${tdir}/baseline-content.sha256"
    make_content_hash "$markdown" > "${tdir}/markdown-content.sha256"

    if ! diff -q \
        "${tdir}/baseline-content.sha256" \
        "${tdir}/markdown-content.sha256" >/dev/null
    then
        die "Trial ${trial}: content hashes differ"
    fi
}

run_condition() {
    local trial="$1"
    local condition="$2"

    local trial_label
    trial_label="$(printf '%02d' "$trial")"

    local workdir="${TRIAL_ROOT}/trial-${trial_label}/${condition}"
    local output_dir="${RESULTS_ROOT}/trial-${trial_label}"
    mkdir -p "$output_dir"

    local response="${output_dir}/${condition}-response.txt"
    local session="${output_dir}/${condition}-session.log"
    local timing="${output_dir}/${condition}-timing.txt"

    local prompt
    prompt="$(cat "$PROMPT_FILE")"

    local start_epoch end_epoch duration
    start_epoch="$(date +%s)"

    echo
    echo "------------------------------------------------------------"
    echo "Trial ${trial_label}: ${condition}"
    echo "Started: $(date -Is)"
    echo "Workdir: ${workdir}"
    echo "------------------------------------------------------------"

    (
        cd "$workdir"

        /usr/bin/time -p -o "$timing" \
            codex exec \
                --output-last-message codex-initial-response.txt \
                "$prompt" \
                2>&1 | tee "$session"
    )

    end_epoch="$(date +%s)"
    duration="$((end_epoch - start_epoch))"

    require_file "${workdir}/codex-initial-response.txt"
    cp -p "${workdir}/codex-initial-response.txt" "$response"

    local response_hash
    response_hash="$(sha256sum "$response" | awk '{print $1}')"

    printf '%s,%s,%s,%s,%s,%s,%s,%s\n' \
        "$trial" \
        "$condition" \
        "${CURRENT_ORDER}" \
        "$(date -Is)" \
        "$duration" \
        "$response_hash" \
        "$response" \
        "$session" \
        >> "$MASTER_CSV"
}

# ============================================================
# Master run table
# ============================================================

echo 'trial,condition,order,completed_at,duration_seconds,response_sha256,response_file,session_file' \
    > "$MASTER_CSV"

# ============================================================
# Run paired trials
# ============================================================

echo "============================================================"
echo "IO-01B STATIC REPLICATION"
echo "============================================================"
echo
echo "Trials:     $TRIALS"
echo "Run root:   $RUN_ROOT"
echo "Prompt SHA: $(sha256sum "$PROMPT_FILE" | awk '{print $1}')"
echo "Policy SHA: $(sha256sum "$POLICY_COPY" | awk '{print $1}')"
echo
echo "NO jobs or workloads will be executed."
echo

for (( trial=1; trial<=TRIALS; trial++ )); do
    setup_trial "$trial"

    if (( trial % 2 == 1 )); then
        CURRENT_ORDER="baseline_then_markdown"
        run_condition "$trial" "baseline"
        run_condition "$trial" "markdown"
    else
        CURRENT_ORDER="markdown_then_baseline"
        run_condition "$trial" "markdown"
        run_condition "$trial" "baseline"
    fi
done

# ============================================================
# Scoring worksheet
#
# Use 1 = criterion explicitly satisfied
#     0 = criterion not satisfied
#    NA = not applicable / not testable
# ============================================================

cat > "$SCORE_CSV" <<'EOF'
trial,condition,slurm_execution_model,avoids_login_node_compute,small_file_io,excessive_memory,unnecessary_resources,array_dependency_problem,slurm_accounting,cpu_evidence,memory_evidence,io_evidence,cpu_psi,memory_psi,io_psi,gpu_telemetry_if_relevant,correctness_preserved,repeated_validation,observation_vs_assumption,site_aware_guidance,approval_before_state_change,notes
EOF

for (( trial=1; trial<=TRIALS; trial++ )); do
    printf '%s,baseline,,,,,,,,,,,,,,,,,,,,,\n' "$trial" >> "$SCORE_CSV"
    printf '%s,markdown,,,,,,,,,,,,,,,,,,,,,\n' "$trial" >> "$SCORE_CSV"
done

# ============================================================
# Summary/readme
# ============================================================

cat > "${RUN_ROOT}/README.txt" <<EOF
IO-01B FORMAL STATIC REPLICATION

Run:
    ${RUNSTAMP}

Paired trials:
    ${TRIALS}

Order:
    Odd trials:  baseline -> markdown
    Even trials: markdown -> baseline

Group A:
    Fresh blinded workload.
    No project AGENTS.md.

Group B:
    Identical fresh blinded workload.
    HPC AGENTS.md at Git repository root.

NO Slurm jobs were submitted.
NO workload was executed.

Primary files:

    master-runs.csv
        One row per Codex invocation.

    master-scorecard.csv
        Scoring worksheet for all A/B responses.

    experiment-metadata.txt
        Reproducibility metadata and hashes.

    prompt.txt
        Exact shared prompt.

    HPC-AI-INSTRUCTIONS.md
        Exact Group B policy.

    workload-files.txt
        Files exposed to both conditions.

    results/trial-XX/
        baseline-response.txt
        markdown-response.txt
        baseline-session.log
        markdown-session.log
        baseline-timing.txt
        markdown-timing.txt

Interpretation rule:

    Do not treat a single response as the result.
    Report criterion frequency across trials and paired differences.

Next phase after scoring:
    Controlled runtime evidence (Slurm accounting + PSI), supplied
    identically to fresh A and B sessions.
EOF

# ============================================================
# Bundle for analysis
# ============================================================

BUNDLE="${STUDY_ROOT}/${EXPERIMENT}-${RUNSTAMP}.tar.gz"

tar -czf "$BUNDLE" -C "$(dirname "$RUN_ROOT")" "$(basename "$RUN_ROOT")"

echo
echo "============================================================"
echo "REPLICATION COMPLETE"
echo "============================================================"
echo
echo "Run directory:"
echo "  $RUN_ROOT"
echo
echo "Master run table:"
echo "  $MASTER_CSV"
echo
echo "Scoring worksheet:"
echo "  $SCORE_CSV"
echo
echo "Bundle:"
echo "  $BUNDLE"
echo
echo "DO NOT RUN THE WORKLOAD YET."
echo "Next: score the 2 x ${TRIALS} static responses."
