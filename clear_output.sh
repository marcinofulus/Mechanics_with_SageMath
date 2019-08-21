#!/bin/bash
shopt -s extglob

if [[ $# -eq  1 ]]
then

    jupyter nbconvert --ClearOutputPreprocessor.enabled=True --clear-output $1

else
    for i in +([0-9])-*.ipynb
    do 
       jupyter nbconvert --ClearOutputPreprocessor.enabled=True --clear-output $i
    done

fi
