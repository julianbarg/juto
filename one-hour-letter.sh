#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

DATE=$(date +%F)
YEAR=$(date +%Y)

DOCS_DIR="$HOME/docs"
LETTER_EN="$HOME/Templates/letter_en.md"
LETTER_DE="$HOME/Templates/letter_de.md"
COMPILE_TEMPLATE="$HOME/Templates/compile_letter.sh"
LETTER_TEMPLATE=$LETTER_EN

help () {
  echo "Usage: ./compile.sh [OPTION]"
  echo "Options:"
  echo "  -l, --letter    Set project name."
  echo "  -d, --de        Use German letter template."
  exit 1
}

while (( "$#" )); do
  case "$1" in
    -h|--help)
      help
      ;;
    -l|--letter)
      shift
      LETTER=$1
      ;;
    -d|--de)
      LETTER_TEMPLATE=$LETTER_DE
      ;;
    *) 
      echo "Error: Invalid argument"
      help
      exit 1
      ;;
  esac
  shift
done

# Check if letter title is set
if [ -z "${LETTER:-}" ]; then
  echo "Error: Missing required option -l|--letter"
  help
fi

FOLDER="${DOCS_DIR}/${YEAR}/letters"
mkdir -p $FOLDER
cd $FOLDER

if [[ ! -f "${LETTER}.md" ]]; then
  cp $LETTER_TEMPLATE "${LETTER}.md"
fi

if [[ ! -f compile.sh ]]; then
  cp ${COMPILE_TEMPLATE} ./compile.sh
  chmod +x ./compile.sh
fi

subl "${LETTER}.md" --project "$HOME/docs/docs.sublime-project"
