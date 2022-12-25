#!/usr/bin/env bash

# Copy function for my coded data

# Parses currently selected text

xsel --clipboard \
	| sed -e "s/[«»‹›]//g" -e "s/|.*//g" \
			-e 's/-$/||/g' -e 's/^\s*$/|/g' \
    | tr '\n' ' ' \
    | sed -e 's/|| //g' -e 's/| /\n\n/g' -e 's/|$//' \
    	-e"s/ $//g" -e's/"/\\"/g' -e 's/  / /g' \
	| xsel -bi
