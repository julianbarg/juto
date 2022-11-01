#!/usr/bin/env bash

set -o nounset

reflow () {
    FILE=$1

    if [[ $(head -n 1 "$FILE") = "---" ]]; then
        YAML_END=$(grep -m 2 -n -E "^---\s?$" "$FILE" \
        | cut -f1 -d: \
        | tail -n 1)
        HEAD=$(head -n $YAML_END "$FILE")
        body=$(sed "1,${YAML_END}d" "$FILE")
        body=$( fmt <(echo "$body") -w 72 | sed "s/  / /g")
        cat <(echo "$HEAD") <(echo "$body") > "$HOME/tmp/reflow.md"
    else
        body=$(cat "$FILE")
        fmt <(echo "$body") -w 72 | sed "s/  / /g" \
            > "$HOME/tmp/reflow.md"
    fi
    cp "$HOME/tmp/reflow.md" "$FILE"
}

reflow $@
