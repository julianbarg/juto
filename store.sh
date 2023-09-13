#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./store.sh pattern [-o OUTDIR] [-i INDIR] [-f FILETYPE]

This script copies the most recent file to the target destination, using the provided pattern as a filename.

Examples:
./store.sh example                            # Copies the most recent file in the default directory to .example.{$FILETYPE}
./store.sh example -f pdf                     # Copies the most recent pdf in the default directory to .example.pdf
./store.sh example -i ~/tmp -o ~/out -f pdf   # Copies the most recent pdf from ~/tmp to ~/out/example.pdf
'
    exit
fi

# Default directory and file type
DIR="$HOME/out"
FILETYPE="*"

PATTERN="$1"
shift # Move to the next argument

PRINT_MODE=0
CHECK_MODE=0

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -o|--output) DIR="$2"; shift ;;
        -i|--input) INDIR="$2"; shift ;;
        -f|--filetype) FILETYPE="$2"; shift ;;
        -p|--print) PRINT_MODE=1 ;;
        -c|--check) CHECK_MODE=1 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
    shift # Move to the next argument
done

# If INDIR isn't set, default to current directory
INDIR="${INDIR-.}" 

# Find the most recent file based on the pattern and file type
FILE=$(find "$INDIR" -maxdepth 1 -type f -name "*.$FILETYPE" -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d' ')

# Check if the file exists
if [[ -z "$FILE" ]]; then
    echo "No file found matching the pattern and filetype."
    exit 1
fi

# If PRINT_MODE is enabled, show the filename to the user
if [[ "$PRINT_MODE" -eq 1 ]]; then
    echo "File to be copied: $FILE"
    read -p "Do you want to continue? [Y/n]: " RESPONSE
    RESPONSE="${RESPONSE,,}" # Convert to lowercase for easier matching
    if [[ "$RESPONSE" != "y" && "$RESPONSE" != "" ]]; then
        echo "User cancelled the operation."
        exit 1
    fi
fi

# If CHECK_MODE is enabled, open the file for user inspection
if [[ "$CHECK_MODE" -eq 1 ]]; then
    # Use xdg-open for Linux. If you want cross-platform, you'll need to adjust this.
    xdg-open "$FILE"
    read -p "After checking the file, do you want to continue? [Y/n]: " RESPONSE
    RESPONSE="${RESPONSE,,}" # Convert to lowercase for easier matching
    if [[ "$RESPONSE" != "y" && "$RESPONSE" != "" ]]; then
        echo "User cancelled the operation."
        exit 1
    fi
fi

# Function to determine the appropriate destination filename
get_destination() {
    local base="$1"
    local counter=1
    while [[ -e "$base" ]]; do
        base="${DIR}/${PATTERN}_${counter}.${FILETYPE}"
        ((counter++))
    done
    echo "$base"
}

DESTINATION=$(get_destination "$DIR/$PATTERN.$FILETYPE")

# Move the file to the destination
mv "$FILE" "$DESTINATION"

echo "File moved to $DESTINATION"