#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./script.sh [--skip-first] [--skip-last] input.pdf output.pdf

This script splits an A5 PDF into A4 and optionally skips the first and last pages.

Options:
    --skip-first    Skip the first page of the input PDF
    --skip-last     Skip the last page of the input PDF
'
    exit
fi

SKIP_FIRST=0
SKIP_LAST=0
INPUT=""
OUTPUT=""

# Parse arguments
while (( "$#" )); do
    case "$1" in
        --skip-first)
            SKIP_FIRST=1
            shift
            ;;
        --skip-last)
            SKIP_LAST=1
            shift
            ;;
        *)
            if [[ -z "$INPUT" ]]; then
                INPUT="$1"
            elif [[ -z "$OUTPUT" ]]; then
                OUTPUT="$1"
            else
                echo "Invalid argument: $1"
                exit 1
            fi
            shift
            ;;
    esac
done

if [[ -z "$INPUT" || -z "$OUTPUT" ]]; then
    echo "Input and output files must be specified."
    exit 1
fi

# Function to get the total number of pages in a PDF
get_page_count() {
    pdftk "$1" dump_data | grep NumberOfPages | awk '{print $2}'
}

main() {
    TEMP_FILE1=$(mktemp --suffix=.pdf)
    TEMP_FILE2=$(mktemp --suffix=.pdf)
    FINAL_OUTPUT=$(mktemp --suffix=.pdf)

    TOTAL_PAGES=$(get_page_count "$INPUT")

    # Extract the first page if required
    if [[ "$SKIP_FIRST" -eq 1 ]]; then
        FIRST_PAGE=$(mktemp --suffix=.pdf)
        pdftk "$INPUT" cat 1 output "$FIRST_PAGE"
        pdftk "$INPUT" cat 2-end output "$TEMP_FILE1"
    else
        cp "$INPUT" "$TEMP_FILE1"
    fi

    # Extract the last page if required
    if [[ "$SKIP_LAST" -eq 1 ]]; then
        LAST_PAGE=$(mktemp --suffix=.pdf)
        pdftk "$INPUT" cat end output "$LAST_PAGE"
        pdftk "$TEMP_FILE1" cat 1-$((TOTAL_PAGES - 2)) output "$TEMP_FILE2"
    else
        cp "$TEMP_FILE1" "$TEMP_FILE2"
    fi

    # Split A5 to A4
    mutool poster -x 2 "$TEMP_FILE2" "$OUTPUT"

    # Re-add the first and last pages if they were skipped
    if [[ "$SKIP_FIRST" -eq 1 ]] && [[ "$SKIP_LAST" -eq 1 ]]; then
        pdftk "$FIRST_PAGE" "$OUTPUT" "$LAST_PAGE" cat output "$FINAL_OUTPUT"
    elif [[ "$SKIP_FIRST" -eq 1 ]]; then
        pdftk "$FIRST_PAGE" "$OUTPUT" cat output "$FINAL_OUTPUT"
    elif [[ "$SKIP_LAST" -eq 1 ]]; then
        pdftk "$OUTPUT" "$LAST_PAGE" cat output "$FINAL_OUTPUT"
    else
        cp "$OUTPUT" "$FINAL_OUTPUT"
    fi

    # Move the final output to the specified output file
    mv "$FINAL_OUTPUT" "$OUTPUT"

    # Clean up temporary files
    rm -f "$TEMP_FILE1" "$TEMP_FILE2"
    [[ -n "${FIRST_PAGE-}" ]] && rm -f "$FIRST_PAGE"
    [[ -n "${LAST_PAGE-}" ]] && rm -f "$LAST_PAGE"
}

main "$@"
