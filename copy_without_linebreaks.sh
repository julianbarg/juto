#!/usr/bin/env bash

# title: copy_without_linebreaks
# authors: Glutanimate (github.com/glutanimate), Julian Barg
# license: MIT license

# Parses currently selected text

SelectedText="$(xsel)"

ModifiedText="$(echo "$SelectedText" | \
    sed -e 's/-$/||/g' -e 's/^\s*$/|/g' \
        | tr '\n' ' ' \
        | sed 's/|| //g' \
        | tr '|' '\n' \
        | sed 's/|$//')"

printf "$ModifiedText" | xsel -bi

