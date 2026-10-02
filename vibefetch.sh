#!/usr/bin/env bash
get_os() {
    if [ -d /bedrock ]; then echo "Bedrock Linux"
    elif [ -f /etc/os-release ]; then . /etc/os-release; echo "$PRETTY_NAME"
    else uname -s; fi
}
get_kernel() { uname -r; }
get_uptime() { uptime -p | sed 's/up //'; }
get_memory() { free -m 2>/dev/null | awk '/^Mem:/ {print $3 "MB / " $2 "MB"}' || echo "N/A"; }

load_theme() {
    case "$1" in
        dracula) c_prim="\e[35m"; c_sec="\e[36m"; c_logo="\e[35m" ;;
        cyberpunk) c_prim="\e[33m"; c_sec="\e[36m"; c_logo="\e[36m" ;;
        forest) c_prim="\e[32m"; c_sec="\e[33m"; c_logo="\e[32m" ;;
        vaporwave) c_prim="\e[36m"; c_sec="\e[35m"; c_logo="\e[35m" ;;
        ocean|*) c_prim="\e[34m"; c_sec="\e[36m"; c_logo="\e[34m" ;;
    esac
    c_reset="\e[0m"
    c_bold="\e[1m"
}

load_config() {
    CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/vibefetch"
    CONFIG_FILE="$CONFIG_DIR/config"
    THEME="ocean"
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    else
        mkdir -p "$CONFIG_DIR"
        echo '# Vibefetch Config' > "$CONFIG_FILE"
        echo '# Valid Themes: ocean, dracula, cyberpunk, forest, vaporwave' >> "$CONFIG_FILE"
        echo 'THEME="ocean"' >> "$CONFIG_FILE"
    fi
}

load_config
load_theme "$THEME"

echo -e "${c_logo}${c_bold}  VIBEFETCH ${c_reset}"
echo -e "${c_prim}  OS     |${c_reset} ${c_sec}$(get_os)${c_reset}"
echo -e "${c_prim}  Kernel |${c_reset} ${c_sec}$(get_kernel)${c_reset}"
echo -e "${c_prim}  Uptime |${c_reset} ${c_sec}$(get_uptime)${c_reset}"
echo -e "${c_prim}  Memory |${c_reset} ${c_sec}$(get_memory)${c_reset}"
echo ""
