#!/bin/bash
shopt -s extglob

for i in +([0-9])-*.ipynb
do 
   jupyter nbconvert --ClearOutputPreprocessor.enabled=True --clear-output $i
done
