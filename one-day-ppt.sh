#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

DATE=$(date +%F)
YEAR=$(date +%Y)

DOCS_DIR="$HOME/docs"
COMPILE_TEMPLATE="$HOME/Templates/compile_ppt.sh"
PPT_TEMPLATE="$HOME/Templates/slides.md"

help () {
  echo "Usage: ./compile.sh -p|--project [PROJECT]"
  echo "Options:"
  echo "  -h, --help      Print this help message."
  echo "  -p, --project   Set project name (required)."
  exit 1
}

while (( "$#" )); do
  case "$1" in
    -h|--help)
      help
      ;;
    -p|--project)
      shift
      PROJ=$1
      ;;
    *) 
      echo "Error: Invalid argument"
      help
      ;;
  esac
  shift
done

# Check if project name is set
if [ -z "${PROJ:-}" ]; then
  echo "Error: Missing required option -p|--project"
  help
fi

PROJ_FOLDER="${DOCS_DIR}/${YEAR}/${PROJ}"
mkdir -p ${PROJ_FOLDER}
cd ${PROJ_FOLDER}
mkdir -p resources

if [[ ! -f slides.md ]]; then
  cp ${PPT_TEMPLATE} slides.md
  subl --project "$HOME/docs/docs.sublime-project" slides.md
fi

if [[ ! -f compile.sh ]]; then
  cp ${COMPILE_TEMPLATE} ./compile.sh
  chmod +x ./compile.sh
fi
