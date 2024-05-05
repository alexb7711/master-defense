# LaTeX Makefile v1.0 -- LaTeX + PDF figures

##==============================================================================
# CONFIGURATION
##==============================================================================
.PHONY = clean help images set-version
MAKEFLAGS := --jobs=4
SHELL  = /bin/bash

##==============================================================================
# DIRECTORIES
##==============================================================================
SCRIPTS = ./org-doc-scripts
IMG     = img
MDPI    = Definitions

##==============================================================================
# FILES
##==============================================================================
DOC_SRC         = main.tex
TARGET          = sa-pap.pdf
ALL             = $(shell find . -type f -name "*.org")
FIGURES_TEX     = $(wildcard $(IMG)/*tex)
FIGURES_EPS     = $(wildcard $(MDPI)/*eps)
EPS_TO_PDF      = $(patsubst %.eps, %-eps-converted-to.pdf, $(FIGURES_EPS))
FIGURES_PDF     = $(patsubst %.tex, %.pdf, $(FIGURES_TEX))

##==============================================================================
# RECIPES
##==============================================================================

##------------------------------------------------------------------------------
#
all: images ## Build full thesis (LaTeX + figures)
	@command -v emacs && make emacs || echo "Emacs not installed... skipping"
	@printf "Generating $(TARGET)...\n"
	@bash -e $(SCRIPTS)/relative-path-bibtex $(DOC_SRC)
	@bash -e $(SCRIPTS)/build-pdf $(basename $(DOC_SRC)) $(TARGET)

##------------------------------------------------------------------------------
#
images: $(FIGURES_PDF) $(EPS_TO_PDF) ## Generate all the images for the project

##------------------------------------------------------------------------------
# Resources:
# - https://stackoverflow.com/questions/15559359/insert-line-after-match-using-sed
#
set-version: ## Stamp the document with date and git commit hash
	@$(eval VERSION=$(shell git describe --tags))
	@grep "$(VERSION)" $(DOC_SRC) > /dev/null || \
	sed -i 's/\\today/\\today : $(VERSION)/' $(DOC_SRC)

##------------------------------------------------------------------------------
#
clean:	## Clean LaTeX and output figure files
	@rm -f $(FIGURES_PDF)
	@rm -f $(EPS_TO_PDF)
	@rm -f $(patsubst %.pdf, %.aux, $(FIGURES_PDF))
	@rm -f $(patsubst %.pdf, %.log, $(FIGURES_PDF))
	@rm -f $(TARGET)
	@latexmk -silent -C $(DOC_SRC)

##------------------------------------------------------------------------------
# https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help:  ## Auto-generated help menu
	@grep -P '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	sort |                                                \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

##==============================================================================
# HELPER RECIPES
##==============================================================================

##------------------------------------------------------------------------------
#
%.pdf: %.tex  ## Figures for the manuscript
	@printf "Generating %s...\033[K\r" "$@"
	@pdflatex -shell-escape -interaction=nonstopmode -output-directory $(IMG) "$<" | \
	grep "^!" -A20 --color=always || true
