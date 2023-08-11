#!/usr/bin/env bash

# Default values
number=1
folder="."
recursive=false

print_help() {
    echo "Usage: $0 [-n number_of_files] [-r|--recursive] [folder_location]"
    echo "  -n: Number of latest files to fetch. Default is 1."
    echo "  -r, --recursive: Search recursively in subfolders."
    echo "  folder_location: Directory to search in. Default is current directory."
    exit 1
}

# Check if no arguments provided
if [ "$#" -eq 0 ]; then
    print_help
fi

while [ "$#" -gt 0 ]; do
    case "$1" in
        -n)
            shift
            number="$1"
            ;;
        -r|--recursive)
            recursive=true
            ;;
        *)
            # Assuming it's the folder location
            folder="$1"
            ;;
    esac
    shift
done

# Check if recursive flag is set
if $recursive; then
    find_cmd="find \"$folder\" -not -path '*/.*' -type f"
else
    find_cmd="find \"$folder\" -maxdepth 1 -not -path '*/.*' -type f"
fi

# Execute the command
eval "$find_cmd -printf '%T@ %p\n'" \
    | sort -n \
    | tail -"$number" \
    | cut -f2- -d" "

