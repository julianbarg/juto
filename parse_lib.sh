export NOTE="$HOME/Documents/note"

PROJ=".[].projects.[].name"
# Also works: location=".projects[].name"
find_proj() {
	while [[ $# -gt 0 ]]; do
		case $1 in
			-c|--command)
			  local COMMAND="$2"
			  shift
			  shift
			  ;;
			-d|--default)
			  local DEFAULT=YES
			  shift
			  ;;
			-k|--key)
			  local KEY="$2"
			  shift
			  ;;
			-p|--project)
			  local PROJECT="$2"
			  shift
			  shift
			  ;;
			-v|--verbal)
			  local VERBAL=YES
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

	if [[ "$VERBAL" == "YES" ]]; then
		echo "COMMAND: $COMMAND"
		echo "PROJECT: $PROJECT"
		echo "DEFAULT: $DEFAULT"
		echo "KEY: $KEY"
		echo "POSITIONAL_ARGS: ${POSITIONAL_ARGS[@]}"
	fi

	if [[ ! -z $KEY && ! -z $PROJECT ]]; then
		local SELECTION="| select($PROJ | contains(\"$PROJECT\" \
		or .[].key==\"$KEY\")"
	elif [[ ! -z $PROJECT ]]; then
		local SELECTION="| select($PROJ | contains(\"$PROJECT\"))"
	elif [[ ! -z $KEY ]]; then
		local SELECTION="| select(.[].key==\"$KEY\")"
	fi

	if [[ "$DEFAULT" == "YES" ]]; then
		local VARS="| .[] |= with_entries(select(.key == \"key\" or .key == \"title\" or .key ==\"summary\"))"
	fi

	for i in "${POSITIONAL_ARGS[@]}"; do
		local USER_VARS+=" or .key == \"$i\""
	done
	if [[ ! -z $USER_VARS ]]; then
		local USER_VARS="| .[] |= with_entries(select(.key == \"key\" ${USER_VARS}))"
	fi

	if [[ "$VERBAL" == "YES" ]]; then
		echo "SELECTION: $SELECTION"
		echo "VARS: $VARS"
		echo "USER_VARS: $USER_VARS"
	fi

	# Debug
	# echo "$COMMAND_"
	find lit -name "*.md" -exec yq -f=extract "[.] $SELECTION $VARS $USER_VARS $COMMAND" {} \;
}
