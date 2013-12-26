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
FLOWCHARTS := dot_files/mcm_flowchart.png dot_files/idsite.png dot_files/regression_testing.png dot_files/perturbed_minimiztion.png

view : $(OUTPUTNAME)
	@-evince $(shell ls -t pdfs/*.pdf|head -n 1)

$(OUTPUTNAME) : named.bst $(TEXFILES) $(FLOWCHARTS) unsorted/main.tex makefile /usr/share/texlive/texmf-dist/tex/latex/base/article.cls refs.bib ccicons.sty
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

ccicons.zip: 
	wget --timestamping http://mirrors.ctan.org/fonts/ccicons.zip

texdirs:=$(shell bash -c "echo /usr/local/share/texmf/{doc/latex,fonts/enc/dvips,fonts/map/dvips,fonts/tfm/public,fonts/type1/public,fonts/opentype/public,tex/latex}/ccicons")

texdirs:
	echo $(texdirs) | xargs -n 1 -t sudo mkdir -p

ccicons.sty: ccicons.zip texdirs
	unzip -o ccicons.zip
	cd ccicons && latex ccicons.ins
	sudo mv -v ccicons/ccicons.pdf /usr/local/share/texmf/doc/latex/ccicons/.
	sudo mv -v ccicons/ccicons-u.enc /usr/local/share/texmf/fonts/enc/dvips/ccicons/.
	sudo mv -v ccicons/ccicons.map /usr/local/share/texmf/fonts/map/dvips/ccicons/.
	sudo mv -v ccicons/ccicons.tfm /usr/local/share/texmf/fonts/tfm/public/ccicons/.
	sudo mv -v ccicons/ccicons.pfb /usr/local/share/texmf/fonts/type1/public/ccicons/.
	sudo mv -v ccicons/ccicons.otf /usr/local/share/texmf/fonts/opentype/public/ccicons/.
	sudo mv -v ccicons/ccicons.sty /usr/local/share/texmf/tex/latex/ccicons/.
	sudo texhash
	sudo updmap-sys --enable Map ccicons.map


named.bst:
	wget --timestamping http://mirrors.rit.edu/CTAN/biblio/bibtex/contrib/named/named.bst

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
