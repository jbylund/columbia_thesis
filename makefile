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
FLOWCHARTS := dot_files/mcm_flowchart.png

view : $(OUTPUTNAME)
	@-evince $(shell ls -t pdfs/*.pdf|head -n 1)

$(OUTPUTNAME) : $(TEXFILES) $(FLOWCHARTS) unsorted/main.tex makefile /usr/share/texlive/texmf-dist/tex/latex/base/article.cls refs.bib
	$(TEXCOMMAND) $(TEXOPTS) -jobname $(BASENAME) $(BASENAME).tex > /dev/null
	$(BIBCOMMAND) $(BASENAME) > /dev/null
	$(TEXCOMMAND) $(TEXOPTS) -jobname $(BASENAME) $(BASENAME).tex > /dev/null
	$(TEXCOMMAND) $(TEXOPTS) -jobname $(BASENAME) $(BASENAME).tex > /dev/null
	@find refs -type f -name "*~" -delete
	mkdir -p pdfs
	cp $(BASENAME).pdf $(OUTPUTNAME)
	mv $(BASENAME).pdf joseph_bylund_thesis.pdf
	@/bin/rm -rf  -rf *.log *.aux *.bbl *.blg *.out *.toc *.lot *.lof
	fdupes pdfs -q -d -N

#	perl -pi -e "s/.*?ModDate.*/\/ModDate (D:20130418152511-04'00')/" $(BASENAME).pdf
#	perl -pi -e "s/.*?CreationDate.*/\/CreationDate (D:20130418152541-04'00')/" $(BASENAME).pdf
#	perl -pi -e "s/.*?\/ID.*/\/ID [<0535B734E397B655F1D0DD37FD8A8CF9> <0535B734E397B655F1D0DD37FD8A8CF9>]/" $(BASENAME).pdf

refs.bib : $(BIBFILES)
	/bin/cat refs/*.bib > refs.bib

clean :
	@/bin/rm -rf  -rf *.log *.aux *.bbl *.blg *.out *.toc *.lot *.lof
	@/bin/rm -f $(OUTPUTNAME)

# rule to make each flowchart
dot_files/%.png: dot_files/%.dot
	dot -Tpng -o $@ $<

unsorted/main.tex : $(UTEXFILES)
	-rm unsorted/main.tex
	./scripts/make_unsorted

.PHONY : clean view
