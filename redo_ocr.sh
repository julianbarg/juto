#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Configurable defaults
PDF_OCR_REMOVE_SCRIPT="$HOME/juto/remove_PDF_text.py"
TMP_DIR="$HOME/tmp"
DEFAULT_OUTDIR="$HOME/out"
DEFAULT_CORES=6
AUTHOR=""

# Default options for ocrmypdf
DESK_SKEW=""
JBIG2_LOSSY=""
OUTFILE=""
VERBOSE=false

# Define a help function for the script usage
function help {
    echo "Usage: $0 [-h|--help] [--title TITLE] [--author AUTHOR] [--skip-first] [--skip-last] [--no-title] [--deskew] [--clean-final] [--lossy] [--out OUTFILE] [-v|--verbose] input_file"
    echo
    echo "Options:"
    echo "  -h, --help             Show this help message and exit"
    echo "  -t, --title TITLE      Specify the title, used for ocrmypdf and output filename"
    echo "  -a, --author AUTHOR    Specify the author, passed to ocrmypdf"
    echo "  -s, --skip-first       Optional, if present will strip the first page"
    echo "      --skip-last        Optional, if present will strip the last page"
    echo "      --no-title         Opt out of title requirement"
    echo "  -d, --deskew           Optional, if present will deskew the input using ocrmypdf"
    echo "  -i, --clean-final      Pass '--clean-final' to ocrmypdf"
    echo "  -l, --lossy            Optional, if present will pass '--jbig2-lossy' to ocrmypdf"
    echo "  -o, --out OUTFILE      Optional, specify the output file"
    echo "  -v, --verbose          Optional, print all the arguments/flags"
    exit 1
}

# Check if no arguments were provided
if [ $# -eq 0 ]; then
    help
fi

# Parse command line options.
OPTS=$(getopt -o ht:a:sdil:o:v --long help,title:,author:,skip-first,skip-last,no-title,deskew,clean-final,lossy,out:,verbose -- "$@")
if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi
eval set -- "$OPTS"

while true; do
  case "$1" in
    -h | --help )
      help
      ;;
    -t | --title ) 
      TITLE="$2"
      shift 2
      ;;
    -a | --author )
      AUTHOR="$2"
      shift 2
      ;;
    -s | --skip-first ) 
      STRIPFIRST=true
      shift
      ;;
    --skip-last ) 
      SKIPLAST=true
      shift
      ;;
    --no-title ) 
      NO_TITLE_REQ=true
      shift
      ;;
    -d | --deskew ) 
      DESK_SKEW="--deskew"
      shift
      ;;
    -i | --clean-final )
      CLEAN_FINAL="--clean-final"
      shift
      ;;
    -l | --lossy )
      JBIG2_LOSSY="--jbig2-lossy"
      shift
      ;;
    -o | --out )
      OUTFILE="$2"
      shift 2
      ;;
    -v | --verbose )
      VERBOSE=true
      shift
      ;;
    -- ) 
      shift
      break
      ;;
    * ) 
      break
      ;;
  esac
done

# Verify the input PDF file
if [[ -z "$1" ]]; then
    echo "Input file not provided"
    help
fi
inputfile=$1

# Verify the TITLE if not opted out
if [[ -z "$TITLE" ]] && [[ -z "$NO_TITLE_REQ" ]]; then
    echo "Title not provided"
    help
fi

# If no title provided, use the input file name as title
if [[ -z "$TITLE" ]]; then
    TITLE=$(basename "$inputfile" .pdf)
fi

# If no outfile provided, use the title as output filename
if [[ -z "$OUTFILE" ]]; then
    OUTFILE="${DEFAULT_OUTDIR}/${TITLE}.pdf"
fi

# If verbose mode enabled, print all the arguments/flags
if $VERBOSE; then
    echo "input file: $inputfile"
    echo "title: ${TITLE:-}"
    echo "author: ${AUTHOR:-}"
    echo "skip first: ${STRIPFIRST:-false}"
    echo "skip last: ${SKIPLAST:-false}"
    echo "no title: ${NO_TITLE_REQ:-false}"
    echo "deskew: ${DESK_SKEW:-false}"
    echo "clean final: ${CLEAN_FINAL:-false}"
    echo "lossy: ${JBIG2_LOSSY:-false}"
    echo "out file: $OUTFILE"
    echo "verbose: $VERBOSE"
fi

# Remove the OCR layer
echo "Removing OCR layer..."
"$PDF_OCR_REMOVE_SCRIPT" "$inputfile" "$TMP_DIR/removed_ocr.pdf"
inputfile="$TMP_DIR/removed_ocr.pdf"

# Strip the first page unless opted out
if [[ ! -z "${STRIPFIRST:-}" ]]; then
    echo "Stripping the first page..."
    pdftk "$inputfile" cat 2-end output "$TMP_DIR/stripped_first_page.pdf"
    inputfile="$TMP_DIR/stripped_first_page.pdf"
fi

# Strip the last page unless opted out
if [[ ! -z "${SKIPLAST:-}" ]]; then
    echo "Stripping the last page..."
    num_pages=$(pdftk "$inputfile" dump_data | grep NumberOfPages | cut -d":" -f2)
    let "num_pages-=1"
    pdftk "$inputfile" cat 1-$num_pages output "$TMP_DIR/stripped_last_page.pdf"
    inputfile="$TMP_DIR/stripped_last_page.pdf"
fi

# Run OCR to create a new OCR layer
echo "Creating a new OCR layer..."
ocrmypdf -l eng --title "$TITLE" --author "$AUTHOR" -O3 ${CLEAN_FINAL:-} \
  $JBIG2_LOSSY $DESK_SKEW --jobs "$DEFAULT_CORES" \
  "$inputfile" "$OUTFILE"