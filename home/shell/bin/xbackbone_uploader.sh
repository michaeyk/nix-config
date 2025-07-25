#!/bin/bash

am_i_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root or with sudo";
        exit;
    fi
}

create_desktop_entry() {
cat << "EOF" > "/usr/share/applications/xbackbone-uploader-usr_admin.desktop"
[Desktop Entry]
Encoding=UTF-8
Exec=&EXEC& %U
Type=Application
Terminal=false;
Comment=Uploader script for XBackBone (admin)
Name=XBackBone Uploader (admin)
Icon=image
GenericName=File Uploader
StartupNotify=false
Categories=Graphics;
MimeType=image/bmp;image/jpeg;image/gif;image/png;image/tiff;image/x-bmp;image/x-ico;image/x-png;image/x-pcx;image/x-tga;image/xpm;image/svg+xml;
NoDisplay=false
EOF

    sed -i "s:&EXEC&:${1}:g" "/usr/share/applications/xbackbone-uploader-usr_admin.desktop"
    echo "Desktop entry created!";
}

upload() {
    RESPONSE="$(curl -s -F "token=token_d008dfa513a829e35eed41a26207037c" -F "upload=@${1}" http://michaelkim.net:9876/upload)";

    if [[ "$(echo "${RESPONSE}" | jq -r '.message')" == "OK" ]]; then
        URL="$(echo "${RESPONSE}" | jq -r '.url')";
        if [ "${DESKTOP_SESSION}" != "" ]; then
            # echo "${URL}" | xclip -selection c;
            echo "${URL}" | wl-copy;
            notify-send "Upload completed!" "${URL}";
        else
            echo "${URL}";
        fi
        exit 0;
    else
        MESSAGE="$(echo "${RESPONSE}" | jq -r '.message')";
        if [ $? -ne 0 ]; then
            echo "Unexpected response:";
            echo "${RESPONSE}";
            exit 1;
        fi
        if [ "${DESKTOP_SESSION}" != "" ]; then
            notify-send "Error!" "${MESSAGE}";
        else
            echo "Error! ${MESSAGE}";
        fi
        exit 1;
    fi
}

check() {
    ERRORS=0;

    if [ ! -x "$(command -v jq)" ]; then
        echo "jq command not found.";
        ERRORS=1;
	fi	

	if [ ! -x "$(command -v curl)" ]; then
        echo "curl command not found.";
        ERRORS=1;
	fi

	# if [ ! -x "$(command -v xclip)" ] && [ "${DESKTOP_SESSION}" != "" ]; then
 #        echo "xclip command not found.";
 #        ERRORS=1;
	# fi

	if [ ! -x "$(command -v notify-send)" ] && [ "${DESKTOP_SESSION}" != "" ]; then
        echo "notify-send command not found.";
        ERRORS=1;
	fi

	if [ "${ERRORS}" -eq 1 ]; then
	  exit 1;
	fi
}

check
if [ "${1}" == "-desktop-entry" ]; then
    am_i_root
    create_desktop_entry "$(realpath "${0}")";
    exit;
fi

if [ -f "${1}" ]; then
    upload "${1}";
else
    if [ "${DESKTOP_SESSION}" != "" ]; then
        notify-send "Error!" "File specified not exists.";
	exit 1;
    else
        echo "Error! File specified not exists.";
	exit 1;
    fi
fi
