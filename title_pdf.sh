#!/bin/bash

usage() {
    echo "This script updates the title metadata of a PDF file."
    echo "Usage: $0 -t title filename"
    echo "Options:"
    echo "  -t, --title    Specify the title of the PDF"
    echo "  -h, --help     Show this help message and exit"
    exit 1
}

# Check if no parameters were passed and display usage
if [ $# -eq 0 ]; then
    usage
    exit 1
fi

# Parse options to the `option` variable
option=$(getopt -o t:h --long title:,help -- "$@")
[ $? -eq 0 ] || {
    echo "Incorrect options provided"
    exit 1
}

eval set -- "$option"

while true; do
    case "$1" in
    -t|--title)
        TITLE=$2
        shift 2
        ;;
    -h|--help)
        usage
        exit 0
        ;;
    --)
        shift
        FILE=$1
        break
        ;;
    esac
done

# If title or file is not provided, print usage and exit
if [ -z "$TITLE" ] || [ -z "$FILE" ]; then
    usage
fi

INFO="
InfoKey: Title
InfoValue: ${TITLE}"

# Use echo to pipe info directly into pdftk
echo "$INFO" | pdftk "$FILE" update_info - output "${HOME}/titlefix.pdf" \
  && mv "${HOME}/titlefix.pdf" "$FILE"