#!/bin/env bash

# 1. Create id
# 2. Get input and save to $tmp/$id_a
# 3. Escape double quote in input with sed
# 4. Create tmp sgpt session
# 5. Ask sgpt for copy edit and save to $tmp_$id_b
# 6. Print diff to shell with wdiff ~/tmp/a.md ~/tmp/b.md | colordiff
# 7. Accept user input for adjustments

id=$(date "+%Y-%m-%dT%H:%M:%S")
input="$HOME/tmp/${id}_in"
output="$HOME/tmp/${id}_out"

# wl-paste | sed 's/"/\\"/g' > "$input"
wl-paste > "$input"
sgpt --chat "$id" --role "gpt4" "$( cat $input )" > "$output"
printf -- "------------------\n"
wdiff -n "$input" "$output" | colordiff #| less -R

while true
do
  read -p ">>>" refine
  sgpt --chat "$id" --role "gpt4" "$refine" > "$output"
  wdiff -n "$input" "$output" | colordiff #| less -R
  echo
done
```

