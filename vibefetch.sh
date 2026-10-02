#!/usr/bin/env bash
# Minimal system fetch
get_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$PRETTY_NAME"
    else
        uname -s
    fi
}
get_kernel() {
    uname -r
}
get_uptime() {
    uptime -p | sed 's/up //'
}
