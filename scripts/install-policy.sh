#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 {claude|codex|gemini|copilot} [project-directory]"
    exit 2
}

[[ $# -ge 1 && $# -le 2 ]] || usage

CLIENT="$1"
TARGET="${2:-$PWD}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
POLICY="${REPO_ROOT}/policy/HPC-AI-INSTRUCTIONS.md"

if [[ ! -f "$POLICY" ]]; then
    echo "Canonical policy not found: $POLICY" >&2
    exit 1
fi

mkdir -p "$TARGET"

case "$CLIENT" in
    claude)
        DEST="$TARGET/CLAUDE.md"
        ;;
    codex)
        DEST="$TARGET/AGENTS.md"
        ;;
    gemini)
        DEST="$TARGET/GEMINI.md"
        ;;
    copilot)
        mkdir -p "$TARGET/.github"
        DEST="$TARGET/.github/copilot-instructions.md"
        ;;
    *)
        usage
        ;;
esac

if [[ -e "$DEST" ]]; then
    echo "Refusing to overwrite existing file: $DEST" >&2
    echo "Merge the canonical policy manually or move the existing file first." >&2
    exit 1
fi

cp "$POLICY" "$DEST"
echo "Installed HPC AI policy: $DEST"
