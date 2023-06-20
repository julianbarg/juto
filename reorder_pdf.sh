#!/bin/bash

# your source pdf
src="tmp/input.pdf"

# a temporary pdf for operations
temp="tmp/temp.pdf"

# destination
dst="tmp/output.pdf"

cp $src $dst

for i in $(seq 3 4 242); do
    j=$(($i+1))
    
    # burst the pdf into individual pages
    pdftk $dst burst output pg_%04d.pdf

    # reorder the pages
    mv pg_$(printf %04d $i).pdf pg_$(printf %04d $i)_temp.pdf
    mv pg_$(printf %04d $j).pdf pg_$(printf %04d $i).pdf
    mv pg_$(printf %04d $i)_temp.pdf pg_$(printf %04d $j).pdf

    # combine the pages
    pdftk $(ls pg_*.pdf | sort -n) cat output $temp

    # replace the old pdf with the new one
    mv $temp $dst
done

# cleanup
rm pg_*.pdf
