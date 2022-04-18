reflow_md () {
    file=$1

    tmp_front=$( mktemp )
    tmp_content_before=$( mktemp )
    tmp_content_after=$( mktemp )
    trap "rm -f $tmp_front" EXIT
    trap "rm -f $tmp_content_before" EXIT
    trap "rm -f $tmp_content_after" EXIT

    sed "/^---$/,/^---$/p" -n $file > $tmp_front
    yamlnt $file > $tmp_content_before
    fmt $tmp_content_before -w 72 > $tmp_content_after

    if [[ $(cat -v $tmp_front) == "" ]]; then
        cat $tmp_content_after > $file
    else
        cat $tmp_front $tmp_content_after
    fi

    rm $tmp_front
    rm $tmp_content_before
    rm $tmp_content_after
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
