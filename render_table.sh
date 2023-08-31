#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

# Default values
WIDTHS=""
ALIGNS=""
WIDTH=""
TEMP_FILE_MD=$(mktemp)  # Temporary markdown file
TEMP_FILE_HTML=$(mktemp --suffix=.html)  # Temporary HTML file with .html suffix
SCRIPT_DIR=$(dirname "$0")  # Directory of the current script

function print_help {
    echo "Usage: $0 INPUT OUTPUT [OPTIONS]"
    echo "  INPUT                 Input file (Markdown format)"
    echo "  OUTPUT                Output file (PNG format)"
    echo "Options:"
    echo "  -w, --widths          Widths for table columns (comma-separated, optional)"
    echo "  -a, --aligns          Aligns for table columns (comma-separated, optional)"
    echo "  -W, --width           Width for output PNG (optional)"
    exit 1
}

# Parse arguments
POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -w|--widths)
            WIDTHS="$2"
            shift
            shift
            ;;
        -a|--aligns)
            ALIGNS="$2"
            shift
            shift
            ;;
        -W|--width)
            WIDTH="$2"
            shift
            shift
            ;;
        *)
            POSITIONAL+=("$1")
            shift
            ;;
    esac
done

set -- "${POSITIONAL[@]}"  # Restore positional parameters

if [ $# -ne 2 ]; then
    echo "ERROR: Incorrect number of arguments."
    print_help
fi

INPUT="$1"
OUTPUT="$2"

# Create the modified Markdown file
echo -n ":::{.list-table" > "$TEMP_FILE_MD"
[[ ! -z "$WIDTHS" ]] && echo -n " widths=\"$WIDTHS\"" >> "$TEMP_FILE_MD"
[[ ! -z "$ALIGNS" ]] && echo -n " aligns=\"$ALIGNS\"" >> "$TEMP_FILE_MD"
echo "}" >> "$TEMP_FILE_MD"
cat "$INPUT" >> "$TEMP_FILE_MD"
echo ":::" >> "$TEMP_FILE_MD"

# Convert Markdown to HTML using pandoc with the list-table.lua filter
pandoc "$SCRIPT_DIR/render_table.md" "$TEMP_FILE_MD" -f markdown -t html --lua-filter="$SCRIPT_DIR/list-table.lua" -o "$TEMP_FILE_HTML"

# Convert the HTML to a PNG using wkhtmltopdf
if [[ -z "$WIDTH" ]]; then
    wkhtmltoimage --minimum-font-size 12 "$TEMP_FILE_HTML" "$OUTPUT"
else
    wkhtmltoimage --minimum-font-size 12 --width "$WIDTH" "$TEMP_FILE_HTML" "$OUTPUT"
fi

# Cleanup temporary files
rm -f "$TEMP_FILE_MD" "$TEMP_FILE_HTML"
