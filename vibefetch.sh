#!/usr/bin/env bash
get_os() {
    if [ -d /bedrock ]; then echo "Bedrock Linux"
    elif [ -f /etc/os-release ]; then . /etc/os-release; echo "$PRETTY_NAME"
    else uname -s; fi
}
get_kernel() { uname -r; }
get_uptime() { uptime -p | sed 's/up //'; }
get_memory() { free -m 2>/dev/null | awk '/^Mem:/ {print $3 "MB / " $2 "MB"}' || echo "N/A"; }

detect_inir_colors() {
    # Try to extract colors from iNiR cache or pywal
    local color_file=""
    
    # Check for iNiR colors
    if [ -f "$HOME/.cache/inir/colors" ]; then
        color_file="$HOME/.cache/inir/colors"
    elif [ -f "$HOME/.cache/wal/colors" ]; then
        color_file="$HOME/.cache/wal/colors"
    elif [ -f "$HOME/.config/wpg/sequences" ]; then
        color_file="$HOME/.config/wpg/sequences"
    fi
    
    if [ -n "$color_file" ] && [ -f "$color_file" ]; then
        # Extract first 6 colors and convert to ANSI codes
        local colors=($(head -6 "$color_file" | tr -d '#'))
        if [ ${#colors[@]} -ge 3 ]; then
            # Convert hex to ANSI 24-bit
            c_prim="\e[38;2;$((0x${colors[0]:0:2}));$((0x${colors[0]:2:2}));$((0x${colors[0]:4:2}))m"
            c_sec="\e[38;2;$((0x${colors[1]:0:2}));$((0x${colors[1]:2:2}));$((0x${colors[1]:4:2}))m"
            c_logo="\e[38;2;$((0x${colors[2]:0:2}));$((0x${colors[2]:2:2}));$((0x${colors[2]:4:2}))m"
            return 0
        fi
    fi
    
    # Fallback to basic ANSI if no wallpaper colors found
    c_prim="\e[31m"; c_sec="\e[34m"; c_logo="\e[35m"
    return 1
}

load_color() {
    case "$1" in
        inir)
            if detect_inir_colors; then
                : # Colors already set by detect_inir_colors
            else
                c_prim="\e[31m"; c_sec="\e[34m"; c_logo="\e[35m"
            fi
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

detect_environment() {
    local shell_name=$(basename "${SHELL:-bash}")
    local terminal=""
    
    # Detect terminal emulator
    if [ -n "$KITTY_WINDOW_ID" ]; then terminal="kitty"
    elif [ -n "$ALACRITTY_WINDOW_ID" ]; then terminal="alacritty" 
    elif [ -n "$WEZTERM_EXECUTABLE" ]; then terminal="wezterm"
    elif [ -n "$KONSOLE_VERSION" ]; then terminal="konsole"
    elif [ -n "$GNOME_TERMINAL_SCREEN" ]; then terminal="gnome-terminal"
    elif [ "$TERM_PROGRAM" = "vscode" ]; then terminal="vscode"
    else terminal="$(ps -p $(ps -p $$ -o ppid=) -o comm=)"
    fi
    
    echo "Shell: $shell_name | Terminal: $terminal"
}

manage_startup() {
    local action="$1"
    local shell_name=$(basename "${SHELL:-bash}")
    local rc_file="$HOME/.bashrc"
    
    # Determine shell config file
    case "$shell_name" in
        zsh) 
            if [ -f "$HOME/.zshrc" ]; then
                rc_file="$HOME/.zshrc"
            else
                rc_file="$HOME/.zshrc"
                touch "$rc_file"
            fi
            ;;
        fish) 
            rc_file="$HOME/.config/fish/config.fish"
            mkdir -p "$(dirname "$rc_file")"
            ;;
        bash|*)
            if [ -f "$HOME/.bashrc" ]; then
                rc_file="$HOME/.bashrc"
            elif [ -f "$HOME/.bash_profile" ]; then
                rc_file="$HOME/.bash_profile"  
            else
                rc_file="$HOME/.bashrc"
                touch "$rc_file"
            fi
            ;;
    esac
    
    local hook_start="# --- VIBEFETCH AUTO-START ---"
    local hook_end="# --- VIBEFETCH AUTO-START END ---"
    
    echo "Detected environment: $(detect_environment)"
    echo "Target config file: $rc_file"
    
    if [ "$action" = "enable" ]; then
        if ! grep -q "$hook_start" "$rc_file" 2>/dev/null; then
            echo -e "\n$hook_start\nvibefetch 2>/dev/null || true\n$hook_end" >> "$rc_file"
            echo "✨ Vibefetch auto-start enabled in $rc_file"
            echo "📝 Restart your terminal or run: source $rc_file"
        else
            echo "✅ Vibefetch is already enabled in $rc_file"
        fi
    elif [ "$action" = "disable" ]; then
        if grep -q "$hook_start" "$rc_file" 2>/dev/null; then
            # Use perl for cross-platform compatibility
            if command -v perl >/dev/null 2>&1; then
                perl -i -pe "BEGIN{undef $/;} s/\n*$hook_start.*?$hook_end\n*//smg" "$rc_file"
            else
                sed -i.bak "/$hook_start/,/$hook_end/d" "$rc_file"
                rm -f "${rc_file}.bak"
            fi
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
        --detect-env) detect_environment; exit 0 ;;
        -c|--color) COLOR="$2"; CONFIG_CHANGED=true; shift ;;
        -p|--preset) PRESET="$2"; CONFIG_CHANGED=true; shift ;;
        --preview) preview ;;
        -h|--help) 
            echo "Usage: vibefetch [OPTIONS]"
            echo "  -c, --color <name>    Colors: inir (auto-wallpaper), ocean, dracula, cyberpunk, forest, vaporwave"
            echo "  -p, --preset <name>   Presets: classic, block, boxes, dots"
            echo "  --preview             Show all layouts for current color"
            echo "  --enable-startup      Add to shell startup automatically"
            echo "  --disable-startup     Remove from shell startup automatically"
            echo "  --detect-env          Show detected shell and terminal info"
            exit 0 ;;
    esac
    shift
done

[ "$CONFIG_CHANGED" = true ] && save_config

print_info
