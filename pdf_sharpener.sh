#!/usr/bin/env bash

FILE="$1"
# TMP="$HOME/tmp/$(basename "$FILE" .pdf)"
OUT="$2"
# THRESHOLD="${3:-80}"
TITLE="$3"

if [ ! -n "$3" ]; then
  echo "Need to provide title as third argument!"
  exit 0
fi


ocrmypdf "$FILE" -d -f "$HOME/tmp/deskew.pdf" \
  && notify-send "Finished deskewing." \
  && gs   -sOutputFile="$HOME/tmp/background.pdf" \
          -sDEVICE=pdfwrite \
          -dCompatibilityLevel=1.4 \
          -sColorConversionStrategy=Gray \
          -dBlackText=true \
          -dProcessColorModel=/DeviceGray \
          -dNOPAUSE \
          -dBATCH \
          "$HOME/tmp/deskew.pdf" \
  && notify-send "Removed background." \
  && convert -density 900 -threshold 70%  \
        "$HOME/tmp/background.pdf" "$HOME/tmp/bw.pdf" \
  && notify-send "Converted to b/w." \
  && ocrmypdf "$HOME/tmp/bw.pdf" "$OUT" --title "$TITLE" --jbig2-lossy -O3 \
  && notify-send "Completed processing PDF."


# echo $THRESHOLD
# echo $TMP
# echo $OUT

# NUM_PAGES=$(pdftk "$FILE" dump_data | grep NumberOfPages | awk '{print $2}')
# MIDDLE_PAGE=$((($NUM_PAGES + 1) / 2))

# pdftoppm "$FILE" -f $MIDDLE_PAGE -png -singlefile "$TMP" \
#   && convert "$TMP.png" -normalize -threshold "${THRESHOLD}%" \
#       "$HOME/tmp/preview_${THRESHOLD}.png" \
#   && ocrmypdf "$HOME/tmp/preview_${THRESHOLD}.png" -O3 \
#       "$HOME/tmp/preview_${THRESHOLD}.pdf" \
#   && xdg-open "$HOME/tmp/preview_${THRESHOLD}.pdf" \
#   && pdftoppm "$FILE" -png "$TMP" \
#   && convert "${TMP}-*" -normalize -threshold "${THRESHOLD}%" \
#       "${TMP}.pdf" \
#   && ocrmypdf -d "${TMP}.pdf" -O3 "$OUT"

# 
#   convert "$tmp*" -normalize -threshold "$THRESHOLD" &&

