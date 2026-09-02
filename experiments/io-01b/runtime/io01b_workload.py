#!/usr/bin/env python3
"""Deterministic IO-01B runtime workload.

This is a corrected measurement workload, not an optimized implementation.
It isolates exactly 12,000 input files in a dedicated directory, writes a
manifest/metadata file, and verifies every scan against the expected digest.
"""

import argparse
import hashlib
import json
import random
import shutil
import time
from pathlib import Path


def aggregate_digest(paths):
    digest = hashlib.sha256()
    logical_bytes = 0
    for path in paths:
        payload = path.read_bytes()
        digest.update(payload)
        logical_bytes += len(payload)
    return digest.hexdigest(), logical_bytes


def prepare(directory: Path, count: int, max_bytes: int, seed: int, metadata: Path):
    if directory.exists():
        shutil.rmtree(directory)
    directory.mkdir(parents=True, exist_ok=False)

    rng = random.Random(seed)
    started = time.perf_counter()
    logical_bytes = 0

    for index in range(count):
        size = rng.randrange(1, max_bytes + 1)
        marker = f"io01b-{seed}-{index:08d}|".encode()
        payload = (marker * (size // len(marker) + 1))[:size]
        (directory / f"{index:08d}.bin").write_bytes(payload)
        logical_bytes += size

    paths = sorted(directory.glob('*.bin'))
    digest, verified_bytes = aggregate_digest(paths)
    elapsed = time.perf_counter() - started

    if len(paths) != count:
        raise SystemExit(f"expected {count} files, found {len(paths)}")
    if verified_bytes != logical_bytes:
        raise SystemExit("logical byte count changed during verification")

    record = {
        "mode": "prepare",
        "directory": str(directory),
        "count": count,
        "max_bytes": max_bytes,
        "seed": seed,
        "logical_bytes": logical_bytes,
        "sha256": digest,
        "elapsed_seconds": elapsed,
    }
    metadata.parent.mkdir(parents=True, exist_ok=True)
    metadata.write_text(json.dumps(record, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(record, sort_keys=True))


def scan(directory: Path, repeats: int, expected_metadata: Path, output: Path):
    expected = json.loads(expected_metadata.read_text(encoding="utf-8"))
    expected_count = int(expected["count"])
    expected_digest = expected["sha256"]
    expected_bytes = int(expected["logical_bytes"])

    paths = sorted(directory.glob('*.bin'))
    if len(paths) != expected_count:
        raise SystemExit(f"expected {expected_count} files, found {len(paths)}")

    digest = hashlib.sha256()
    logical_bytes = 0
    started = time.perf_counter()
    for _ in range(repeats):
        for path in paths:
            payload = path.read_bytes()
            digest.update(payload)
            logical_bytes += len(payload)
    elapsed = time.perf_counter() - started

    # The repeated digest differs from the single-pass prepare digest. Verify a
    # separate one-pass digest so correctness is independent of repeat count.
    verify_digest, verify_bytes = aggregate_digest(paths)
    if verify_digest != expected_digest or verify_bytes != expected_bytes:
        raise SystemExit("input dataset failed checksum/byte-count validation")

    record = {
        "mode": "scan",
        "directory": str(directory),
        "files": len(paths),
        "repeats": repeats,
        "logical_bytes_per_pass": expected_bytes,
        "logical_bytes_processed": logical_bytes,
        "elapsed_seconds": elapsed,
        "effective_mib_per_second": (logical_bytes / (1024 * 1024)) / elapsed if elapsed else None,
        "single_pass_sha256": verify_digest,
        "repeated_sha256": digest.hexdigest(),
        "correctness": "PASS",
    }
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(record, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(record, sort_keys=True))


def main():
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest="command", required=True)

    p = sub.add_parser("prepare")
    p.add_argument("--directory", type=Path, required=True)
    p.add_argument("--count", type=int, default=12000)
    p.add_argument("--max-bytes", type=int, default=5000)
    p.add_argument("--seed", type=int, default=20260902)
    p.add_argument("--metadata", type=Path, required=True)

    s = sub.add_parser("scan")
    s.add_argument("--directory", type=Path, required=True)
    s.add_argument("--repeats", type=int, default=3)
    s.add_argument("--expected-metadata", type=Path, required=True)
    s.add_argument("--output", type=Path, required=True)

    args = parser.parse_args()
    if args.command == "prepare":
        prepare(args.directory, args.count, args.max_bytes, args.seed, args.metadata)
    else:
        scan(args.directory, args.repeats, args.expected_metadata, args.output)


if __name__ == "__main__":
    main()
