NAME=inc
TARGET="../zprava.pdf"
TARGET2="../../test/zprava.pdf"
LOGIN=xskalo01

ALLFILES=$(NAME).tex makefile

pdf: all

all: $(NAME).tex
	latex $(NAME).tex
	pdflatex $(NAME).tex
	cp $(NAME).pdf $(TARGET)
	cp $(NAME).pdf $(TARGET2)

zip:
	zip $(LOGIN).zip $(ALLFILES)

clean:
	rm -f $(NAME).log $(NAME).dvi $(NAME).pdf $(NAME).aux $(NAME).out texput.log $(LOGIN).zip
