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
        inir)
            # iNiR dynamically overrides terminal palettes. 
            # We map directly to ANSI base slots which iNiR controls.
            c_prim="\e[31m" # INiR Color 1 (Primary Wallpaper Accent)
            c_sec="\e[34m"  # INiR Color 4 (Secondary Wallpaper Accent)
            c_logo="\e[35m" # INiR Color 5 (Tertiary)
            ;;
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

preset_boxes() {
    echo -e "\n${c_logo} ╭─── ${c_bold}VIBEFETCH${c_reset}"
    echo -e "${c_logo} │ ${c_prim}OS:${c_reset} ${c_sec}$(get_os)${c_reset}"
    [ "$SHOW_KERNEL" = true ] && echo -e "${c_logo} │ ${c_prim}Kernel:${c_reset} ${c_sec}$(get_kernel)${c_reset}"
    [ "$SHOW_UPTIME" = true ] && echo -e "${c_logo} │ ${c_prim}Uptime:${c_reset} ${c_sec}$(get_uptime)${c_reset}"
    [ "$SHOW_MEMORY" = true ] && echo -e "${c_logo} │ ${c_prim}Memory:${c_reset} ${c_sec}$(get_memory)${c_reset}"
    echo -e "${c_logo} ╰───────────────── ${c_reset}\n"
}

preset_dots() {
    echo -e "\n  ${c_logo}•${c_prim} $(get_os)${c_reset}"
    [ "$SHOW_KERNEL" = true ] && echo -e "  ${c_logo}•${c_prim} $(get_kernel)${c_reset}"
    [ "$SHOW_UPTIME" = true ] && echo -e "  ${c_logo}•${c_prim} $(get_uptime)${c_reset}"
    [ "$SHOW_MEMORY" = true ] && echo -e "  ${c_logo}•${c_prim} $(get_memory)${c_reset}"
    echo ""
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
    
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    else
        mkdir -p "$CONFIG_DIR"
        echo 'COLOR="ocean"' > "$CONFIG_FILE"
        echo 'PRESET="classic"' >> "$CONFIG_FILE"
        echo 'SHOW_KERNEL=true' >> "$CONFIG_FILE"
        echo 'SHOW_UPTIME=true' >> "$CONFIG_FILE"
        echo 'SHOW_MEMORY=true' >> "$CONFIG_FILE"
    fi
}

save_config() {
    if [ -d "$CONFIG_DIR" ]; then
        echo 'COLOR="'"$COLOR"'"' > "$CONFIG_FILE"
        echo 'PRESET="'"$PRESET"'"' >> "$CONFIG_FILE"
        echo 'SHOW_KERNEL='"$SHOW_KERNEL" >> "$CONFIG_FILE"
        echo 'SHOW_UPTIME='"$SHOW_UPTIME" >> "$CONFIG_FILE"
        echo 'SHOW_MEMORY='"$SHOW_MEMORY" >> "$CONFIG_FILE"
    fi
}

manage_startup() {
    local action="$1"
    local shell_name=$(basename "${SHELL:-bash}")
    local rc_file="$HOME/.bashrc"
    
    case "$shell_name" in
        zsh) rc_file="$HOME/.zshrc" ;;
        fish) rc_file="$HOME/.config/fish/config.fish" ;;
    esac
    
    local hook_start="# --- VIBEFETCH START ---"
    local hook_end="# --- VIBEFETCH END ---"
    
    if [ "$action" = "enable" ]; then
        if [ ! -f "$rc_file" ]; then touch "$rc_file"; fi
        if ! grep -q "$hook_start" "$rc_file" 2>/dev/null; then
            echo -e "\n$hook_start\nvibefetch\n$hook_end" >> "$rc_file"
            echo "✨ Vibefetch auto-start enabled in $rc_file"
        else
            echo "✅ Vibefetch is already enabled in $rc_file"
        fi
    elif [ "$action" = "disable" ]; then
        if grep -q "$hook_start" "$rc_file" 2>/dev/null; then
            sed -i.bak "/$hook_start/,/$hook_end/d" "$rc_file"
            rm -f "${rc_file}.bak"
            echo "🗑️ Vibefetch auto-start disabled from $rc_file"
        else
            echo "ℹ️ Vibefetch is not currently enabled in $rc_file"
        fi
    fi
    exit 0
}

print_info() {
    load_color "$COLOR"
    case "$PRESET" in
        boxes) preset_boxes ;;
        dots) preset_dots ;;
        block) preset_block ;;
        classic|*) preset_classic ;;
    esac
}

preview() {
    for p in classic block boxes dots; do
        PRESET="$p"
        echo -e "--- Previewing PRESET: \e[1m$p\e[0m (Color: $COLOR) ---"
        print_info
    done
    exit 0
}

load_config
CONFIG_CHANGED=false

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --enable-startup) manage_startup "enable" ;;
        --disable-startup) manage_startup "disable" ;;
        -c|--color) COLOR="$2"; CONFIG_CHANGED=true; shift ;;
        -p|--preset) PRESET="$2"; CONFIG_CHANGED=true; shift ;;
        --preview) preview ;;
        -h|--help) 
            echo "Usage: vibefetch [OPTIONS]"
            echo "  -c, --color <name>    Colors: inir (auto-wallpaper), ocean, dracula, cyberpunk, forest, vaporwave"
            echo "  -p, --preset <name>   Presets: classic, block, boxes, dots"
            echo "  --preview             Show all layouts for current color"
            echo "  --enable-startup      Add to bash/zsh/fish startup automatically"
            echo "  --disable-startup     Remove from bash/zsh/fish startup automatically"
            exit 0 ;;
    esac
    shift
done

[ "$CONFIG_CHANGED" = true ] && save_config

print_info
