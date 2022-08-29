#!/usr/bin/env bash

# Download all articles listed in the csv file from scihub
# and uses the second row as a filename.
# Using: https://github.com/zaytoun/scihub.py

ARTICLES=$1
DESTINATION=$2

TMP_FOLDER="${DESTINATION}/../dl_scihub_tmp"
# Write all processed dois to log in case bash scihub crashes.
LOG="${DESTINATION}/../dl_scihub.log"

mkdir $TMP_FOLDER
# Write downloaded 
touch $LOG

while IFS=, read -r doi id; do
    scihub -s "$doi" -O $TMP_FOLDER -u https://sci-hub.ee/ \
    && echo "$doi" >> $LOG \
    && FILE=$(ls $TMP_FOLDER) \
    && mv $TMP_FOLDER/$FILE "${DESTINATION}/${id}.pdf"
done < $ARTICLES
