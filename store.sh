#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

display_help() {
    echo 'Usage: ./store.sh PATTERN [OPTIONS]

This script moves the most recent file using the provided pattern as its 
filename to the target destination.

Arguments:
  PATTERN         The primary pattern to look for in filenames.

Options:
  -h, --help      Display this help message.
  -o, --output    Specify the output directory (default is $HOME/out).
  -i, --input     Specify the input directory (default is current directory).
  -f, --filetype  Specify the filetype (e.g., "pdf" or ".pdf"; default is "*").
  -p, --print     Enable print mode: Show filename before copying.
  -c, --check     Enable check mode: Open the file for inspection before copying.

Examples:
./store.sh example
    # Moves the most recent file in the default directory to 
    # .example_0.{$FILETYPE} or the next available number.

./store.sh example -f pdf
    # Moves the most recent pdf in the default directory to .example_0.pdf or 
    # the next available number.

./store.sh example -i ~/tmp -o ~/out -f pdf
    # Moves the most recent pdf from ~/tmp to ~/out/example_0.pdf or the 
    # next available number.
'
exit 0
}

# If no arguments or help is explicitly asked, display the help message.
if [[ "$#" -eq 0 || "${1-}" =~ ^-*h(elp)?$ ]]; then
    display_help
fi

# Default directory and file type
DIR="$HOME/out"
FILETYPE="*"

PATTERN=""

PRINT_MODE=0
CHECK_MODE=0

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -o|--output) DIR="$2"; shift ;;
        -i|--input) INDIR="$2"; shift ;;
        -f|--filetype) FILETYPE="${2#.}"; shift ;; # Strips leading period, if it exists.
        -p|--print) PRINT_MODE=1 ;;
        -c|--check) CHECK_MODE=1 ;;
        *) 
            if [[ -z "$PATTERN" && ! "$1" =~ ^- ]]; then
                PATTERN="$1"
            else
                echo "Unknown option or multiple patterns provided: $1"
                exit 1
            fi
            ;;
    esac
    shift # Move to the next argument
done

if [[ -z "$PATTERN" ]]; then
    echo "A pattern is required!"
    display_help
    exit 1
fi

# If INDIR isn't set, default to current directory
INDIR="${INDIR-.}" 

# Find the most recent file based on the pattern and file type
FILE=$(find "$INDIR" -maxdepth 1 -type f -name "*.$FILETYPE" -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d' ')

# Check if the file exists
if [[ -z "$FILE" ]]; then
    echo "No file found matching the pattern and filetype."
    exit 1
fi

# Compute checksum of the source file
CHECKSUM_SRC=$(sha256sum "$FILE" | awk '{print $1}')

# Loop over the last 25 files in the destination directory
for dest_file in $(ls -t ${DIR}/*.${FILETYPE} | head -25); do
    CHECKSUM_DEST=$(sha256sum "$dest_file" | awk '{print $1}')
    if [[ "$CHECKSUM_SRC" == "$CHECKSUM_DEST" ]]; then
        echo "Checksum of the file matches one of the last 25 files in the destination. Aborting."
        exit 1
    fi
done

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
    local counter=0
    local destination="${DIR}/${PATTERN}_${counter}.${FILETYPE}"
    while [[ -e "$destination" ]]; do
        ((counter++))
        destination="${DIR}/${PATTERN}_${counter}.${FILETYPE}"
    done
    echo "$destination"
}

DESTINATION=$(get_destination "$DIR/$PATTERN.$FILETYPE")

# Move the file to the destination
mv "$FILE" "$DESTINATION"

echo "File moved to $DESTINATION"
