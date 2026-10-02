#!/usr/bin/env bash
get_os() {
    if [ -d /bedrock ]; then echo "Bedrock Linux"
    elif [ -f /etc/os-release ]; then . /etc/os-release; echo "$PRETTY_NAME"
    else uname -s; fi
}
get_kernel() { uname -r; }
get_uptime() { uptime -p | sed 's/up //'; }
get_memory() { free -m 2>/dev/null | awk '/^Mem:/ {print $3 "MB / " $2 "MB"}' || echo "N/A"; }
c_blue="\e[34m"; c_cyan="\e[36m"; c_reset="\e[0m"; c_bold="\e[1m"
echo -e "${c_cyan}${c_bold}  VIBEFETCH ${c_reset}"
echo -e "${c_blue}  OS     |${c_reset} $(get_os)"
echo -e "${c_blue}  Kernel |${c_reset} $(get_kernel)"
echo -e "${c_blue}  Uptime |${c_reset} $(get_uptime)"
echo -e "${c_blue}  Memory |${c_reset} $(get_memory)"
echo ""
