alias mandoc="pandoc \
  -f markdown+yaml_metadata_block+multiline_tables \
  --reference-doc $HOME/Templates/gw_review_manuscript.docx\
  --citeproc --bibliography ~/bibliography.bib \
  --csl ~/Templates/apa-6-no-initials.csl"
