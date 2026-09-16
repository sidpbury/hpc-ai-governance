# Cover Letter - IJHPCA

Dear Editors,

Please consider the manuscript **“Progressive Governance for Agentic AI in High-Performance Computing: Behavioral Steering and MCP Authorization”** for publication as an Original Research Article in *The International Journal of High Performance Computing Applications*.

The manuscript addresses an emerging HPC systems problem: how institutions can use agentic large language models to assist researchers without making the model itself an uncontrolled source of scheduler authority. The paper reports a five-phase controlled case study that separates evidence selection, evidence interpretation, authorization-sensitive behavior, technical enforcement, and response to adversarial repository context. The experiments use Slurm workload evidence and Linux Pressure Stall Information as representative operational signals, and a constrained Model Context Protocol service as the external authorization boundary for simulated scheduler actions.

The principal result is a separation of responsibilities. Project-level Markdown instructions changed which HPC evidence the tested agent selected and whether it attempted a scheduler state change when researcher authorization was absent. When an action was explicitly requested, however, an external MCP control plane independently enforced the authorization decision: all 20 unauthorized requests were denied and all 20 authorized requests were allowed exactly once. Production Slurm was intentionally not contacted by the state-changing experimental backend, and the manuscript states this limitation explicitly. A fifth adversarial-context experiment then placed conflicting repository instructions in the project. Under absent authorization, MCP submission attempts increased from 3/10 benign-context trials to 8/10 adversarial-context trials, but all 11 unauthorized requests were denied and no direct scheduler bypass was observed in 40 sessions.

We believe the paper fits IJHPCA because it evaluates a supporting technology for operational HPC rather than presenting a generic application of AI. The manuscript focuses on scheduler integration, HPC telemetry, reproducible evaluation, constrained capabilities, and the boundary between language-model reasoning and privileged execution. It also relates the method to recent IJHPCA work on rigorous evaluation of LLM scientific assistants.

A development version of the study materials and manuscript has been maintained in a public GitHub repository together with executable experiment artifacts. It has not been published as a peer-reviewed article. Please advise if the journal would prefer this public development manuscript to be treated or disclosed as a preprint during processing.

Generative AI tools were used during manuscript preparation for literature-search organization, reference compilation, and editorial restructuring. All references, numerical results, experimental claims, and retained artifacts were checked by the author. This assistance is disclosed in the manuscript acknowledgements.

**Before submission, please confirm:** the manuscript is not currently under consideration by another journal and all statements concerning funding and conflicts of interest are accurate.

Thank you for your consideration.

Sincerely,

Sidney L. Pendelberry  
Rochester Institute of Technology  
College of Engineering  
Department of Industrial and Systems Engineering  
Corresponding-author email: **[add before submission]**
