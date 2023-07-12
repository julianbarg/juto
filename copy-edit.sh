#!/usr/bin/env bash

# Default model argument
model="gpt-4"

# Default role argument
role="coauthor"

# Default temperature argument
temperature=0

# Default input source
input_source=""

# Default input
input=""

# Help function
function display_help {
  echo "Usage: script.sh [OPTIONS]"
  echo "Options:"
  echo "  -h, --help          Display this help message"
  echo "  --3.5               Use gpt-3.5-turbo model instead of the default gpt-4"
  echo "  -t, --temperature   Set the temperature value (default: 0)"
  echo "  -p, --proofread     Set the role to 'proofread'"
  echo "  -i, --input         Specify the input directly"
  echo "  -c, --clipboard     Use the clipboard for input"
}

# Process optional flags and arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -h|--help)
      display_help
      exit 0
      ;;
    --3.5)
      model="gpt-3.5-turbo"
      ;;
    -t|--temperature)
      temperature=$2
      shift
      ;;
    -p|--proofread)
      role="proofread"
      ;;
    -i|--input)
      input_source="direct"
      shift
      input="$*"
      break
      ;;
    -c|--clipboard)
      input_source="clipboard"
      ;;
    *)
      echo "Unknown option: $1"
      display_help
      exit 1
      ;;
  esac
  shift
done

# If no input source was specified, display the help message and exit
if [ -z "$input_source" ]; then
  display_help
  exit 0
fi

# Get input from the specified source
if [ "$input_source" = "clipboard" ]; then
  input=$(wl-paste)
fi

# Run the command with the chosen model, role, temperature,
# using $input as the input, and pipe the output to wdiff and colordiff
echo "$input" \
  | sgpt --role "$role" --model "$model" \
    --temperature "$temperature" --chat temp \
  | wdiff -n <(echo "$input") - \
  | colordiff \
  && paplay /usr/share/sounds/freedesktop/stereo/complete.oga
