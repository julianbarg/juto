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
  echo "Usage: ./compile.sh [OPTION]"
  echo "Options:"
  echo "  -p, --project   Set project name."
  exit 0
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
      exit 1
      ;;
  esac
  shift
done

# Get project name
if [ -z "${PROJ:-}" ]; then
  echo "Choose name for the project."
  read -p "> " PROJ
fi
PROJ_FOLDER="${DOCS_DIR}/${YEAR}/${PROJ}"
mkdir -p ${PROJ_FOLDER}
cd ${PROJ_FOLDER}
mkdir -p resources

if [[ ! -f slides.md ]]; then
  cp ${PPT_TEMPLATE} slides.md
fi

if [[ ! -f compile.sh ]]; then
  cp ${COMPILE_TEMPLATE} ./compile.sh
  chmod +x ./compile.sh
fi
