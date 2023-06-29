#!/bin/bash

# Configurable defaults
PDF_OCR_REMOVE_SCRIPT="$HOME/juto/remove_PDF_text.py"
TMP_DIR="$HOME/tmp"
DEFAULT_OUTDIR="$HOME/out"
DEFAULT_CORES=6

# Define a help function for the script usage
function usage {
    echo "Usage: $0 [--title TITLE] [--strip-first] [--opt-out] input_file"
    echo "--title, -t       specify the title, used for ocrmypdf and output filename"
    echo "--skip-strip, -s  optional, if present will skip stripping the first page"
    echo "--opt-out, -o     opt out of title requirement"
    exit 1
}

# Parse command line options.
OPTS=$(getopt -o t:so --long title:,skip-strip,opt-out -- "$@")
if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi
eval set -- "$OPTS"

while true; do
  case "$1" in
    -t | --title ) 
      TITLE="$2"
      shift 2
      ;;
    -s | --skip-strip ) 
      STRIPFIRST=false
      shift
      ;;
    -o | --opt-out ) 
      NO_TITLE_REQ=true
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
if [ -z "$1" ]; then
    echo "Input file not provided"
    usage
fi
inputfile=$1

# Verify the TITLE if not opted out
if [ -z "$TITLE" ] && [ -z "$NO_TITLE_REQ" ]; then
    echo "Title not provided"
    usage
fi

# If no title provided, use the input file name as title
if [ -z "$TITLE" ]; then
    TITLE=$(basename "$inputfile" .pdf)
fi

# Remove the OCR layer
echo "Removing OCR layer..."
"$PDF_OCR_REMOVE_SCRIPT" "$inputfile" "$TMP_DIR/removed_ocr.pdf"
inputfile="$TMP_DIR/removed_ocr.pdf"

# Strip the first page unless opted out
if [ "$STRIPFIRST" != "false" ]; then
    echo "Stripping the first page..."
    pdftk "$inputfile" cat 2-end output "$TMP_DIR/stripped_first_page.pdf"
    inputfile="$TMP_DIR/stripped_first_page.pdf"
fi

# Run OCR to create a new OCR layer
echo "Creating a new OCR layer..."
ocrmypdf -l eng --title "$TITLE" -O3 --jbig2-lossy --jobs "$DEFAULT_CORES" "$inputfile" "${DEFAULT_OUTDIR}/${TITLE}.pdf"
