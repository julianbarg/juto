today=$(date +%F)

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
    "title: ''"\
    "added: ${today}"\
    "date: ''"\
    "factiva: ''"\
    "focus: ''"\
    "link: ''"\
    "location: ''"\
    "source: ''"\
    "type: ''"\
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
    tmp=$(mktemp)
    (echo "$default_header" && cat $file) > $tmp
    mv $tmp $file
}

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

prmd () {
    file=$1
    reflow_md $file
    add_header $file
}

latest () {
    local number
    local recursive
    POSITIONAL_ARGS=()
    for i in "$@"; do
        case $i in
            -n)
             number="$2"
             shift
             shift
             ;;
            -r)
             recursive="true"
             shift
             shift
             ;;
            *)
             POSITIONAL_ARGS+=("$1")
             shift
             ;;
        esac
    done
    set -- "${POSITIONAL_ARGS[@]}"
    folder=$1
    
    if [[ -z $number ]]; then
        number=1
    fi

    if [[ "$recursive" = true ]]; then
        find $folder -not -path '*/.*' -type f -printf '%T@ %p\n' \
            | sort -n \
            | tail -"$number" \
            | cut -f2- -d" "
    else
        ls $folder -t | head -n $number
    fi    
}

bind_pdfs () {
    POSITIONAL_ARGS=()
    for i in "$@"; do
        case $i in
            -n)
             number="$2"
             shift
             shift
             ;;
            *)
             POSITIONAL_ARGS+=("$1")
             shift
             ;;
        esac
    done
    set -- "${POSITIONAL_ARGS[@]}"
    out=$1
    
    if [[ -z $number ]]; then
        number=2
    fi

    files="$( ls $folder -t | head -n $number | tac )"
    tmp=$(mktemp)
    pdftk $files cat output $tmp
    mv $tmp $out
}

alias open="xdg-open"
