#!/usr/bin/env bash
get_os() {
    if [ -d /bedrock ]; then echo "Bedrock Linux"
    elif [ -f /etc/os-release ]; then . /etc/os-release; echo "$PRETTY_NAME"
    else uname -s; fi
}
get_kernel() { uname -r; }
get_uptime() { uptime -p | sed 's/up //'; }
get_memory() { free -m 2>/dev/null | awk '/^Mem:/ {print $3 "MB / " $2 "MB"}' || echo "N/A"; }

load_color() {
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

preset_classic() {
    echo -e "${c_logo}${c_bold}  VIBEFETCH ${c_reset}"
    echo -e "${c_prim}  OS     |${c_reset} ${c_sec}$(get_os)${c_reset}"
    [ "$SHOW_KERNEL" = true ] && echo -e "${c_prim}  Kernel |${c_reset} ${c_sec}$(get_kernel)${c_reset}"
    [ "$SHOW_UPTIME" = true ] && echo -e "${c_prim}  Uptime |${c_reset} ${c_sec}$(get_uptime)${c_reset}"
    [ "$SHOW_MEMORY" = true ] && echo -e "${c_prim}  Memory |${c_reset} ${c_sec}$(get_memory)${c_reset}"
    echo ""
}

preset_inline() {
    local out=""
    out+="${c_logo}${c_bold}VIBE${c_reset} "
    out+="${c_prim}OS:${c_reset} ${c_sec}$(get_os)${c_reset} "
    [ "$SHOW_KERNEL" = true ] && out+="${c_prim}KERN:${c_reset} ${c_sec}$(get_kernel)${c_reset} "
    [ "$SHOW_UPTIME" = true ] && out+="${c_prim}UP:${c_reset} ${c_sec}$(get_uptime)${c_reset} "
    [ "$SHOW_MEMORY" = true ] && out+="${c_prim}MEM:${c_reset} ${c_sec}$(get_memory)${c_reset} "
    echo -e "\n  $out\n"
}

preset_minimal() {
    echo -e "\n  ${c_sec}$(get_os)${c_reset}  ${c_prim}$(get_kernel)${c_reset}  ${c_logo}$(get_uptime)${c_reset}\n"
}

preset_block() {
    echo -e "\n${c_logo}${c_bold}  ██  ${c_sec}$(get_os)${c_reset}"
    [ "$SHOW_KERNEL" = true ] && echo -e "${c_logo}${c_bold}  ██  ${c_prim}$(get_kernel)${c_reset}"
    [ "$SHOW_UPTIME" = true ] && echo -e "${c_logo}${c_bold}  ██  ${c_prim}$(get_uptime)${c_reset}"
    [ "$SHOW_MEMORY" = true ] && echo -e "${c_logo}${c_bold}  ██  ${c_sec}$(get_memory)${c_reset}"
    echo ""
}

load_config() {
    CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/vibefetch"
    CONFIG_FILE="$CONFIG_DIR/config"
    COLOR="ocean"
    PRESET="classic"
    SHOW_KERNEL=true
    SHOW_UPTIME=true
    SHOW_MEMORY=true
    if [ -f "$CONFIG_FILE" ]; then source "$CONFIG_FILE"; fi
}

print_info() {
    load_color "$COLOR"
    case "$PRESET" in
        inline) preset_inline ;;
        minimal) preset_minimal ;;
        block) preset_block ;;
        classic|*) preset_classic ;;
    esac
}

load_config
print_info
