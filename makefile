BASENAME := $(shell grep -l "\documentclass" *.tex)
BASENAME := $(shell basename $(BASENAME) .tex)
DATE := $(shell date +"%Y_%m_%d_%H%M")
OUTPUTNAME := pdfs/$(BASENAME).$(DATE).pdf
TEXCOMMAND := pdflatex
BIBCOMMAND := bibtex
TEXFILES   := $(shell ls *.tex refs/*.bib */*.tex)

view : $(OUTPUTNAME)
	@-evince $(shell ls -t pdfs/*.pdf|head -n 1)

$(OUTPUTNAME) : $(TEXFILES) makefile /usr/share/texlive/texmf-dist/tex/latex/base/article.cls 
	mkdir -p pdfs
	$(TEXCOMMAND) -jobname $(BASENAME) $(BASENAME).tex
	cat refs/*.bib > refs.bib
	$(BIBCOMMAND) $(BASENAME)
	$(TEXCOMMAND) -jobname $(BASENAME) $(BASENAME).tex
	$(TEXCOMMAND) -jobname $(BASENAME) $(BASENAME).tex
	@/bin/rm -rf  -rf *.log *.aux *.bbl *.blg *.out *.toc *.lot *.lof refs.bib
	@find refs -type f -name "*~" -delete
	perl -pi -e "s/.*?ModDate.*/\/ModDate (D:20130418152511-04'00')/" $(BASENAME).pdf
	perl -pi -e "s/.*?CreationDate.*/\/CreationDate (D:20130418152541-04'00')/" $(BASENAME).pdf
	perl -pi -e "s/.*?\/ID.*/\/ID [<0535B734E397B655F1D0DD37FD8A8CF9> <0535B734E397B655F1D0DD37FD8A8CF9>]/" $(BASENAME).pdf
	cp $(BASENAME).pdf $(OUTPUTNAME)
	mv $(BASENAME).pdf joseph_bylund_thesis.pdf
	fdupes pdfs -q -d -N

clean : 
	@/bin/rm -rf  -rf *.log *.aux *.bbl *.blg *~ *.out *.toc *.lot *.lof
	@/bin/rm -f $(OUTPUTNAME)

.PHONY : clean view
