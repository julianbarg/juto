fix_wrong_yaml () {
    FILE=$1
    LINES_DOUBLE=$(grep -E "[^:]*: \"[^\\\"]*\"[^\"]+" -n $FILE | cut -f1 -d :)
    LINES_SINGLE=$(grep -E "[^:]*: '[^\\']*'[^']+" -n $FILE | cut -f1 -d :)

    for line in $LINES_DOUBLE; do
        # echo $line
        sed "${line}s/\"//g" $FILE -i
    done

    for line in $LINES_SINGLE; do
        # echo $line
        sed "${line}s/'//g" $FILE -i
    done
}

update_bib_yaml () {
    YAML_LOC=$HOME/bibliography
    pandoc "${YAML_LOC}.bib" -s -f biblatex -t markdown > "${YAML_LOC}.yaml" \
    && fix_wrong_yaml ${YAML_LOC}.yaml \
    && yq '.references' "${YAML_LOC}.yaml" -i
}

add_lit () {
    POSITIONAL_ARGS=()
    local INPLACE=no
    local VERBOSE=no
    while [[ $# -gt 0 ]]; do        
        case $1 in
            -i)
            local INPLACE=yes
            shift
            ;;    
        -v|--verbose)
            local VERBOSE=yes
            shift
            ;;
        -*|--*)
            echo "Unknown option $1"
            exit 1
            ;;
        *)
            local POSITIONAL_ARGS+=("$1")
            shift
            ;;
        esac
    done
    set -- "${POSITIONAL_ARGS[@]}"

    if [[ VERBOSE = "yes" ]]; then
        echo "Parsing arguments"
    fi
    SOURCE=$HOME/bibliography.yaml
    VARS="\"doi\", \"title-short\", \"container-title-short\", \"author\""

    YAML="$( yq '.[] 
        |= (select(has("title-short") | not) 
        | .title-short = .title)' $SOURCE -f=extract )"

    # YAML="$( yq '.[] 
    #     |= (select(has("title-short") | not) 
    #     | .title-short = .title 
    #     | .title-short style="double" 
    #     | .title-short |= sub("\n", ""))' $SOURCE -f=extract )"

    # YAML="$( yq '.[] 
    #     |= (select(has("title-short") | not) 
    #     | .title-short = .title 
    #     | .title-short style="double" 
    #     | .title-short |= sub("\n", "")
    #     | .[].title-short |= sub("(.{100})(.*)", "${1}")' $SOURCE -f=extract )"

    add_lit_one () {
        local FILE=$1
        local INPLACE=$2
        local VERBOSE=$3
        local tmpfile=$(mktemp $HOME/tmp/XXXXXXXXX.tmpfile)
        local doi=$(yq '.doi' $FILE -f=extract)
        if [[ $INPLACE = 'yes' ]]; then
            local INPLACE_ARG='-i'
        fi
        if [[ $VERBOSE = 'yes' ]]; then
            echo "In place: $INPLACE"
            echo "In place tag: $INPLACE_ARG"
        fi
        
        yq ".[] \
            | select(.doi == \"$doi\") \
            | pick([$VARS]) \
            | .journal_short = .container-title-short \
            | del(.container-title, .container-title-short)" <(echo "$YAML") \
            > $tmpfile
        yq ". *= load(\"$tmpfile\")" $FILE $INPLACE_ARG -f=process
        if [[ $VERBOSE = 'yes' ]]; then
            echo $FILE
            echo "Doi: $doi"
        fi
        rm $tmpfile
    }

    update_bib_yaml

    yamllint ${POSITIONAL_ARGS[@]}

    input "Continue?"

    for i in ${POSITIONAL_ARGS[@]}; do
        if [[ $VERBOSE = 'yes' ]]; then
            echo "This one is $i"
        fi
        # add_lit_one $i
        add_lit_one $i $INPLACE $VERBOSE &
    done

    wait

}

get_files () {
    local files
    for doi in $@; do
        file=$(grep "$doi" lit -r -l)
        files+="$(grep "$doi" lit -r -l) "
        if [ -z $file ]; then
            echo "File for DOI $doi missing."
        fi
    done
    echo $files
}

find_pdf () {
    ENTRY="$1"
    FOLDER="$HOME/Zotero/storage/"
    AUTHOR=$( yq '.author[0].family' $ENTRY )
    YEAR=$( yq '.year' "$ENTRY" )
    TITLE=$( yq '.title' "$ENTRY" | sed "s/[[:punct:]].*//")
    TITLE=$( echo ${TITLE:0:20} )

    # echo "Author: $AUTHOR"
    # echo "Year: $YEAR"
    # echo "Title: $TITLE"
    
    HIT=$( find "$FOLDER" -mindepth 2 -maxdepth 2 -path "*${AUTHOR}*${YEAR}*${TITLE}*" )

    echo "$HIT"
}

# get_values () {
#     POSITIONAL_ARGS=()
#     while [[ $# -gt 0 ]]; do        
#         case $1 in
#             -f|--file)
#             FILE="$2"
#             shift
#             shift
#             ;;    
#         -v|--verbose)
#             VERBOSE=yes
#             shift
#             ;;
#         -*|--*)
#             echo "Unknown option $1"
#             exit 1
#             ;;
#         *)
#             POSITIONAL_ARGS+=("$1")
#             shift
#             ;;
#         esac
#     done
#     set -- "${POSITIONAL_ARGS[@]}"

#     input

#     str=""
#     for value in "$@"; do
#         str+="\"$value\","
#     done
#     str=${str::-1}

#     if [ VERBOSE == "yes" ]; then
#         echo "File: $FILE"
#         echo "String: $str"
#     fi

#     yq "[.[] | pick([$str])]" $FILE
# }
