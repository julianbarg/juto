source "$(dirname "${BASH_SOURCE[0]}")/latest.sh"

check () {
  xdg-open "$(latest $HOME/out)"
}
