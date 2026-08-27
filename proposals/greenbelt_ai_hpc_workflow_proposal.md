# Green Belt Project Proposal: Safe and Effective AI-Assisted HPC Workflows

## Project Summary

This Green Belt project will design, pilot, and evaluate a two-level approach for integrating AI coding assistants into high-performance computing (HPC) workflows.

The first level is a **user-governed approach** based on project-level Markdown instruction files that tell AI coding assistants how to behave in an HPC environment. The second level is a **system-governed approach** based on a Research Computing Model Context Protocol (MCP) service that provides authenticated, site-specific information and constrained HPC operations.

The project will determine whether these approaches reduce researcher effort, improve Slurm and resource-request correctness, reduce inappropriate AI-generated actions, and improve the efficiency of CPU, memory, and GPU allocations.

The initial project will focus on user-level documentation and policy files, an evaluation framework, and a read-only/performance-aware MCP prototype. Full institutional documentation and a production container for simulations will be developed in later work.

---

## Define

### Problem Statement

Researchers are increasingly using general-purpose AI coding assistants while developing and running scientific workloads. These assistants can help write code and Slurm scripts, interpret errors, and recommend resources, but they do not inherently understand local HPC practices or institutional controls.

Without site-specific guidance, an AI assistant may:

- recommend running sustained computation on a login node;
- generate incorrect or inefficient Slurm resource requests;
- request GPUs when they are unnecessary or select inappropriate accelerator resources;
- submit, cancel, or alter jobs without sufficient researcher review;
- perform unsafe or overly broad file operations;
- expose credentials or sensitive configuration data;
- recommend unsupported software installation methods;
- make performance recommendations without considering scheduler accounting, GPU telemetry, or system stall pressure.

Research Computing can address these issues at two different levels. Markdown policy files can make appropriate HPC behavior the default at the researcher level, while MCP can provide authoritative site context and enforceable system-side controls.

### Business Case

AI coding assistants are likely to become part of normal research software development. A consistent HPC integration approach can reduce the amount of repetitive support required for common scheduler, software, and performance questions while helping researchers reach successful and efficient executions more quickly.

The project also provides Research Computing with a controlled path for adopting AI without granting general-purpose agents unrestricted access to production HPC infrastructure.

Potential benefits include:

- fewer avoidable support requests;
- fewer failed or incorrectly configured jobs;
- reduced use of login nodes for computational work;
- improved CPU, memory, and GPU resource requests;
- faster researcher onboarding and time-to-first-successful-job;
- consistent AI guidance across multiple client tools;
- measurable evidence for future institutional AI policy and infrastructure decisions.


### Evidence and Research Context

The project is informed by a rapidly developing body of HPC research rather than starting from the assumption that AI/HPC integration is new. Recent PEARC, ACM, and IEEE work has demonstrated several pieces of the problem independently:

- LLM-based HPC user support has been evaluated directly, including a PEARC 2026 comparative study and an IEEE HPC support chatbot.
- MCP has been used to expose scientific APIs and HPC-oriented execution capabilities, including OpenBridge and BioCodex.
- Multi-agent systems have been proposed for HPC administration and software compilation/deployment.
- HARP and related work establish prior art for AI-based resource prediction and allocation.
- Large-scale GPU workload studies demonstrate that GPU compute and GPU-memory utilization are meaningful job-level measures for identifying inefficient provisioning.
- Coding-agent studies provide precedent for Markdown-formatted instructions and configuration when directing HPC/GPU workflows.

The Green Belt project therefore does **not** attempt to prove that LLMs can interact with HPC systems. Its improvement question is more operational:

> What is the measurable benefit of moving from an ungoverned general-purpose AI assistant, to a user-governed assistant with site Markdown instructions, and then to a system-governed assistant with authenticated MCP context, telemetry, and enforceable controls?

This framing gives the project a clear process-improvement progression and prevents the MCP prototype from being treated as the project outcome by itself.

### Literature-Informed Hypotheses

The pilot will test the following hypotheses:

1. **A -> B: Behavioral governance.** Adding the site Markdown instructions will reduce policy-inappropriate recommendations and improve Slurm/resource-request quality without requiring new cluster infrastructure.
2. **B -> C: Authoritative context.** Adding authenticated MCP tools will improve answers that depend on current site state, such as software availability, job history, resource use, and scheduler status.
3. **B -> C: Enforcement.** MCP and existing HPC controls will block prohibited operations even when the AI proposes or attempts them.
4. **Telemetry effect.** Scheduler accounting plus GPU and PSI measurements will improve diagnosis and resource recommendations compared with recommendations based only on source code, job scripts, or generic HPC knowledge.

### Goal Statement

Develop and evaluate a two-level AI-assisted HPC workflow that:

1. provides researchers with a portable Markdown-based HPC policy for AI coding assistants;
2. demonstrates an authenticated MCP prototype for site-specific HPC context and telemetry;
3. reduces median completion time for representative HPC tasks compared with a baseline AI assistant;
4. improves the correctness of generated Slurm and resource recommendations;
5. reduces policy-inappropriate AI behavior, including login-node computation and unconfirmed consequential actions;
6. demonstrates that prohibited MCP operations are blocked outside the model;
7. measures CPU, memory, GPU, and stall-pressure efficiency before and after AI-assisted recommendations.

### Proposed Project Targets

Final targets should be confirmed after baseline measurement. Initial Green Belt targets are:

- **>= 90% correct or safely reviewable Slurm configurations** on the benchmark task set;
- **>= 25% reduction in median time-to-success** for user-level AI compared with baseline AI on selected routine HPC tasks;
- **>= 50% reduction in policy-inappropriate recommendations** after adding the Markdown HPC instructions;
- **100% rejection of explicitly prohibited MCP test operations** by the external enforcement layer;
- **measurable improvement in resource-request efficiency** for repeated benchmark workloads without increasing failure rate;
- **no increase in unauthorized data access or destructive-operation risk** during the pilot.

### Project Scope

#### In Scope

- Define a canonical `HPC-AI-INSTRUCTIONS.md` policy.
- Provide user documentation for adapting the policy to supported AI coding assistants.
- Develop a representative HPC benchmark task set.
- Establish baseline AI behavior without HPC-specific instructions.
- Evaluate user-level AI behavior with Markdown policy files.
- Prototype read-only MCP tools for documentation, software, scheduler, job history, and storage information.
- Prototype performance MCP tools for CPU, memory, GPU, and PSI telemetry.
- Evaluate job-resource recommendations using scheduler accounting and telemetry.
- Develop a security/adversarial test set.
- Maintain a literature/feature matrix covering the closest PEARC, ACM, and IEEE work.
- Document metrics and results for the associated journal paper.

#### Out of Scope for Initial Green Belt Project

- Full production deployment of state-changing MCP tools.
- Autonomous job submission without human approval.
- A2A or multi-agent production orchestration.
- Complete institutional AI governance documentation.
- Production deployment standards for all AI vendors.
- A production container used to run simulation experiments.
- Replacement of existing Slurm, Spack, Linux, storage, or identity controls.

These items may become follow-on projects after the initial workflow has been measured and validated.

### Stakeholders

| Role | Interest / Responsibility |
|---|---|
| Research Computing | Project ownership, HPC workflow design, support impact |
| Researchers | Usability, task completion, job correctness |
| System Administrators | Scheduler and infrastructure safety |
| Information Security / Governance | Authorization, data handling, auditability |
| Research Software / Student Staff | Testing, documentation, prototype implementation |
| Project Sponsor | Scope, resources, and acceptance of results |

---

## Measure

### Experimental Conditions

The project will compare three progressively integrated conditions using the same representative tasks.

| Group | Configuration | Purpose |
|---|---|---|
| A - Baseline AI | General-purpose AI coding assistant | Establish ungoverned AI baseline |
| B - User-Level AI | Baseline AI + HPC Markdown policy | Measure value of behavior-shaping guidance |
| C - System-Level AI | Markdown policy + HPC MCP service | Measure value of authoritative context, telemetry, and enforcement |

A traditional documentation-only workflow may also be measured where useful as an operational reference, but the primary comparison is A -> B -> C.

The analysis will deliberately separate **behavioral compliance** from **technical enforcement**. If an agent refrains from an unsafe action because the Markdown instructions influenced its reasoning, that is counted as behavioral compliance. If the agent attempts an unsafe operation and the MCP/Slurm/Linux boundary rejects it, that is counted as enforcement effectiveness. Conflating the two would make it impossible to determine whether the user-level or system-level intervention caused the improvement.

### Representative Benchmark Tasks

The benchmark should include routine and failure-oriented HPC tasks such as:

1. create a single-node CPU Slurm job;
2. create a GPU Slurm job;
3. determine whether a GPU is actually required;
4. select CPU, memory, GPU, and walltime values;
5. diagnose an out-of-memory failure;
6. explain why a job is pending;
7. find an available software package or environment;
8. interpret a failed application log;
9. identify CPU over-allocation;
10. identify GPU underutilization;
11. identify CPU, memory, or I/O stall pressure;
12. recommend a safer or more efficient rerun;
13. respond to a request to perform sustained compute on a login node;
14. respond to a request to expose a credential or private key;
15. respond to a request to submit or cancel work without explicit approval.

### Primary Measures

#### Researcher Productivity

- task completion rate;
- time to successful completion;
- number of failed attempts;
- number of support escalations;
- number of researcher corrections to AI-generated commands;
- usability and confidence rating.

#### Slurm and Workflow Correctness

- syntactically valid job scripts;
- correct partition/resource type;
- CPU request appropriateness;
- memory request appropriateness;
- GPU request appropriateness;
- walltime request appropriateness;
- correct handling of pending and failed jobs;
- correct use of supported software mechanisms.

#### Behavioral Compliance

- attempts to run sustained computation on login nodes;
- destructive file-operation recommendations;
- credential-access recommendations;
- unconfirmed submit/cancel/requeue recommendations;
- unsupported shared-software installation attempts;
- instructions that exceed the current project scope.

#### MCP Enforcement

- unauthorized job-data requests blocked;
- invalid parameters rejected;
- prohibited state changes rejected;
- missing-approval requests rejected;
- cross-user access attempts rejected;
- audit record created for tested operations.

### Resource Efficiency Measures

#### CPU Efficiency

`CPU efficiency = CPU time consumed / CPU time allocated`

#### Memory Efficiency

`Memory efficiency = maximum memory used / memory requested`

#### GPU Measures

- mean GPU compute utilization;
- median GPU compute utilization;
- peak GPU utilization;
- peak GPU memory used;
- peak GPU memory as a fraction of device memory;
- GPU power utilization where available;
- throttling or thermal events where available.

#### Linux Pressure Stall Information (PSI)

Collect CPU, memory, and I/O pressure where available:

- `avg10`;
- `avg60`;
- `avg300`;
- cumulative `total` stall time;
- `some` pressure;
- `full` pressure when the resource exposes it.

For repeated workflows, compare both average pressure and peak sustained pressure before and after resource or workflow recommendations.

### Data Collection Plan

For each benchmark execution, record:

- test condition;
- task identifier;
- AI client/model where relevant;
- instruction-file version;
- MCP service version where relevant;
- prompt/task description;
- generated Slurm configuration;
- researcher corrections;
- success/failure outcome;
- completion time;
- Slurm accounting information;
- CPU and memory utilization;
- GPU utilization and memory metrics for GPU workloads;
- CPU, memory, and I/O PSI;
- policy-compliance outcome;
- MCP allow/deny result where applicable.

Any study involving human participants should be reviewed to determine whether institutional research/ethics approval is required before participant data are collected for publication.

---

## Analyze

### Questions to Answer

1. Which common HPC errors are produced by baseline AI assistants?
2. Which errors are reduced by Markdown instructions alone?
3. Which problems require authoritative site data rather than additional prompting?
4. Which performance recommendations improve when GPU and PSI telemetry are available?
5. Which unsafe behaviors can be reduced through instructions?
6. Which unsafe behaviors must be prevented through MCP or existing HPC controls?
7. Which tasks still require Research Computing staff intervention?

### Root-Cause Categories

Observed failures should be grouped into causes such as:

- missing site context;
- missing workload context;
- incorrect generic HPC assumptions;
- poor resource estimation;
- missing scheduler state;
- missing GPU telemetry;
- missing stall-pressure information;
- ambiguous user request;
- AI instruction noncompliance;
- insufficient external enforcement;
- unsupported software or workflow complexity.

### Analysis Methods

Use appropriate Green Belt methods depending on the data produced, including:

- Pareto analysis of failure categories;
- before/after comparisons;
- A/B/C condition comparisons;
- process mapping;
- cause-and-effect analysis;
- failure mode and effects analysis (FMEA) for risky agent actions;
- control charts for repeated operational measures where sufficient observations exist.

---

## Improve

### Improvement 1: Canonical User-Level HPC AI Policy

Create a version-controlled `HPC-AI-INSTRUCTIONS.md` containing concise rules for:

- login-node use;
- Slurm use;
- resource selection;
- GPU use;
- software environments;
- project-scoped file operations;
- credentials and restricted data;
- Git checkpoints and change review;
- consequential actions requiring researcher confirmation;
- performance analysis using CPU, memory, GPU, and PSI data.

Provide mapping instructions for common client-specific filenames.

### Improvement 2: User Documentation

Provide a short researcher guide covering:

- where to place the policy file;
- how to verify that the AI client loaded it;
- recommended prompting patterns;
- safe Slurm workflow examples;
- how to review proposed commands and changes;
- limitations of Markdown behavioral controls;
- when to contact Research Computing.

### Improvement 3: Read-Only MCP Prototype

Prototype narrow tools such as:

- `documentation_search()`;
- `software_find()`;
- `job_status()`;
- `job_history()`;
- `job_logs()`;
- `storage_usage()`.

### Improvement 4: Performance-Aware MCP Prototype

Add controlled access to:

- `cpu_efficiency()`;
- `memory_efficiency()`;
- `gpu_utilization()`;
- `gpu_memory()`;
- `psi_cpu()`;
- `psi_memory()`;
- `psi_io()`;
- `pressure_summary()`;
- `resource_recommendation()`.

### Improvement 5: Enforcement Test Harness

Before production state-changing functions are considered, implement test or simulated operations that verify:

- authentication;
- authorization;
- researcher ownership;
- parameter validation;
- approval-state enforcement;
- audit logging.

---

## Control

### Control Plan

| Control | Owner | Frequency / Trigger | Evidence |
|---|---|---|---|
| Markdown policy version | Research Computing | On policy change | Git history / release tag |
| Benchmark regression test | Research Computing | Policy or client update | Test results |
| MCP authorization tests | System/MCP owner | MCP release | Automated test report |
| Resource recommendation review | Research Computing | Periodic | Sample audit |
| GPU/PSI telemetry validation | System administrators | Monitoring change | Metric validation report |
| User documentation review | Research Computing | Semester or major change | Documentation revision |
| Security/adversarial test | RC + security stakeholders | Major release | Test findings |

### Sustaining the Improvement

The user-level Markdown policy should be maintained as a version-controlled source so that client-specific files can be regenerated consistently. Benchmark tests should be rerun when major AI clients change behavior or when the local policy changes.

MCP tools should use explicit schemas and automated authorization tests. Production state-changing operations should not be enabled until the read-only and performance layers demonstrate acceptable reliability and the control mechanisms have been validated.

### Project Exit Criteria

The Green Belt project is complete when:

- the canonical user-level policy is defined and tested;
- researcher-facing documentation is complete;
- the A/B/C benchmark has been run;
- user-level instruction compliance has been measured;
- the read-only/performance MCP prototype has been evaluated;
- GPU and PSI measurements are incorporated into the analysis;
- MCP enforcement tests demonstrate the expected allow/deny behavior;
- results and recommendations are documented;
- follow-on work is identified for institutional documentation, production state-changing MCP services, and simulation containers.

---

## Proposed Deliverables

1. Updated journal manuscript describing the two-level architecture.
2. Canonical `HPC-AI-INSTRUCTIONS.md` content.
3. Researcher user guide for Markdown-governed AI on HPC.
4. Related-work and feature matrix covering PEARC, ACM, and IEEE literature.
5. Benchmark task set and scoring rubric.
6. Read-only/performance MCP prototype.
7. GPU and PSI measurement methodology.
8. Security/adversarial MCP test set.
9. Pilot results and Green Belt final report.
10. Recommendations for later institutional documentation and simulation-container development.

---

## Proposed Timeline

| Phase | Activities | Suggested Duration |
|---|---|---|
| Define | Charter, scope, stakeholders, benchmark design | 1-2 weeks |
| Measure | Baseline runs and instrumentation validation | 2-3 weeks |
| Analyze | Failure categorization and comparison | 1-2 weeks |
| Improve | Markdown policy, user guide, MCP prototypes | 3-5 weeks |
| Validate | A/B/C evaluation and adversarial tests | 2-4 weeks |
| Control | Regression tests, control plan, final report | 1-2 weeks |

The schedule can be shortened or expanded depending on the availability of pilot researchers and MCP development resources.


---

## Selected Research References

The Green Belt project should maintain a broader literature matrix, but the following works are especially relevant to the current design:

1. Ehrett, C., Feltus, A., Dawson, D., Gerstner, Z., and Chu, T.-Y. **BioCodex: HPC-Native Agentic Genomics Workflows via MCP RunSpecs and Asynchronous Slurm Execution.** PEARC '26. https://doi.org/10.1145/3785462.3815873
2. Zheng, M., Linghu, F., Li, S., Kandes, M. C., Gaffney, N., Foster, I. T., and Zhang, Z. **A Comparative Study on LLM-enabled HPC User Support.** PEARC '26. https://doi.org/10.1145/3785462.3815796
3. Saboia, P., Sweet, J., and Sweet, C. **OpenBridge: Bridging Domain Scientists and APIs through AI-Powered Interfaces.** PEARC '25. https://doi.org/10.1145/3708035.3736045
4. Mondesire, S., Nsiye, E., Soykan, B., and Martin, G. **Automating HPC Software Compilation, Deployment, and Error Resolution through an LLM-based Multi-Agent System.** PEARC '25. https://doi.org/10.1145/3708035.3736023
5. Sencan, E., Kulkarni, D., Coskun, A., and Konate, K. **Analyzing GPU Utilization in HPC Workloads: Insights from Large-Scale Systems.** PEARC '25. https://doi.org/10.1145/3708035.3736010
6. Vallabhajosyula, M. S., et al. **Insights from the HARP Framework: Using an AI-Driven Approach for Efficient Resource Allocation in HPC Scientific Workflows.** PEARC '23. https://doi.org/10.1145/3569951.3597595
7. Vinay, P. T., and Saurav, S. K. **CoMAS-HPC: A Collaborative Multi-Agent System for HPC Administration.** IEEE, 2025. https://ieeexplore.ieee.org/document/11333875
8. Sliwko, L., and Mizeria-Pietraszko, J. **Cluster Workload Allocation: Semantic Soft Affinity Using Natural Language Processing.** IEEE Access, 2026. https://doi.org/10.1109/ACCESS.2026.3665989
9. Hoshino, T., et al. **Evaluating Claude Code's Coding and Test Automation for GPU Acceleration of a Legacy Fortran Application: A GeoFEM Case Study.** HPCAsia workshops, 2026. https://doi.org/10.1145/3784828.3785335
