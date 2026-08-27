.PHONY: paper clean

paper:
	cd paper && pdflatex -interaction=nonstopmode -halt-on-error ai_hpc_agentic_workflows.tex
	cd paper && pdflatex -interaction=nonstopmode -halt-on-error ai_hpc_agentic_workflows.tex

clean:
	rm -f paper/*.aux paper/*.log paper/*.out paper/*.toc paper/*.bbl paper/*.blg
