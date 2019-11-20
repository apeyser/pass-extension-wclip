#!/bin/bash

wclip.pshell() {
    local cmd='$OutputEncoding = New-Object -typename System.Text.UTF8Encoding ; [Console]::OutputEncoding = New-Object -typename System.Text.UTF8Encoding ; '"$1"
    powershell.exe -command "$cmd"
}

wclip.get() {
    wclip.pshell 'get-clipboard | write-output'
}

wclip.set() {
    wclip.pshell '$input | set-clipboard'
}

clip() {
    local sleep_argv0="pass-wclip-sleep-arbitrary-name"
    pkill -f "^$sleep_argv0" 2>/dev/null && sleep 0.5

    local before=$(wclip.get | base64)
    local pass=$(echo -n "$1" | base64)
    echo -n "$1" | wclip.set
    (
	( exec -a "$sleep_argv0" sleep "$CLIP_TIME" )
	local now=$(wclip.get | tr -d "\r\n" | base64)
	if [[ "$now" = "$pass" ]]; then
	    echo -n "$before" | base64 -d | wclip.set
	fi
    ) & disown

    echo "Copied $2 to clipboard using powershell. Will clear in $CLIP_TIME seconds."
}

cmd_show --clip "$@"
