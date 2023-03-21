#!/usr/bin/env bash

FILE="$1"
TMP="$HOME/tmp/$(basename $FILE .pdf)"
THRESHOLD="${2:-80}"
OUT="$3"

# echo $THRESHOLD
# echo $TMP
# echo $OUT

pdftoppm $FILE -png -singlefile "$TMP" \
  && convert "$TMP.png" -normalize -threshold "${THRESHOLD}%" \
      "$HOME/tmp/preview_${THRESHOLD}.png" \
  && ocrmypdf "$HOME/tmp/preview_${THRESHOLD}.png" -O3 \
      "$HOME/tmp/preview_${THRESHOLD}.pdf" \
  && xdg-open "$HOME/tmp/preview_${THRESHOLD}.pdf" \
  && pdftoppm $FILE -png "$TMP" \
  && convert "${TMP}-*" -normalize -threshold "${THRESHOLD}%" \
      "${TMP}.pdf" \
  && ocrmypdf "${TMP}.pdf" -O3 "$OUT"

# 
#   convert "$tmp*" -normalize -threshold "$THRESHOLD" &&

