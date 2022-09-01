#!/usr/bin/env bash

ARTICLES=$1
DESTINATION=$2

while IFS=, read -r doi id; do
    echo "$doi" | xclip -sel clip
    firefox "doi.org/$doi" &
    while read -p "Did you find $doi? Yes/no`echo $'\n> '`" key <&1; do
        if [[ $key = y ]]; then
            TARGET="$DESTINATION/${id}.pdf"
            mv "$(latest $dl)" "$TARGET"
            echo "Saved to $TARGET"
            open $TARGET &
            break
        elif [[ $key = n ]]; then
            break
        fi
    done
done < $ARTICLES
