BASENAME := $(shell grep -l "\documentclass" *.tex)
BASENAME := $(shell basename $(BASENAME) .tex)
DATE := $(shell date +"%Y_%m_%d_%H%M")
OUTPUTNAME := pdfs/$(BASENAME).$(DATE).pdf
TEXCOMMAND := pdflatex
TEXOPTS    := "-halt-on-error"
BIBCOMMAND := bibtex
TEXFILES   := $(shell find . -iname "*.tex" -o -iname "*.bib")
UTEXFILES  := $(shell find unsorted -name "*.tex" | \grep -v main.tex )

view : $(OUTPUTNAME)
	@-evince $(shell ls -t pdfs/*.pdf|head -n 1)

$(OUTPUTNAME) : $(TEXFILES) unsorted/main.tex makefile /usr/share/texlive/texmf-dist/tex/latex/base/article.cls 
	mkdir -p pdfs
	$(TEXCOMMAND) $(TEXOPTS) -jobname $(BASENAME) $(BASENAME).tex
	cat refs/*.bib > refs.bib
	$(BIBCOMMAND) $(BASENAME)
	$(TEXCOMMAND) $(TEXOPTS) -jobname $(BASENAME) $(BASENAME).tex > /dev/null
	$(TEXCOMMAND) $(TEXOPTS) -jobname $(BASENAME) $(BASENAME).tex
	@/bin/rm -rf  -rf *.log *.aux *.bbl *.blg *.out *.toc *.lot *.lof refs.bib
	@find refs -type f -name "*~" -delete
	perl -pi -e "s/.*?ModDate.*/\/ModDate (D:20130418152511-04'00')/" $(BASENAME).pdf
	perl -pi -e "s/.*?CreationDate.*/\/CreationDate (D:20130418152541-04'00')/" $(BASENAME).pdf
	perl -pi -e "s/.*?\/ID.*/\/ID [<0535B734E397B655F1D0DD37FD8A8CF9> <0535B734E397B655F1D0DD37FD8A8CF9>]/" $(BASENAME).pdf
	cp $(BASENAME).pdf $(OUTPUTNAME)
	mv $(BASENAME).pdf joseph_bylund_thesis.pdf
	fdupes pdfs -q -d -N

clean :
	@/bin/rm -rf  -rf *.log *.aux *.bbl *.blg *.out *.toc *.lot *.lof refs.bib
	@/bin/rm -f $(OUTPUTNAME)

unsorted/main.tex : $(UTEXFILES)
	-rm unsorted/main.tex
	for i in $(shell ls unsorted/*.tex | \grep -v main.tex); do j=`basename $$i .tex`; echo "\input{unsorted/$$j}" >> unsorted/main.tex; done

.PHONY : clean view
