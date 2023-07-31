#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

# Default values
DENSITY=750
THRESHOLD="70%"
QUALITY=60
FULL_PAGE=false
DESKEW=false
VERBOSE=false
DEFAULT_CORES=6

# Display help message
usage() {
  echo "Usage: $0 [OPTIONS] <input-file> <output-file>"
  echo
  echo "Options:"
  echo "  -d, --density      Set the density (default $DENSITY)"
  echo "  -t, --threshold    Set the threshold (default $THRESHOLD)"
  echo "  -q, --quality      Set the quality (default $QUALITY)"
  echo "  --deskew           Enable deskewing using ocrmypdf"
  echo "  -f, --full         Process the entire file instead of just the middle page"
  echo "  -v, --verbose      Print variables and steps"
  echo "  -h, --help         Display this help message and exit"
}

# Function to print verbose messages
verbose() {
  [ "$VERBOSE" = true ] && echo "$@"
}

# Array to store non-option arguments
ARGS=()

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -d|--density)
      DENSITY="$2"; shift ;;
    -t|--threshold)
      THRESHOLD="$2"; shift ;;
    -q|--quality)
      QUALITY="$2"; shift ;;
    --deskew)
      DESKEW=true ;;
    -f|--full)
      FULL_PAGE=true ;;
    -v|--verbose)
      VERBOSE=true ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      ARGS+=("$1") ;;
  esac
  shift
done

# Check if exactly two non-option arguments were provided
if [[ "${#ARGS[@]}" -ne 2 ]]; then
  usage
  exit 1
fi

FILE="${ARGS[0]}"
OUT="${ARGS[1]}"

verbose "Density: $DENSITY, Threshold: $THRESHOLD, Quality: $QUALITY, Full Page: $FULL_PAGE, Deskew: $DESKEW"

# Perform the operation only on the middle page if -f is not set
if [ "$FULL_PAGE" = false ]; then
  verbose "Processing only the middle page."
  PAGES=$(pdfinfo "$FILE" | grep 'Pages:' | awk '{print $2}')
  MIDDLE_PAGE=$(( (PAGES / 2) + 1 ))
  TEMP_FILE="$HOME/tmp/middle_page.pdf"
  pdftk "$FILE" cat $MIDDLE_PAGE output "$TEMP_FILE"
  FILE="$TEMP_FILE"
fi

if [ "$DESKEW" = true ]; then
  verbose "Deskewing the file."
  ocrmypdf "$FILE" -d -f --jobs "$DEFAULT_CORES" "$HOME/tmp/deskew.pdf" \
    && FILE="$HOME/tmp/deskew.pdf"
  [ "$FULL_PAGE" = true ] && notify-send "Finished deskewing."
fi

verbose "Removing background."
gs -sOutputFile="$HOME/tmp/background.pdf" \
   -sDEVICE=pdfwrite \
   -dCompatibilityLevel=1.4 \
   -sColorConversionStrategy=Gray \
   -dBlackText=true \
   -dProcessColorModel=/DeviceGray \
   -dNOPAUSE \
   -dBATCH \
   "$FILE"
[ "$FULL_PAGE" = true ] && notify-send "Removed background."

verbose "Converting to black and white."
convert -density "$DENSITY" -threshold "$THRESHOLD" -quality "$QUALITY" \
        "$HOME/tmp/background.pdf" "$HOME/tmp/bw.pdf"

[ "$FULL_PAGE" = true ] && notify-send "Converted to b/w."

verbose "Processing complete."

cp "$HOME/tmp/bw.pdf" ${OUT}

xdg-open "${OUT}" &
