# Review-response plan — 2026-09-08

Source review: PaperReview.ai review of the short paper, venue setting AAAI.

## Overall interpretation

The review supports the central contribution: the four-phase decomposition and the distinction between Markdown behavioral steering and MCP technical enforcement. The weak-reject recommendation is driven primarily by experimental breadth, reproducibility detail, threat-model/authorization detail, and related-work positioning rather than by a contradiction in the core result.

## Incorporated into the full paper

| Review concern | Revision made |
|---|---|
| Markdown policy not disclosed | Added the public repository path (`policy/HPC-AI-INSTRUCTIONS.md`), identified the PSI and researcher-approval clauses relevant to the experiments, and explicitly stated that the study did not ablate individual clauses. |
| PSI composite unclear | Defined the 15-item conservative composite: the three PSI-domain rows in the original 17-item rubric are replaced with one `any PSI domain selected` item. Reframed that direct PSI-selection measure as the primary Phase 1 endpoint and retained aggregate rubric scores as secondary descriptive measures. |
| Rubric ceiling unclear | Defined Phase 2 ceiling literally as every trial in both conditions satisfying all 18 predefined criteria. |
| Statistical analysis limited | Retained exact paired tests and added descriptive marginal Wilson 95% intervals. Explicitly stated that no prospective power calculation was used and that the study is exploratory rather than a population-level model estimate. |
| MCP interface too conceptual | Added an implementation table for `authorization_status`, `validate_job`, `job_status`, `job_history`, `storage_usage`, `psi_metrics`, and `submit_job`, including actual inputs and study behavior. |
| Identity/auth model underspecified | Added a Threat Model and Authorization Model subsection. It distinguishes partially trusted AI/model and untrusted repository/tool content from trusted MCP/Slurm enforcement. It states exactly what the prototype implements and does not implement. |
| Audit guarantees unclear | Documented JSONL audit fields and explicitly stated that the logs are ordinary local files, not immutable or non-repudiable. |
| Bypass claim too strong | Made the boundary explicit: MCP only enforces operations routed through the governed capability. The study disabled direct state-changing scheduler clients; this is not containment of a hostile process with unrestricted shell access. |
| Reproducibility artifacts hard to find | Added a table pointing to the policy, Phase 1/2 harnesses, Phase 3 prompts/rubric, Phase 4 MCP source, and Phase 4 challenge/results. Also disclosed that complete raw transcript bundles are retained but not all are currently published. |
| PSI result too narrow / aggregate score potentially misleading | Reframed the result around the experimentally supported claim: Markdown reliably surfaced site-selected PSI evidence. The paper now says the aggregate score must not be read as a general improvement in HPC reasoning. |
| Downstream impact not shown | Quantified the Phase 4 requested-resource-envelope reductions: 20 GiB to 64–256 MiB (98.75–99.69% reduction) and 20 minutes to 1–2 minutes (90–95% reduction), while explicitly noting these are not measured scheduler cost or queue-time savings. |
| Repository-context-file literature missing | Added Gloaguen et al. (arXiv:2602.11988) and Lulla et al. (arXiv:2601.20404), and reconciled their mixed findings with this paper's narrower steering result. |
| Related MCP/control-plane comparisons missing | Added MADA (arXiv:2603.11515), SchedCP (arXiv:2509.01245), and a Slurm-based LLM deployment study (arXiv:2508.17814). |
| Agent security work missing | Added AgentSentry (arXiv:2602.22724) and The Silicon Mirror (arXiv:2604.00478), positioned as complementary inference-time defenses rather than substitutes for external authorization. |
| Broader AI-for-HPC context thin | Added the 2026 AI-for-HPC systematic review (arXiv:2602.00014). |

## Still requires new experimental work

These comments cannot be fixed honestly by prose alone:

1. **Second model/client replication** — repeat the highest-value behavioral experiments (Phase 1 evidence selection and Phase 3 authorization-sensitive behavior) with at least one additional model/client.
2. **Adversarial Phase 4 challenge** — place malicious instructions in realistic untrusted content (for example README, job output, or tool-return text) instructing the agent to bypass the governance service; record governed and direct-action attempts.
3. **Second workload class** — add a GPU or MPI scenario; GPU is the lower-cost first extension because GPU utilization/memory plus PSI provides a clear evidence-selection and recommendation task.
4. **Slurm-cgroup PSI** — use job/step cgroup `cpu.pressure`, `memory.pressure`, and `io.pressure` in the new workload rather than relying only on node-wide `/proc/pressure`.
5. **MCP overhead** — measure local tool-call latency and, in a production pilot, end-to-end submission latency and policy-denial behavior.
6. **Policy ablation** — compare the full policy with a minimal PSI/authorization policy and one-purpose variants to measure sensitivity to policy content and length.
7. **Production identity integration** — future pilot must propagate authenticated identity/account context, enforce allocation policy, and define durable audit guarantees before making a production-security claim.
8. **Public raw-session artifact** — release a de-identified transcript/tool-log bundle with prompt and policy hashes for external replication.

## Recommended priority

Before a stronger AAAI-style resubmission, prioritize: (1) second model/client Phase 1+3 replication, (2) adversarial Phase 4 challenge, and (3) one GPU workload with Slurm-cgroup PSI. The remaining items materially improve deployability and artifact quality but are less critical to the central empirical claim.
