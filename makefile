BASENAME := $(shell grep -l "\documentclass" *.tex)
BASENAME := $(shell basename $(BASENAME) .tex)
DATE := $(shell date +"%Y_%m_%d_%H%M")
OUTPUTNAME := pdfs/$(BASENAME).$(DATE).pdf
TEXCOMMAND := pdflatex
TEXOPTS    := -halt-on-error
BIBCOMMAND := bibtex
TEXFILES   := $(shell find . -iname "*.tex")
BIBFILES   := $(shell find refs -iname "*.bib")
UTEXFILES  := $(shell find unsorted -name "*.tex" | \grep -v main.tex )
FLOWCHARTS := dot_files/mcm_flowchart.png dot_files/idsite.png dot_files/regression_testing.png

view : $(OUTPUTNAME)
	@-evince $(shell ls -t pdfs/*.pdf|head -n 1)

$(OUTPUTNAME) : $(TEXFILES) $(FLOWCHARTS) unsorted/main.tex makefile /usr/share/texlive/texmf-dist/tex/latex/base/article.cls refs.bib cell_based_solvent/paper.tex
	$(TEXCOMMAND) $(TEXOPTS) -jobname $(BASENAME) $(BASENAME).tex
	$(BIBCOMMAND) $(BASENAME)
	$(TEXCOMMAND) $(TEXOPTS) -jobname $(BASENAME) $(BASENAME).tex
	$(TEXCOMMAND) $(TEXOPTS) -jobname $(BASENAME) $(BASENAME).tex
	@find refs -type f -name "*~" -delete
	mkdir -p pdfs
	perl -pi -e "s/.*?ModDate.*/\/ModDate (D:20130418152511-04'00')/" $(BASENAME).pdf
	perl -pi -e "s/.*?CreationDate.*/\/CreationDate (D:20130418152541-04'00')/" $(BASENAME).pdf
	perl -pi -e "s/.*?\/ID \[<.*/\/ID [<0535B734E397B655F1D0DD37FD8A8CF9> <0535B734E397B655F1D0DD37FD8A8CF9>]/" $(BASENAME).pdf
	cp $(BASENAME).pdf $(OUTPUTNAME)
	mv $(BASENAME).pdf joseph_bylund_thesis.pdf
	@/bin/rm -rf  -rf *.log *.aux *.bbl *.blg *.out *.toc *.lot *.lof
	fdupes pdfs -q -d -N

cell_based_solvent/paper.tex :
	git submodule init
	git submodule update
	cd cell_based_solvent; checkout master

refs.bib : $(BIBFILES)
	/bin/cat refs/*.bib > refs.bib

clean :
	@/bin/rm -rf  -rf *.log *.aux *.bbl *.blg *.out *.toc *.lot *.lof
	@/bin/rm -f $(OUTPUTNAME)

# rule to make each flowchart
dot_files/%.png: dot_files/%.dot
	dot -Gnewrank -Tpng -o $@ $<

unsorted/main.tex : $(UTEXFILES)
	-rm unsorted/main.tex
	./scripts/make_unsorted

.PHONY : clean view
