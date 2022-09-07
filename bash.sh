today=$(date +%F)

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
            # -r)
            #  recursive="true"
            #  shift
            #  shift
            #  ;;
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

    # if [[ "$recursive" = true ]]; then
        # Makes it so it only searches non-hidden
    find $folder -not -path '*/.*' -type f -printf '%T@ %p\n' \
        | sort -n \
        | tail -"$number" \
        | cut -f2- -d" "
    # else
    #     ls $folder -t | head -n $number
    # fi    
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

    files="$(latest -n $number)"
    echo $files
    tmp=$(mktemp)
    pdftk $files cat output $tmp
    mv $tmp $out
}

alias open="echo 'stderr suppressed!' && xdg-open 2> /dev/null"

md () {
    # ToDO: add alternative argument -f $file
    pdf=$(latest ~/Downloads)
    tmp=$(mktemp)
    pdftotext $pdf $tmp
    mv $tmp tmp.md
    add_header tmp.md
    subl tmp.md
}

perm () {
    name=$1
    mv "$HOME/out/temp.docx" "$HOME/out/$name"
}

increment () {
    POSITIONAL_ARGS=()
    for i in "$@"; do
        case $i in
            -n)
             NUMBER="$2"
             shift
             shift
             ;;
            --verbose)
             VERBOSE="true"
             shift
             ;;
            *)
             POSITIONAL_ARGS+=("$1")
             shift
             ;;
        esac
    done
    set -- "${POSITIONAL_ARGS[@]}"
    FILE=$1

    if [[ "$VERBOSE" = true ]]; then
        echo $NUMBER
        echo $FILE
    fi

    tmp=$(mktemp)
    gawk -v num="$NUMBER" '{
        n=split($0,a," ", b)
        {if (int(a[1]) >= num) {a[1]=a[1]+1}}
        line=b[0]
        for (i=1; i<=n; i++)
            line=(line a[i]  b[i])
        print line
    }' "$FILE" > $tmp
    mv $tmp "$FILE" 
}

opl () {
    open $(latest $HOME/Downloads)
}

csv_to_md () {
    local FILE=$1
    header=$(head -n 1 $FILE | sed "s/,/|/g")
    n_cols=$(echo -n $header \
        | sed 's/[^,]//g' \
        | wc -m
        )

    seperator="---"
    for i in {1 .. $n_cols}; do
        seperator+="|---"
    done

    # Don't need to remove third in triple--reduced to double anyways
    # | sed -E 's/"{3}/""/g' \
    body=$(csvtool -u \| cat $FILE \
        | sed '1d' \
        | sed 's/""/thisisadouble/g' \
        | sed 's/"//g' \
        | sed 's/thisisadouble/"/g' )

    output=$(echo -e "${header}\n${seperator}\n${body}")
    echo "$output"
}

input () {
    PROMPT=$1
    WORD=$2
    while read -p "${PROMPT}`echo $'\n> '`" key <&1; do
        if [[ -z $WORD && ! -z $key ]]; then
            break
        elif [[ $key == $WORD ]]; then
            break
        fi
    done
} 

yy () {
    xargs -I '{}' -- yq $@ {} -f=process
}

y () {
    ARG1=$1
    ARG2=$2
    shift
    shift
    yq "$ARG2" "$ARG1" -f=process $@
}
