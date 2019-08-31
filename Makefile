SHELL := /bin/bash 
notebooks := $(wildcard *.ipynb)
notebooks_executed := $(foreach d,$(notebooks), notebooks4pdf/$(d) )


.PHONY: clean pdf notebooks dirs clean_output test

clear_output: 
	@echo CLEANING...
	./clear_output.sh
	@echo OK

#$(notebooks_executed) : $(notebooks)
#	@echo from $@
#	@echo to $%

test:
	@echo TEST
	@echo $(log1) $(log2)

notebooks4pdf/%.ipynb : %.ipynb
	@echo CLEANING OUTPUT of $< 
	@jupyter nbconvert --ClearOutputPreprocessor.enabled=True --clear-output $< 
	@echo Executing notebook  $< and writing it to $@
	@time PDF=1 jupyter nbconvert  --to notebook --execute  $< --output $@ 
	@echo Removing tagged cells in excecuted notebook
	@cd notebooks4pdf &&  jupyter nbconvert  --to notebook  $< --output $< --TagRemovePreprocessor.enabled=True --TagRemovePreprocessor.remove_cell_tags="['nbtest']"   



pdf: $(notebooks_executed)  latex_template2.tplx cas_utils.sage
	cd notebooks4pdf; python3 -m bookbook.latex --template ../latex_template2.tplx --pdf && mv combined.pdf ../mechanics_with_sagemath.pdf

html: $(notebooks_executed)
	@test -d html && rm -rv html || echo no html dir existed
	@cd notebooks4pdf &&  python3 -m bookbook.html  && mv html ../ -v && cp -r images  ../html/


clean:
	@rm -fv combined.*   *log *aux *tex
	@rm -frv notebooks4pdf/ html/

dirs:
	@test -d notebooks4pdf || mkdir -v notebooks4pdf && echo notebooks4pdf exists
	@test -L notebooks4pdf/images || ln -sv ../images notebooks4pdf/images && echo images link exists  


log1 := $(shell test -d notebooks4pdf || mkdir -v notebooks4pdf)
log2 := $(shell test -L notebooks4pdf/images || ln -sv ../images notebooks4pdf/images)
