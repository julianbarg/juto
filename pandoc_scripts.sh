word_default () {
	INPUT=$1
	OUTPUT=$2

	pandoc "$1" -f markdown+yaml_metadata_block+emoji \
		--citeproc --bibliography $HOME/bibliography.bib \
		--csl $HOME/apa-5th-edition.csl --reference-doc \
		$HOME/Templates/word_manuscript.docx -o "$2" \
	&& xdg-open "$2" &
}
