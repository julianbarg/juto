#!/usr/bin/env bash

xsel --clipboard \
  | sed -e "s/|.*//g" -e "s/[«»‹›]//g" \
  | xsel -bi
