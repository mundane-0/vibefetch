#!/usr/bin/env bash

# --- FAST SYSTEM DETECTORS ---
get_os() {
    if [ -d /bedrock ]; then echo "Bedrock Linux"
    elif [ -f /etc/os-release ]; then . /etc/os-release; echo "$PRETTY_NAME" | tr -d '\r\n'
    else uname -s; fi
}
get_kernel() { uname -r | tr -d '\r\n'; }
get_uptime() { uptime -p | sed 's/up //' | tr -d '\r\n'; }
get_memory() { free -m 2>/dev/null | awk '/^Mem:/ {print $3 "MB / " $2 "MB"}' || echo "N/A"; }
get_host()   { echo "${USER:-user}@${HOSTNAME:-host}" | tr -d '\r\n'; }
get_env()    { echo "${XDG_CURRENT_DESKTOP:-tty} / $(basename "${SHELL:-sh}")" | tr -d '\r\n'; }

# --- COLOR SYSTEM ---
detect_inir_colors() {
    local color_file=""
    if [ -f "$HOME/.local/state/quickshell/user/generated/colors.json" ]; then
        color_file="$HOME/.local/state/quickshell/user/generated/colors.json"
    elif [ -n "$INIR_COLOR_PATH" ] && [ -f "$INIR_COLOR_PATH" ]; then
        color_file="$INIR_COLOR_PATH"
    elif [ -f "$HOME/.cache/wal/colors" ]; then
        color_file="$HOME/.cache/wal/colors"
    elif [ -f "$HOME/.config/wpg/sequences" ]; then
        color_file="$HOME/.config/wpg/sequences"
    fi

    if [ -n "$color_file" ] && [ -f "$color_file" ]; then
        if [[ "$color_file" == *".json" ]]; then
            if ! command -v jq >/dev/null 2>&1; then return 1; fi
            local c_p=$(jq -r '.primary // empty' "$color_file" | tr -d '\r\n#')
            local c_s=$(jq -r '.secondary // empty' "$color_file" | tr -d '\r\n#')
            local c_l=$(jq -r '.tertiary // empty' "$color_file" | tr -d '\r\n#')
            if [ -n "$c_p" ]; then
                c_prim="\e[38;2;$((16#${c_p:0:2}));$((16#${c_p:2:2}));$((16#${c_p:4:2}))m"
                c_sec="\e[38;2;$((16#${c_s:0:2}));$((16#${c_s:2:2}));$((16#${c_s:4:2}))m"
                c_logo="\e[38;2;$((16#${c_l:0:2}));$((16#${c_l:2:2}));$((16#${c_l:4:2}))m"
                return 0
            fi
        else
            local colors=($(head -6 "$color_file" | tr -d '\r\n#'))
            if [ ${#colors[@]} -ge 3 ]; then
                c_prim="\e[38;2;$((16#${colors[0]:0:2}));$((16#${colors[0]:2:2}));$((16#${colors[0]:4:2}))m"
                c_sec="\e[38;2;$((16#${colors[1]:0:2}));$((16#${colors[1]:2:2}));$((16#${colors[1]:4:2}))m"
                c_logo="\e[38;2;$((16#${colors[2]:0:2}));$((16#${colors[2]:2:2}));$((16#${colors[2]:4:2}))m"
                return 0
            fi
        fi
    fi
    return 1
}

load_color() {
    case "$1" in
        inir) detect_inir_colors || { c_prim="\e[31m"; c_sec="\e[34m"; c_logo="\e[35m"; } ;;
        dracula) c_prim="\e[35m"; c_sec="\e[36m"; c_logo="\e[35m" ;;
        cyberpunk) c_prim="\e[33m"; c_sec="\e[36m"; c_logo="\e[36m" ;;
        forest) c_prim="\e[32m"; c_sec="\e[33m"; c_logo="\e[32m" ;;
        vaporwave) c_prim="\e[36m"; c_sec="\e[35m"; c_logo="\e[35m" ;;
        ocean|*) c_prim="\e[34m"; c_sec="\e[36m"; c_logo="\e[34m" ;;
    esac
    c_reset="\e[0m"; c_bold="\e[1m"
}

# --- LAYOUTS CORE BUILDER ---
sp() {
    if [ "$SIZE" = "compact" ]; then
        printf "%b\n" "$1"
    else
        printf "\n%b\n\n" "$1"
    fi
}

preset_classic() {
    local out="${c_logo}${c_bold}  VIBEFETCH ${c_reset}\n"
    if [ "$SIZE" = "large" ]; then out="${out}\n"; fi
    out="${out}${c_prim}  OS     |${c_reset} ${c_sec}$(get_os)${c_reset}\n"
    if [ "$SHOW_KERNEL" = "true" ]; then
        if [ "$SIZE" = "large" ]; then out="${out}\n"; fi
        out="${out}${c_prim}  Kernel |${c_reset} ${c_sec}$(get_kernel)${c_reset}\n"
    fi
    if [ "$SHOW_UPTIME" = "true" ]; then
        if [ "$SIZE" = "large" ]; then out="${out}\n"; fi
        out="${out}${c_prim}  Uptime |${c_reset} ${c_sec}$(get_uptime)${c_reset}\n"
    fi
    if [ "$SHOW_MEMORY" = "true" ]; then
        if [ "$SIZE" = "large" ]; then out="${out}\n"; fi
        out="${out}${c_prim}  Memory |${c_reset} ${c_sec}$(get_memory)${c_reset}"
    fi
    sp "$out"
}

preset_boxes() {
    local out="${c_logo} ╭─── ${c_bold}VIBEFETCH${c_reset}\n"
    if [ "$SIZE" = "large" ]; then out="${out}${c_logo} │ ${c_reset}\n"; fi
    out="${out}${c_logo} │ ${c_prim}OS:${c_reset} ${c_sec}$(get_os)${c_reset}\n"
    if [ "$SHOW_KERNEL" = "true" ]; then
        if [ "$SIZE" = "large" ]; then out="${out}${c_logo} │ ${c_reset}\n"; fi
        out="${out}${c_logo} │ ${c_prim}Kernel:${c_reset} ${c_sec}$(get_kernel)${c_reset}\n"
    fi
    if [ "$SHOW_UPTIME" = "true" ]; then
        if [ "$SIZE" = "large" ]; then out="${out}${c_logo} │ ${c_reset}\n"; fi
        out="${out}${c_logo} │ ${c_prim}Uptime:${c_reset} ${c_sec}$(get_uptime)${c_reset}\n"
    fi
    if [ "$SHOW_MEMORY" = "true" ]; then
        if [ "$SIZE" = "large" ]; then out="${out}${c_logo} │ ${c_reset}\n"; fi
        out="${out}${c_logo} │ ${c_prim}Memory:${c_reset} ${c_sec}$(get_memory)${c_reset}\n"
    fi
    if [ "$SIZE" = "large" ]; then out="${out}${c_logo} │ ${c_reset}\n"; fi
    out="${out}${c_logo} ╰───────────────── ${c_reset}"
    sp "$out"
}

preset_dots() {
    local out="  ${c_logo}•${c_prim} $(get_os)${c_reset}\n"
    if [ "$SHOW_KERNEL" = "true" ]; then
        if [ "$SIZE" = "large" ]; then out="${out}\n"; fi
        out="${out}  ${c_logo}•${c_prim} $(get_kernel)${c_reset}\n"
    fi
    if [ "$SHOW_UPTIME" = "true" ]; then
        if [ "$SIZE" = "large" ]; then out="${out}\n"; fi
        out="${out}  ${c_logo}•${c_prim} $(get_uptime)${c_reset}\n"
    fi
    if [ "$SHOW_MEMORY" = "true" ]; then
        if [ "$SIZE" = "large" ]; then out="${out}\n"; fi
        out="${out}  ${c_logo}•${c_prim} $(get_memory)${c_reset}"
    fi
    sp "$out"
}

preset_block() {
    local out="${c_logo}${c_bold}  ██  ${c_sec}$(get_os)${c_reset}\n"
    if [ "$SHOW_KERNEL" = "true" ]; then
        if [ "$SIZE" = "large" ]; then out="${out}\n"; fi
        out="${out}${c_logo}${c_bold}  ██  ${c_prim}$(get_kernel)${c_reset}\n"
    fi
    if [ "$SHOW_UPTIME" = "true" ]; then
        if [ "$SIZE" = "large" ]; then out="${out}\n"; fi
        out="${out}${c_logo}${c_bold}  ██  ${c_prim}$(get_uptime)${c_reset}\n"
    fi
    if [ "$SHOW_MEMORY" = "true" ]; then
        if [ "$SIZE" = "large" ]; then out="${out}\n"; fi
        out="${out}${c_logo}${c_bold}  ██  ${c_sec}$(get_memory)${c_reset}"
    fi
    sp "$out"
}

preset_full() {
    local out="${c_logo}${c_bold}  $(get_host) ${c_reset}\n  ${c_prim}─${c_sec}─${c_logo}─${c_prim}─${c_sec}─${c_logo}─${c_prim}─${c_sec}─${c_logo}─${c_prim}─${c_sec}─${c_logo}─${c_prim}─${c_sec}─${c_logo}─${c_reset}\n"
    if [ "$SIZE" = "large" ]; then out="${out}\n"; fi
    out="${out}${c_prim}  OS   ${c_reset} $(get_os)\n"
    if [ "$SIZE" = "large" ]; then out="${out}\n"; fi
    out="${out}${c_prim}  ENV  ${c_reset} $(get_env)\n"
    
    if [ "$SHOW_KERNEL" = "true" ]; then
        if [ "$SIZE" = "large" ]; then out="${out}\n"; fi
        out="${out}${c_prim}  SYS  ${c_reset} $(get_kernel)\n"
    fi
    if [ "$SHOW_UPTIME" = "true" ]; then
        if [ "$SIZE" = "large" ]; then out="${out}\n"; fi
        out="${out}${c_prim}  UP   ${c_reset} $(get_uptime)\n"
    fi
    if [ "$SHOW_MEMORY" = "true" ]; then
        if [ "$SIZE" = "large" ]; then out="${out}\n"; fi
        out="${out}${c_prim}  RAM  ${c_reset} $(get_memory)"
    fi
    sp "$out"
}

preset_nano() {
    local out="${c_logo}${c_bold}>> ${c_sec}$(get_os)${c_reset} ${c_prim}[$(get_uptime)]${c_reset}"
    sp "$out"
}

# --- CONFIG & STARTUP ---
load_config() {
    CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/vibefetch"
    CONFIG_FILE="$CONFIG_DIR/config"
    COLOR="ocean"
    PRESET="classic"
    SIZE="normal"
    SHOW_KERNEL="true"
    SHOW_UPTIME="true"
    SHOW_MEMORY="true"
    INIR_COLOR_PATH=""

    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    else
        mkdir -p "$CONFIG_DIR"
        echo 'COLOR="ocean"' > "$CONFIG_FILE"
        echo 'PRESET="classic"' >> "$CONFIG_FILE"
        echo 'SIZE="normal"' >> "$CONFIG_FILE"
        echo 'SHOW_KERNEL="true"' >> "$CONFIG_FILE"
        echo 'SHOW_UPTIME="true"' >> "$CONFIG_FILE"
        echo 'SHOW_MEMORY="true"' >> "$CONFIG_FILE"
        echo 'INIR_COLOR_PATH=""' >> "$CONFIG_FILE"
    fi
}

save_config() {
    mkdir -p "$CONFIG_DIR"
    echo 'COLOR="'"$COLOR"'"' > "$CONFIG_FILE"
    echo 'PRESET="'"$PRESET"'"' >> "$CONFIG_FILE"
    echo 'SIZE="'"$SIZE"'"' >> "$CONFIG_FILE"
    echo 'SHOW_KERNEL="'"$SHOW_KERNEL"'"' >> "$CONFIG_FILE"
    echo 'SHOW_UPTIME="'"$SHOW_UPTIME"'"' >> "$CONFIG_FILE"
    echo 'SHOW_MEMORY="'"$SHOW_MEMORY"'"' >> "$CONFIG_FILE"
    echo 'INIR_COLOR_PATH="'"$INIR_COLOR_PATH"'"' >> "$CONFIG_FILE"
}

detect_shell() {
    local pid=$$; for _ in 1 2 3; do
        pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
        [ -z "$pid" ] || [ "$pid" = "1" ] && break
        local comm=$(ps -o comm= -p "$pid" 2>/dev/null)
        case "$comm" in fish|zsh|bash) echo "$comm"; return ;; esac
    done
    basename "${SHELL:-bash}"
}

manage_startup() {
    local action="$1"; local shell_name=$(detect_shell)
    local rc_file="$HOME/.bashrc"
    case "$shell_name" in
        fish) rc_file="$HOME/.config/fish/config.fish"; mkdir -p "$(dirname "$rc_file")" ;;
        zsh)  rc_file="$HOME/.zshrc" ;;
        bash|*) [ -f "$HOME/.bash_profile" ] && [ ! -f "$HOME/.bashrc" ] && rc_file="$HOME/.bash_profile" ;;
    esac

    local h_start="# --- VIBEFETCH START ---"; local h_end="# --- VIBEFETCH START END ---"
    
    if [ "$action" = "enable" ]; then
        if grep -q "$h_start" "$rc_file" 2>/dev/null; then echo "✅ Already enabled in $rc_file"
        else
            printf '\n%s\nvibefetch 2>/dev/null || true\n%s\n' "$h_start" "$h_end" >> "$rc_file"
            echo "✨ Auto-start enabled in $rc_file"
        fi
    elif [ "$action" = "disable" ]; then
        if command -v perl >/dev/null 2>&1; then perl -i -0pe "s/\n*\Q$h_start\E.*?\Q$h_end\E\n*//s" "$rc_file"
        else sed -i.bak "/$h_start/,/$h_end/d" "$rc_file" && rm -f "${rc_file}.bak"; fi
        echo "🗑️  Auto-start disabled from $rc_file"
    fi
    exit 0
}

show_help() {
    load_color "$COLOR" # Ensure colors are setup for the beautiful help menu
    
    printf "\n"
    printf "${c_logo}${c_bold}  🌊 VIBEFETCH ${c_reset} - Minimalist Linux Sysfetch\n"
    printf "\n"
    printf "${c_prim}  USAGE:${c_reset}\n"
    printf "    vibefetch [OPTIONS]\n"
    printf "\n"
    printf "${c_prim}  OPTIONS (Design):${c_reset}\n"
    printf "    ${c_sec}-c, --color <name>${c_reset}     Set aesthetic theme color\n"
    printf "                           (inir, ocean, dracula, cyberpunk, forest, vaporwave)\n"
    printf "    ${c_sec}-p, --preset <name>${c_reset}    Set visual layout architecture\n"
    printf "                           (classic, full, block, boxes, dots, nano)\n"
    printf "    ${c_sec}-s, --size <name>${c_reset}      Set padding and line spacing\n"
    printf "                           (compact, normal, large)\n"
    printf "\n"
    printf "${c_prim}  OPTIONS (Functional):${c_reset}\n"
    printf "    ${c_sec}--preview${c_reset}              Show all presets with the current color and size combo\n"
    printf "    ${c_sec}--enable-startup${c_reset}       Add to your shell initialization script to start on open\n"
    printf "    ${c_sec}--disable-startup${c_reset}      Safely remove from auto-start without breaking anything\n"
    printf "    ${c_sec}-h, help, --help${c_reset}       Show this beautiful help menu\n"
    printf "\n"
    printf "${c_logo}  Tinkered with ♥ from Bedrock Linux.${c_reset}\n\n"
}

print_info() {
    load_color "$COLOR"
    case "$PRESET" in
        boxes) preset_boxes ;;
        dots) preset_dots ;;
        block) preset_block ;;
        full) preset_full ;;
        nano) preset_nano ;;
        classic|*) preset_classic ;;
    esac
}

preview() {
    for p in classic block boxes dots full nano; do
        PRESET="$p"
        printf "--- Previewing PRESET: \033[1m%s\033[0m (Size: %s, Color: %s) ---\n" "$p" "$SIZE" "$COLOR"
        print_info
    done
    exit 0
}

load_config
CONFIG_CHANGED=false

# Handle 0-arg fast path or parse loops
if [ "$#" -eq 1 ]; then
    if [ "$1" = "help" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        show_help; exit 0
    elif [ "$1" = "--preview" ]; then
        preview; exit 0
    fi
fi

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --enable-startup)  manage_startup "enable" ;;
        --disable-startup) manage_startup "disable" ;;
        -s|--size)         SIZE="$2"; CONFIG_CHANGED=true; shift ;;
        -c|--color)        COLOR="$2"; CONFIG_CHANGED=true; shift ;;
        -p|--preset)       PRESET="$2"; CONFIG_CHANGED=true; shift ;;
        --preview)         preview ;;
        help|-h|--help)    show_help; exit 0 ;;
        *)                 echo "Unknown option: $1"; show_help; exit 1 ;;
    esac
    shift
done

[ "$CONFIG_CHANGED" = true ] && save_config
print_info
