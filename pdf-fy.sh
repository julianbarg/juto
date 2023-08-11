#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

# Default values
num_files=1
output_file=""
folder="."  # Default to current directory
density=300
quality=85

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./pdf-fy.sh [OPTIONS] output_file.pdf

This script concatenates the latest images from a specified folder and converts them to a PDF.

Options:
  -n    Number of latest files to concatenate (default: 1)
  -f    Folder to look for the latest files (default: current directory)
  -d    Density for the PDF (default: 300)
  -q    Quality for the PDF (default: 85)
'
    exit
fi

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -n) num_files="$2"; shift ;;
        -f) folder="$2"; shift ;;
        -d) density="$2"; shift ;;
        -q) quality="$2"; shift ;;
        *) output_file="$1" ;;
    esac
    shift
done

if [[ -z "$output_file" ]]; then
    echo "Error: Output file not specified."
    exit 1
fi

# Calculate dimensions based on density
width_in_pixels=$(awk "BEGIN {print int(8.5 * $density)}")
height_in_pixels=$(awk "BEGIN {print int(11 * $density)}")

# Get the latest files
files=$( "$(dirname "$0")/latest.sh" -f "$folder" -n "$num_files" )

# Convert to PDF with specified density, quality, and dimensions
convert -quality "$quality" -resize ${width_in_pixels}x${height_in_pixels} $files -page Letter "$output_file"
