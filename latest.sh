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
    files="$(find $folder -not -path '*/.*' -type f -printf '%T@ %p\n' \
        | sort -n \
        | tail -"$number" \
        | cut -f2- -d" ")"
    # else
    #     ls $folder -t | head -n $number
    # fi
    echo "$files"
}
