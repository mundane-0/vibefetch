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
            local c_p c_s c_l
            c_p=$(jq -r '.primary // empty' "$color_file" | tr -d '\r\n#')
            c_s=$(jq -r '.secondary // empty' "$color_file" | tr -d '\r\n#')
            c_l=$(jq -r '.tertiary // empty' "$color_file" | tr -d '\r\n#')
            if [ -n "$c_p" ]; then
                c_prim="\e[38;2;$((16#${c_p:0:2}));$((16#${c_p:2:2}));$((16#${c_p:4:2}))m"
                c_sec="\e[38;2;$((16#${c_s:0:2}));$((16#${c_s:2:2}));$((16#${c_s:4:2}))m"
                c_logo="\e[38;2;$((16#${c_l:0:2}));$((16#${c_l:2:2}));$((16#${c_l:4:2}))m"
                return 0
            fi
        else
            local colors
            colors=($(head -6 "$color_file" | tr -d '\r\n#'))
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

# --- LAYOUT ENGINE ---
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

# --- CONFIG ---
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
        # shellcheck disable=SC1090
        source "$CONFIG_FILE"
        # Sanitize potentially corrupted config values
        case "$SIZE" in compact|normal|large) ;; *) SIZE="normal" ;; esac
        case "$PRESET" in classic|boxes|dots|block|full|nano) ;; *) PRESET="classic" ;; esac
        case "$COLOR" in inir|ocean|dracula|cyberpunk|forest|vaporwave) ;; *) COLOR="ocean" ;; esac
    else
        mkdir -p "$CONFIG_DIR"
        printf 'COLOR="ocean"\nPRESET="classic"\nSIZE="normal"\nSHOW_KERNEL="true"\nSHOW_UPTIME="true"\nSHOW_MEMORY="true"\nINIR_COLOR_PATH=""\n' > "$CONFIG_FILE"
    fi
}

save_config() {
    mkdir -p "$CONFIG_DIR"
    printf 'COLOR="%s"\nPRESET="%s"\nSIZE="%s"\nSHOW_KERNEL="%s"\nSHOW_UPTIME="%s"\nSHOW_MEMORY="%s"\nINIR_COLOR_PATH="%s"\n' \
        "$COLOR" "$PRESET" "$SIZE" "$SHOW_KERNEL" "$SHOW_UPTIME" "$SHOW_MEMORY" "$INIR_COLOR_PATH" > "$CONFIG_FILE"
}

# --- STARTUP MANAGEMENT ---
# All historical marker pairs (newest first). Disable purges EVERY legacy block
# so upgrades from old versions never leave orphans in the rc file.
MARKERS=(
    "# --- VIBEFETCH AUTO-START ---|# --- VIBEFETCH AUTO-START END ---"
    "# --- VIBEFETCH START ---|# --- VIBEFETCH END ---"
)

detect_shell() {
    # The rc file belongs to the login shell ($SHELL) — trust it first
    local login_shell
    login_shell=$(basename "${SHELL:-bash}")
    case "$login_shell" in
        fish|zsh|bash) echo "$login_shell"; return ;;
    esac
    # Fallback: walk the process tree
    local pid=$$
    local i comm
    for i in 1 2 3; do
        pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
        [ -z "$pid" ] || [ "$pid" = "1" ] && break
        comm=$(ps -o comm= -p "$pid" 2>/dev/null)
        case "$comm" in
            fish|zsh|bash) echo "$comm"; return ;;
        esac
    done
    echo "bash"
}

detect_terminal() {
    if [ -n "$KITTY_WINDOW_ID" ]; then echo "kitty"; return; fi
    if [ -n "$ALACRITTY_WINDOW_ID" ]; then echo "alacritty"; return; fi
    if [ -n "$WEZTERM_EXECUTABLE" ]; then echo "wezterm"; return; fi
    if [ -n "$KONSOLE_VERSION" ]; then echo "konsole"; return; fi
    if [ -n "$GNOME_TERMINAL_SCREEN" ]; then echo "gnome-terminal"; return; fi
    if [ "$TERM_PROGRAM" = "vscode" ]; then echo "vscode"; return; fi
    case "$TERM" in foot|foot-direct) echo "foot"; return ;; esac
    echo "unknown"
}

get_rc_file() {
    case "$1" in
        fish)
            local f="$HOME/.config/fish/config.fish"
            mkdir -p "$(dirname "$f")"
            echo "$f" ;;
        zsh) echo "$HOME/.zshrc" ;;
        bash|*)
            if [ -f "$HOME/.bash_profile" ] && [ ! -f "$HOME/.bashrc" ]; then
                echo "$HOME/.bash_profile"
            else
                echo "$HOME/.bashrc"
            fi ;;
    esac
}

remove_all_hooks() {
    local file="$1"
    [ -f "$file" ] || return 0
    local pair start end
    for pair in "${MARKERS[@]}"; do
        start="${pair%%|*}"
        end="${pair##*|}"
        if grep -qF "$start" "$file" 2>/dev/null; then
            if command -v perl >/dev/null 2>&1; then
                perl -i -0pe "s/\n*\Q$start\E.*?\Q$end\E\n*//s" "$file"
            else
                sed -i.bak "/\Q$start\E/,/\Q$end\E/d" "$file" 2>/dev/null || sed -i.bak "/$start/,/$end/d" "$file"
                rm -f "${file}.bak"
            fi
        fi
    done
}

manage_startup() {
    local action="$1"
    local shell_name rc_file term
    shell_name=$(detect_shell)
    rc_file=$(get_rc_file "$shell_name")
    term=$(detect_terminal)

    local h_start="# --- VIBEFETCH AUTO-START ---"
    local h_end="# --- VIBEFETCH AUTO-START END ---"

    printf 'Detected shell    : %s\nDetected terminal : %s\nConfig file       : %s\n' \
        "$shell_name" "$term" "$rc_file"

    if [ "$action" = "enable" ]; then
        # Purge every legacy block first to avoid duplicates from old versions
        remove_all_hooks "$rc_file"
        touch "$rc_file"
        # Guarded + shell-specific: silently no-ops if the binary is ever removed,
        # so an uninstall never breaks terminal startup.
        local hook_cmd
        if [ "$shell_name" = "fish" ]; then
            hook_cmd='if command -v vibefetch >/dev/null 2>&1; vibefetch; end'
        else
            hook_cmd='command -v vibefetch >/dev/null 2>&1 && vibefetch'
        fi
        printf '\n%s\n%s\n%s\n' "$h_start" "$hook_cmd" "$h_end" >> "$rc_file"
        echo "✨ Auto-start enabled. Restart $term (or open a new tab) to test."
    else
        remove_all_hooks "$rc_file"
        echo "🗑️  Auto-start disabled (all legacy hooks purged)."
    fi
    exit 0
}

manage_uninstall() {
    local shell_name rc_file
    shell_name=$(detect_shell)
    rc_file=$(get_rc_file "$shell_name")
    remove_all_hooks "$rc_file"
    echo "🗑️  Startup hook removed from $rc_file"
    local self
    self=$(command -v vibefetch 2>/dev/null)
    if [ -n "$self" ]; then
        if [ -w "$self" ]; then
            rm -f "$self" && echo "🗑️  Binary removed: $self"
        else
            rm -f "$self" 2>/dev/null && echo "🗑️  Binary removed: $self" \
                || { echo "🔐 Need sudo to remove $self — run:"; echo "   sudo rm -f $self"; }
        fi
    fi
    echo "✨ Vibefetch fully uninstalled."
    exit 0
}

# --- HELP ---
show_help() {
    load_color "${COLOR:-ocean}"
    printf "\n"
    printf "%b  🌊 VIBEFETCH %b - Minimalist Linux Sysfetch\n" "${c_logo}${c_bold}" "${c_reset}"
    printf "\n"
    printf "%b  USAGE:%b\n" "${c_prim}" "${c_reset}"
    printf "    vibefetch [OPTIONS]\n"
    printf "\n"
    printf "%b  OPTIONS (Design):%b\n" "${c_prim}" "${c_reset}"
    printf "    %b-c, --color <name>%b   Set theme colors and save it\n" "${c_sec}" "${c_reset}"
    printf "                           inir (auto from your wallpaper), ocean,\n"
    printf "                           dracula, cyberpunk, forest, vaporwave\n"
    printf "    %b-p, --preset <name>%b  Set the layout architecture and save it\n" "${c_sec}" "${c_reset}"
    printf "                           classic, full (detailed), boxes,\n"
    printf "                           block, dots, nano (1-liner)\n"
    printf "    %b-s, --size <name>%b    Set line spacing and save it\n" "${c_sec}" "${c_reset}"
    printf "                           compact, normal, large\n"
    printf "\n"
    printf "%b  OPTIONS (Functional):%b\n" "${c_prim}" "${c_reset}"
    printf "    %b--preview%b            Show every preset with your current combo\n" "${c_sec}" "${c_reset}"
    printf "    %b--enable-startup%b     Auto-launch on terminal open (bash/zsh/fish)\n" "${c_sec}" "${c_reset}"
    printf "    %b--disable-startup%b    Remove auto-launch (purges legacy hooks too)\n" "${c_sec}" "${c_reset}"
    printf "    %b--uninstall%b         Remove hook + binary in one command\n" "${c_sec}" "${c_reset}"
    printf "    %b--detect-env%b         Show detected shell and terminal\n" "${c_sec}" "${c_reset}"
    printf "    %b-h, help, --help%b     Show this menu\n" "${c_sec}" "${c_reset}"
    printf "\n"
    printf "%b  Config lives in ~/.config/vibefetch/config%b\n" "${c_logo}" "${c_reset}"
    printf "%b  Every option above is saved automatically.%b\n\n" "${c_logo}" "${c_reset}"
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
    local p
    for p in classic full boxes block dots nano; do
        PRESET="$p"
        printf -- '--- Previewing PRESET: \033[1m%s\033[0m (Size: %s, Color: %s) ---\n' "$p" "$SIZE" "$COLOR"
        print_info
    done
    exit 0
}

# --- MAIN ---
need_arg() {
    if [ -z "$2" ] || [ "${2#-}" != "$2" ]; then
        echo "Error: $1 requires a value." >&2
        show_help
        exit 1
    fi
}

load_config
CONFIG_CHANGED=false

if [ "$#" -eq 1 ]; then
    case "$1" in
        help|-h|--help) show_help; exit 0 ;;
        --preview) preview ;;
    esac
fi

while [ "$#" -gt 0 ]; do
    case $1 in
        --enable-startup)  manage_startup "enable" ;;
        --disable-startup) manage_startup "disable" ;;
        --uninstall)       manage_uninstall ;;
        --detect-env)      printf 'Shell: %s | Terminal: %s\n' "$(detect_shell)" "$(detect_terminal)"; exit 0 ;;
        -s|--size)         need_arg "$1" "$2"; SIZE="$2"; CONFIG_CHANGED=true ;;
        -c|--color)        need_arg "$1" "$2"; COLOR="$2"; CONFIG_CHANGED=true ;;
        -p|--preset)       need_arg "$1" "$2"; PRESET="$2"; CONFIG_CHANGED=true ;;
        --preview)         preview ;;
        help|-h|--help)    show_help; exit 0 ;;
        *)                 echo "Unknown option: $1" >&2; show_help; exit 1 ;;
    esac
    shift 2 2>/dev/null || shift
done

if [ "$CONFIG_CHANGED" = true ]; then
    case "$SIZE" in compact|normal|large) ;; *) echo "Error: invalid size '$SIZE' (compact|normal|large)" >&2; exit 1 ;; esac
    case "$PRESET" in classic|boxes|dots|block|full|nano) ;; *) echo "Error: invalid preset '$PRESET' (classic|boxes|dots|block|full|nano)" >&2; exit 1 ;; esac
    case "$COLOR" in inir|ocean|dracula|cyberpunk|forest|vaporwave) ;; *) echo "Error: invalid color '$COLOR'" >&2; exit 1 ;; esac
    save_config
fi

print_info
