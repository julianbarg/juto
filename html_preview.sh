#!/usr/bin/env bash

pandoc $1 -f markdown -t html --citeproc --bibliography $HOME/bibliography.bib --csl /home/julian/apa-6th-edition.csl -o /home/julian/Documents/temp.html && gnome-www-browser /home/julian/Documents/temp.html
