#!/usr/bin/env bash

# Go to okular to ensure that pdf is opened in existing window.
# Note: -R also works but turns off any flags like
# "Always on Visible Workspace"

if [[ $( wmctrl -l | grep "Okular" ) ]]; then
	wmctrl -a "Okular"
	# wmctrl -R "okular"
	sleep 0.3
fi

QT_SCALE_FACTOR=1.5 okular "$1"
