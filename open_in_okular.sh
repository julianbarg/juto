#!/usr/bin/env bash

# Go to okular to ensure that pdf is opened in existing window.
# Note: -R also works but turns off any flags like
# "Always on Visible Workspace"

if [[ $( wmctrl -l | grep "okular" ) ]]; then
	wmctrl -a "okular"
	# wmctrl -R "okular"
	sleep 0.3
fi

okular "$1"
