#!/bin/bash

SELECTION="$(printf "1 - Lock\n2 - Suspend\n3 - Log out\n4 - Reboot\n5 - Reboot to UEFI\n6 - Hard reboot\n7 - Shutdown" | fuzzel --dmenu -l 7 -p "Power Menu: ")"

case $SELECTION in
	*"Lock")
		hyprlock;;
	*"Suspend")
		systemctl suspend;;
	*"Log out")
		cliphist wipe; hyprctl dispatch exit;;
	*"Reboot")
		cliphist wipe; systemctl reboot;;
	*"Reboot to UEFI")
		cliphist wipe; systemctl reboot --firmware-setup;;
	*"Hard reboot")
		cliphist wipe; pkexec "echo b > /proc/sysrq-trigger";;
	*"Shutdown")
		cliphist wipe; systemctl poweroff;;
esac
