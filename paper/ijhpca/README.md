# IJHPCA submission package

Target journal: **The International Journal of High Performance Computing Applications** (Sage).

## Files

- `../ai_hpc_agentic_workflows.tex` / `.pdf` - canonical, non-blinded journal manuscript.
- `ijhpca_manuscript_blinded.tex` / `.pdf` - anonymized peer-review manuscript.
- `ijhpca_title_page.tex` / `.pdf` - separate author/title page.
- `COVER-LETTER.md` - draft cover letter.
- `SUBMISSION-CHECKLIST.md` - journal-specific preflight checklist.
- `REFERENCE-AUDIT.md` - verification record for the shortened journal bibliography.
- `references.bib` - machine-readable reference records for future reference-manager use.

## Build

The manuscript intentionally uses a manual Sage-Harvard-formatted reference list with `natbib`, so BibTeX is not required.

```bash
pdflatex -interaction=nonstopmode -halt-on-error ai_hpc_agentic_workflows.tex
pdflatex -interaction=nonstopmode -halt-on-error ai_hpc_agentic_workflows.tex

cd ijhpca
pdflatex -interaction=nonstopmode -halt-on-error ijhpca_manuscript_blinded.tex
pdflatex -interaction=nonstopmode -halt-on-error ijhpca_manuscript_blinded.tex
pdflatex -interaction=nonstopmode -halt-on-error ijhpca_title_page.tex
```

## Experimental scope

The manuscript reports the completed five-phase study: IO-01B evidence selection and interpretation, IO-01C authorization-sensitive behavior, IO-01D MCP enforcement, and IO-01E adversarial repository-context testing.

The IO-01E action result is derived from the machine-generated MCP and direct-action tables. The generated `master-scorecard.csv` remained an unfilled template and is not used to support any Phase 5 claim.
