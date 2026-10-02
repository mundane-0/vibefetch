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
get_memory() {
    free -m 2>/dev/null | awk '/^Mem:/ {print $3 "MB / " $2 "MB"}' || echo "N/A"
}
# Colors
c_blue="\e[34m"
c_cyan="\e[36m"
c_reset="\e[0m"
c_bold="\e[1m"
