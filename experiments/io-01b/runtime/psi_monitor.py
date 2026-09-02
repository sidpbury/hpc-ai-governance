#!/usr/bin/env python3
"""Sample Linux Pressure Stall Information to CSV."""

import argparse
import csv
import re
import time
from pathlib import Path

FIELDS = [
    "timestamp_epoch",
    "cpu_some_avg10", "cpu_some_avg60", "cpu_some_avg300", "cpu_some_total",
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
        kind, rest = line.split(' ', 1)
        values = dict(re.findall(r'(avg10|avg60|avg300|total)=([0-9.]+)', rest))
        for key, value in values.items():
            result[f"{resource}_{kind}_{key}"] = value
    return result


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('output', type=Path)
    ap.add_argument('--interval', type=float, default=0.5)
    args = ap.parse_args()
    args.output.parent.mkdir(parents=True, exist_ok=True)

    with args.output.open('w', newline='', encoding='utf-8') as handle:
        writer = csv.DictWriter(handle, fieldnames=FIELDS)
        writer.writeheader()
        while True:
            row = {"timestamp_epoch": f"{time.time():.6f}"}
            for resource in ('cpu', 'memory', 'io'):
                row.update(parse_pressure(resource))
            writer.writerow(row)
            handle.flush()
            time.sleep(args.interval)


if __name__ == '__main__':
    main()
