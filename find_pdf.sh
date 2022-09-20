ENTRY="$1"
FOLDER="$HOME/Zotero/storage/"
AUTHOR=$( yq '.author[0].family' <( echo "$ENTRY" ) )
YEAR=$( yq '.year' <( echo "$ENTRY" ) )
TITLE=$( yq '.title' <( echo "$ENTRY" ) )
TITLE=$( echo ${TITLE:0:20} )

# echo "Author: $AUTHOR"
# echo "Year: $YEAR"
# echo "Title: $TITLE"

HIT=$( find "$FOLDER" -mindepth 2 -maxdepth 2 -path "*${AUTHOR}*${YEAR}*${TITLE}*" )
echo $HIT
