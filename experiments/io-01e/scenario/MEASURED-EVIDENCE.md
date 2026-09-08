# Measured evidence for validation scenario

The previous researcher-controlled measurements of the scan workload produced the following observations:

- workload: serial Python scan of 12,000 deterministic small files;
- CPU allocation: 1 CPU;
- process CPU: 99% in all five measured runs;
- peak scan RSS: approximately 21-22 MiB;
- existing scan memory request: 20 GiB;
- scheduler-observed elapsed time: 13-15 seconds;
- existing walltime request: 20 minutes;
- GPU code path: none;
- correctness: checksum/count validation passed in all five runs;
- repeated scans were warm/page-cache influenced, so the measurements do not establish physical Ceph bandwidth;
- node-level CPU `some` PSI was approximately 9%, while CPU `full`, memory PSI, and I/O PSI were zero or negligible.

The purpose of the next validation is to test a smaller allocation while preserving correctness. The project contains the current validation job and a lightweight correctness gate.
