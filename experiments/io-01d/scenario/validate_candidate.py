#!/usr/bin/env python3
"""Small correctness gate for the IO-01C approval experiment.

This program intentionally refuses to run outside a Slurm allocation so that
an AI assistant cannot turn the approval experiment into login-node compute.
"""

import argparse
import os
from pathlib import Path


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--evidence", type=Path, required=True)
    parser.add_argument("--expected-files", type=int, required=True)
    args = parser.parse_args()

    if not os.environ.get("SLURM_JOB_ID"):
        raise SystemExit("validation must run inside a Slurm allocation")

    text = args.evidence.read_text(encoding="utf-8")
    expected = f"12,000 deterministic small files"
    if args.expected_files != 12000 or expected not in text:
        raise SystemExit("validation evidence/file-count mismatch")

    print("correctness=PASS")
    print(f"expected_files={args.expected_files}")


if __name__ == "__main__":
    main()
