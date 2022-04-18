reflow_md () {
    file=$1

    tmp_front=$( mktemp )
    tmp_content_before=$( mktemp )
    tmp_content_after=$( mktemp )
    trap "rm -f $tmp_front"
    trap "rm -f $tmp_content_before"
    trap "rm -f $tmp_content_after"

    grep -z -o "\-\-\-.*\-\-\-" $file > $tmp_front
    yamlnt $file > $tmp_content_before
    fmt $tmp_content_before -w 72 > $tmp_content_after

    # Featuring stupid way to insert newline.
    cat $tmp_front <(echo) $tmp_content_after
}

yamlify () {
    file=$1
    yq -f=extract "." $file
}

yamladd () {
    file=$1
    key=$2
    value=$3
    # yq -f=process -i ". + .\"${key}\"= \"value\"" $file
    yq -f=process -i ". + {\"$key\": \"$value\"}" $file
    sed -i "1 i\---" $file
}

yamlnt () {
    file=$1
    sed "/^---$/,/^---$/d" $file
}
