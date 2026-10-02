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
    local color_file=""
    if [ -f "$HOME/.cache/inir/colors" ]; then
        color_file="$HOME/.cache/inir/colors"
    elif [ -f "$HOME/.cache/wal/colors" ]; then
        color_file="$HOME/.cache/wal/colors"
    elif [ -f "$HOME/.config/wpg/sequences" ]; then
        color_file="$HOME/.config/wpg/sequences"
    fi

    if [ -n "$color_file" ]; then
        local colors=($(head -6 "$color_file" | tr -d '#'))
        if [ ${#colors[@]} -ge 3 ]; then
            c_prim="\e[38;2;$((16#${colors[0]:0:2}));$((16#${colors[0]:2:2}));$((16#${colors[0]:4:2}))m"
            c_sec="\e[38;2;$((16#${colors[1]:0:2}));$((16#${colors[1]:2:2}));$((16#${colors[1]:4:2}))m"
            c_logo="\e[38;2;$((16#${colors[2]:0:2}));$((16#${colors[2]:2:2}));$((16#${colors[2]:4:2}))m"
            return 0
        fi
    fi
    return 1
}

load_color() {
    case "$1" in
        inir)
            detect_inir_colors || { c_prim="\e[31m"; c_sec="\e[34m"; c_logo="\e[35m"; }
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
    mkdir -p "$CONFIG_DIR"
    echo 'COLOR="'"$COLOR"'"' > "$CONFIG_FILE"
    echo 'PRESET="'"$PRESET"'"' >> "$CONFIG_FILE"
    echo 'SHOW_KERNEL='"$SHOW_KERNEL" >> "$CONFIG_FILE"
    echo 'SHOW_UPTIME='"$SHOW_UPTIME" >> "$CONFIG_FILE"
    echo 'SHOW_MEMORY='"$SHOW_MEMORY" >> "$CONFIG_FILE"
}

# Detect terminal emulator (real emulator, not the shell)
detect_terminal() {
    # Check well-known env variables first
    if [ -n "$KITTY_WINDOW_ID" ]; then echo "kitty"; return; fi
    if [ -n "$ALACRITTY_WINDOW_ID" ]; then echo "alacritty"; return; fi
    if [ -n "$WEZTERM_EXECUTABLE" ]; then echo "wezterm"; return; fi
    if [ -n "$KONSOLE_VERSION" ]; then echo "konsole"; return; fi
    if [ -n "$GNOME_TERMINAL_SCREEN" ]; then echo "gnome-terminal"; return; fi
    if [ "$TERM_PROGRAM" = "vscode" ]; then echo "vscode"; return; fi
    # foot sets $TERM to foot or foot-direct
    if [ "$TERM" = "foot" ] || [ "$TERM" = "foot-direct" ]; then echo "foot"; return; fi
    # Walk up process tree looking for known terminal binaries
    local pid=$$
    for _ in 1 2 3 4 5; do
        pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
        [ -z "$pid" ] || [ "$pid" = "1" ] && break
        local comm
        comm=$(ps -o comm= -p "$pid" 2>/dev/null)
        case "$comm" in
            foot|kitty|alacritty|wezterm|xterm|urxvt|st|konsole|gnome-terminal*|tilix|hyper)
                echo "$comm"; return ;;
        esac
    done
    echo "unknown"
}

# Detect the real interactive shell (not the one running this script)
detect_shell() {
    # $SHELL is the login shell, most reliable
    basename "${SHELL:-bash}"
}

detect_env() {
    echo "Shell: $(detect_shell) | Terminal: $(detect_terminal)"
}

get_rc_file() {
    local shell_name="$1"
    case "$shell_name" in
        fish)
            local f="$HOME/.config/fish/config.fish"
            mkdir -p "$(dirname "$f")"
            echo "$f" ;;
        zsh)
            echo "$HOME/.zshrc" ;;
        bash|*)
            # prefer .bashrc, fall back to .bash_profile
            if [ -f "$HOME/.bash_profile" ] && [ ! -f "$HOME/.bashrc" ]; then
                echo "$HOME/.bash_profile"
            else
                echo "$HOME/.bashrc"
            fi ;;
    esac
}

manage_startup() {
    local action="$1"
    local shell_name
    shell_name=$(detect_shell)
    local rc_file
    rc_file=$(get_rc_file "$shell_name")
    local term
    term=$(detect_terminal)

    local hook_start="# --- VIBEFETCH AUTO-START ---"
    local hook_end="# --- VIBEFETCH AUTO-START END ---"

    echo "Detected shell    : $shell_name"
    echo "Detected terminal : $term"
    echo "Config file       : $rc_file"

    if [ "$action" = "enable" ]; then
        if grep -q "$hook_start" "$rc_file" 2>/dev/null; then
            echo "✅ Already enabled in $rc_file"
        else
            touch "$rc_file"
            printf '\n%s\nvibefetch\n%s\n' "$hook_start" "$hook_end" >> "$rc_file"
            echo "✨ Enabled! Restart $term or run: source $rc_file"
        fi
    elif [ "$action" = "disable" ]; then
        if grep -q "$hook_start" "$rc_file" 2>/dev/null; then
            if command -v perl >/dev/null 2>&1; then
                perl -i -0pe "s/\n*\Q$hook_start\E.*?\Q$hook_end\E\n*//s" "$rc_file"
            else
                sed -i.bak "/$hook_start/,/$hook_end/d" "$rc_file"
                rm -f "${rc_file}.bak"
            fi
            echo "🗑️  Disabled from $rc_file"
        else
            echo "ℹ️  Not currently enabled in $rc_file"
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
        --enable-startup)  manage_startup "enable" ;;
        --disable-startup) manage_startup "disable" ;;
        --detect-env)      detect_env; exit 0 ;;
        -c|--color)        COLOR="$2"; CONFIG_CHANGED=true; shift ;;
        -p|--preset)       PRESET="$2"; CONFIG_CHANGED=true; shift ;;
        --preview)         preview ;;
        -h|--help)
            echo "Usage: vibefetch [OPTIONS]"
            echo "  -c, --color <name>    inir, ocean, dracula, cyberpunk, forest, vaporwave"
            echo "  -p, --preset <name>   classic, block, boxes, dots"
            echo "  --preview             Show all presets for current color"
            echo "  --enable-startup      Auto-start on terminal open"
            echo "  --disable-startup     Remove auto-start"
            echo "  --detect-env          Show detected shell and terminal"
            exit 0 ;;
    esac
    shift
done

[ "$CONFIG_CHANGED" = true ] && save_config

print_info
