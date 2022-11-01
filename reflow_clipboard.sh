reflow () {
    FILE=$1

    if [[ $(head -n 1 "$FILE") = "---" ]]; then
        YAML_END=$(grep -m 2 -n -E "^---\s?$" "$FILE" \
        | cut -f1 -d: \
        | tail -n 1)
        HEAD=$(head -n $YAML_END "$FILE")
        body=$(sed "1,${YAML_END}d" "$FILE")
    else
        HEAD=""
        body=$(cat "$FILE")
    fi

    body=$( fmt <(echo -n "$body") -w 72 | sed "s/  / /g")

    echo -n "$HEAD
$body" > "$HOME/tmp/reflow.md"

    cp "$HOME/tmp/reflow.md" "$FILE"
}

xsel -b > $HOME/tmp/clipboard.txt
reflow "$HOME/tmp/clipboard.txt"
cat "$HOME/tmp/clipboard.txt" | xclip -sel clip
