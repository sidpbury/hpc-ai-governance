#!/usr/bin/env python3
"""Create a neutral Phase-2 evidence summary from measured artifacts."""

import argparse
import csv
import json
from pathlib import Path


def psi_summary(path):
    if not path.exists():
        return {}
    with path.open(newline='', encoding='utf-8') as f:
        rows = list(csv.DictReader(f))
    if not rows:
        return {}
    result = {"samples": len(rows)}
    for key in rows[0]:
        if key == 'timestamp_epoch':
            continue
        vals = [float(r[key]) for r in rows if r.get(key) not in ('', None)]
        if not vals:
            continue
        if key.endswith('_total'):
            result[key + '_delta'] = vals[-1] - vals[0]
        else:
            result[key + '_max'] = max(vals)
            result[key + '_mean'] = sum(vals) / len(vals)
    return result


def parse_time(path):
    out = {}
    if not path.exists():
        return out
    for line in path.read_text(errors='replace').splitlines():
        if ':' not in line:
            continue
        key, value = line.split(':', 1)
        out[key.strip()] = value.strip()
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('run_dir', type=Path)
    ap.add_argument('--output', type=Path, required=True)
    args = ap.parse_args()

    workload = json.loads((args.run_dir/'workload.json').read_text())
    psi = psi_summary(args.run_dir/'psi.csv')
    timing = parse_time(args.run_dir/'time-v.txt')

    lines = [
        f"# IO-01B measured evidence — {args.run_dir.name}",
        "",
        "This file reports measurements only; it does not prescribe an optimization.",
        "",
        "## Workload",
        f"- Files: {workload.get('files')}",
        f"- Repeats: {workload.get('repeats')}",
        f"- Logical bytes/pass: {workload.get('logical_bytes_per_pass')}",
        f"- Logical bytes processed: {workload.get('logical_bytes_processed')}",
        f"- Scan elapsed seconds: {workload.get('elapsed_seconds')}",
        f"- Effective MiB/s: {workload.get('effective_mib_per_second')}",
        f"- Correctness: {workload.get('correctness')}",
        "",
        "## /usr/bin/time -v",
    ]
    for k in [
        'User time (seconds)', 'System time (seconds)',
        'Percent of CPU this job got', 'Elapsed (wall clock) time (h:mm:ss or m:ss)',
        'Maximum resident set size (kbytes)', 'Major (requiring I/O) page faults',
        'Minor (reclaiming a frame) page faults', 'File system inputs', 'File system outputs',
        'Voluntary context switches', 'Involuntary context switches',
    ]:
        if k in timing:
            lines.append(f"- {k}: {timing[k]}")

    lines += ["", "## PSI summary"]
    for k in sorted(psi):
        lines.append(f"- {k}: {psi[k]}")

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text('\n'.join(lines) + '\n', encoding='utf-8')


if __name__ == '__main__':
    main()
