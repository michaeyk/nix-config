#!/usr/bin/sh

cp /tmp/screenshot.png $HOME/Pictures/screenshots/screenshot_from_$(date +%Y-%m-%d_%H-%M-%S).png

xbackbone_uploader.sh /tmp/screenshot.png 



