today=$(date +%F)

reflow_md () {
    file=$1
    yaml="$(sed "/^---$/,/^---$/p" -n $file)"
    body="$(yamlnt $file)"
    body=$( fmt <(echo "$body") -w 72 )

    if [[ -z $yaml ]]; then
        echo "$body" > $file
    else
        echo -e "${yaml}\n${body}" > $file
    fi
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

default_header=$(printf "%s\n"\
    "---"\
    "actors: ''"\
    "added: ${today}"\
    "date: ''"\
    "factiva: ''"\
    "focus: ''"\
    "link: ''"\
    "location: ''"\
    "source: ''"\
    "title: ''"\
    "iterations: ''"\
    "---")

toumd () {
    file=$1
    touch $file
    echo "$default_header" >> $file
    subl $file
}

add_header () {
    file=$1
    (echo "$default_header" && cat $file) > tmp
    mv tmp $file
}