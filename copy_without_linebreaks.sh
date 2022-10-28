#!/usr/bin/env bash

# title: copy_without_linebreaks
# authors: Glutanimate (github.com/glutanimate), Julian Barg
# license: MIT license

# Parses currently selected text

selected_text="$(xsel)"

modified_text="$(echo "$selected_text" | \
    sed -e 's/-$/||/g' -e 's/^\s*$/|/g' \
        | tr '\n' ' ' \
        | sed 's/|| //g' \
        | tr '|' '\n' \
        | sed 's/|$//')"

printf "$modified_text" | xsel -bi

