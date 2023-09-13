# Defaults are already set
PATTERN="$1"
shift # Move to the next argument

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -o) DIR="$2"; shift ;;
        -i) INDIR="$2"; shift ;;
        -f) FILETYPE="$2"; shift ;;
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

# Copy the file to the destination
DESTINATION="$DIR/$PATTERN.$FILETYPE"
cp "$FILE" "$DESTINATION"

echo "File copied to $DESTINATION"
