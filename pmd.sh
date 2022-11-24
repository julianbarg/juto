#!/usr/bin/env bash

set -o nounset
set -o errexit

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

main () {
  local INPUT="$1"
  local DESTINATION="$2"
  local NAME=$(basename "$INPUT" .pdf)
  local TMP="$HOME/tmp/$NAME"

  echo "Destination: $DESTINATION"
  echo "Input: $INPUT"

  pdfbox ExtractText -html "$INPUT" "$TMP.html"
  sed -z "s#\n</i>#\n</i>\n\n</p><p>#g" "$TMP.html" -i
  sed -z "s#\n</b>#\n</b>\n\n</p><p>#g" "$TMP.html" -i
  pandoc "$TMP.html" -t markdown -o "$TMP.md" 
  sed -e "s#</*div>##g" \
    -e "s/^:::$//g" \
    -e 's/^::: {style="page-break-before:always; page-break-after:always"}$//g' \
    -e "s/^\*\*/\n\*\*/g" \
    -e "s/\*\*$/\*\*\n/g" \
    -e 's/[«»]//g' \
    -e 's//•/g' \
    -e 's/\\//g' "$TMP.md" -i
  sed -z -e "s/\n/«/g" \
    -e 's/\([^«]\)\(«\)\([^«]\)/\1 \3/g' \
    -e "s/«/\n/g" "$TMP.md" -i 
  sed "s/^[^0-9a-zA-Z]*$//g" "${TMP}.md" -i

  sed -E "s/[^0-9a-zA-Z.]//g" "${TMP}.md" > "${TMP}_stripped.md"
  delete_lines=$(grep -E "^.{1,3}$" "${TMP}_stripped.md" -n \
    | cut -f1 -d: \
    | tac)
  if [[ ! -z $delete_lines ]]; then
    for deleted_line in $delete_lines; do
      sed "${deleted_line}d" "${TMP}.md" -i
    done
  fi

  # sed -E "s/^.{1,10}$//g" "$TMP.md" -i 
  sed -z "s/\([a-z]\)\(\n\n\)\([a-z]\)/\1 \3/g" "$TMP.md" -i 
  echo "$(fmt -w 72 "${TMP}.md")" > "${TMP}.md" 
  cat "$HOME/juto/default_header.yaml" > "$DESTINATION" 
  cat -s "$TMP.md" >> "$DESTINATION"
  subl "$DESTINATION"
}

main "$@"
