#!/usr/bin/env python3
"""Sample Linux Pressure Stall Information to CSV."""

import argparse
import csv
import re
import time
from pathlib import Path

# Use a stable superset schema. Newer kernels may expose CPU "full" pressure
# in addition to the traditionally expected CPU "some" line.
FIELDS = [
    "timestamp_epoch",
    "cpu_some_avg10", "cpu_some_avg60", "cpu_some_avg300", "cpu_some_total",
    "cpu_full_avg10", "cpu_full_avg60", "cpu_full_avg300", "cpu_full_total",
    "memory_some_avg10", "memory_some_avg60", "memory_some_avg300", "memory_some_total",
    "memory_full_avg10", "memory_full_avg60", "memory_full_avg300", "memory_full_total",
    "io_some_avg10", "io_some_avg60", "io_some_avg300", "io_some_total",
    "io_full_avg10", "io_full_avg60", "io_full_avg300", "io_full_total",
]


def parse_pressure(resource):
    result = {}
    path = Path('/proc/pressure') / resource
    if not path.exists():
        return result
    for line in path.read_text().splitlines():
        if ' ' not in line:
            continue
        kind, rest = line.split(' ', 1)
        values = dict(re.findall(r'(avg10|avg60|avg300|total)=([0-9.]+)', rest))
        for key, value in values.items():
            result[f"{resource}_{kind}_{key}"] = value
    return result


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('output', type=Path)
    ap.add_argument('--interval', type=float, default=0.5)
    ap.add_argument(
        '--samples', type=int, default=0,
        help='Number of samples to write; 0 means continue until terminated.',
    )
    args = ap.parse_args()
    if args.interval < 0:
        ap.error('--interval must be >= 0')
    if args.samples < 0:
        ap.error('--samples must be >= 0')

    args.output.parent.mkdir(parents=True, exist_ok=True)

    with args.output.open('w', newline='', encoding='utf-8') as handle:
        # extrasaction=ignore makes the collector forward-compatible if a future
        # kernel adds another PSI line before the repository schema is updated.
        writer = csv.DictWriter(handle, fieldnames=FIELDS, extrasaction='ignore')
        writer.writeheader()
        sample_count = 0
        while args.samples == 0 or sample_count < args.samples:
            row = {"timestamp_epoch": f"{time.time():.6f}"}
            for resource in ('cpu', 'memory', 'io'):
                row.update(parse_pressure(resource))
            writer.writerow(row)
            handle.flush()
            sample_count += 1
            if args.samples and sample_count >= args.samples:
                break
            time.sleep(args.interval)


if __name__ == '__main__':
    main()
