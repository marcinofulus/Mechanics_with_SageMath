SHELL := /bin/bash 
notebooks := $(wildcard *.ipynb)
notebooks_executed := $(foreach d,$(notebooks), notebooks4pdf/$(d) )

.PHONY: clean pdf notebooks dirs clean_output

clear_output: 
	@echo CLEANING...
	./clear_output.sh
	@echo OK

#$(notebooks_executed) : $(notebooks)
#	@echo from $@
#	@echo to $%


notebooks4pdf/%.ipynb : %.ipynb
	@make dirs
	@echo CLEANING OUTPUT of $< 
	@jupyter nbconvert --ClearOutputPreprocessor.enabled=True --clear-output $<
	@echo executing notebook  $< and writing it to $@
	@time jupyter nbconvert  --to notebook --execute  $< --output $@  >& /tmp/nbconvert.log

pdf: $(notebooks_executed)  latex_template2.tplx cas_utils.sage
	cd notebooks4pdf; python3 -m bookbook.latex --template ../latex_template2.tplx --pdf && mv combined.pdf ../mechanics_with_sagemath.pdf



clean:
	@rm -fv combined.*  mechanics_with_sagemath.pdf *log *aux *tex
	@rm -frv notebooks4pdf/ html/

dirs:
	@test -d notebooks4pdf || mkdir -v notebooks4pdf && echo notebooks4pdf exists
	@test -L notebooks4pdf/images || ln -sv ../images notebooks4pdf/images && echo images link exists  
