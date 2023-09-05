#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./check [directory-path|file-type] [file-type]

This script opens the most recent file based on the provided directory and/or file type.

Examples:
./check $HOME/Downloads .pdf  # Opens the most recent pdf in the Downloads folder
./check .pdf                  # Opens the most recent pdf in $HOME/out
./check ~/Downloads           # Opens the most recent file of any type in the Downloads folder
'
    exit
fi

# Default directory and file type
DIR="$HOME/out"
FILETYPE="*"

# Function to check if a path is a directory
is_dir() {
    [[ -d "$1" ]]
}

# Handle the first argument
if [[ -n "${1-}" ]]; then
    if is_dir "$1"; then
        DIR="$1"
    else
        FILETYPE="$1"
    fi
fi

# Handle the second argument (if it exists)
if [[ -n "${2-}" ]]; then
    FILETYPE="$2"
fi

# Use the 'find' command to get the most recent file
# and 'xargs' to pass it as an argument to 'xdg-open'
# which will open the file with the default application
find "$DIR" -maxdepth 1 -name "*$FILETYPE" -print0 | xargs -0 ls -lt | head -n 1 | awk '{print $NF}' | xargs xdg-open
