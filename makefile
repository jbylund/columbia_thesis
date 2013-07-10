BASENAME := $(shell grep -l "\documentclass" *.tex)
BASENAME := $(shell basename $(BASENAME) .tex)
DATE := $(shell date +"%Y_%m_%d_%H%M")
OUTPUTNAME := $(BASENAME).$(DATE).pdf
TEXCOMMAND := pdflatex
BIBCOMMAND := bibtex
TEXFILES   := $(shell ls *.tex *.bib)

view : $(OUTPUTNAME) 
	@-evince $(shell ls -t pdfs/*.pdf|head -n 1)

$(OUTPUTNAME) : $(TEXFILES) makefile /usr/share/texlive/texmf-dist/tex/latex/base/article.cls pdfs
	$(TEXCOMMAND) -jobname $(BASENAME) $(BASENAME).tex
	$(BIBCOMMAND) $(BASENAME)
	$(TEXCOMMAND) -jobname $(BASENAME) $(BASENAME).tex
	$(TEXCOMMAND) -jobname $(BASENAME) $(BASENAME).tex
	/bin/rm -rf *.log *.aux *.bbl *.blg *~ *.out *.toc *.lot *.lof
	perl -pi -e "s/.*?ModDate.*/\/ModDate (D:20130418152511-04'00')/" $(BASENAME).pdf
	perl -pi -e "s/.*?CreationDate.*/\/CreationDate (D:20130418152541-04'00')/" $(BASENAME).pdf
	perl -pi -e "s/.*?\/ID.*/\/ID [<0535B734E397B655F1D0DD37FD8A8CF9> <0535B734E397B655F1D0DD37FD8A8CF9>]/" $(BASENAME).pdf
	mv $(BASENAME).pdf pdfs/$(BASENAME).$(DATE).pdf
	fdupes . -q -d -N

pdfs :
	@mkdir pdfs

clean : 
	@/bin/rm -rf *.log *.aux *.bbl *.blg *~
	@/bin/rm -f $(OUTPUTNAME)

.PHONY : clean view
