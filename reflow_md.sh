#!/usr/bin/env bash

set -o nounset

FILE=$1

if [[ $(head -n 1 "$FILE") = "---" ]]; then
    YAML_END=$(grep -m 2 -n "^---$" "$FILE" \
    | cut -f1 -d: \
    | tail -n 1)
    HEAD=$(head -n $YAML_END "$FILE")
    body=$(sed "1,${YAML_END}d" "$FILE")
else
    HEAD=""
    body=$(cat "$FILE")
fi

body=$( fmt <(echo "$body") -w 72 )

echo "$HEAD" "$body" > $HOME/tmp/reflow.md

cp $HOME/tmp/reflow.md > "$FILE"
