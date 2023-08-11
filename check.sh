#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

# Define the folder to search in
folder="$HOME/out"

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./check.sh

This script finds the latest file in $HOME/out and opens it using xdg-open.

'
    exit
fi

cd "$(dirname "$0")"


latest_file=$(./latest.sh "$folder")

# Check if a file was found
if [ -z "$latest_file" ]; then
    echo "No files found in $folder."
    exit 1
fi

# Use xdg-open to open the latest file
xdg-open "$latest_file"
