# 🌊 Vibefetch

A minimalist, aesthetic system fetch tool for Linux vibecoders.
Pure Bash. Zero dependencies. Installs in 3 seconds.

## Installation (3 Seconds)

Copy this block into your terminal:

```bash
sudo curl -sL "https://raw.githubusercontent.com/mundane-0/vibefetch/main/vibefetch.sh" -o /usr/local/bin/vibefetch && sudo chmod +x /usr/local/bin/vibefetch
```

## Usage

```bash
vibefetch               # launch with your saved settings
vibefetch --preview     # see every preset with your current combo
vibefetch help          # full interactive help menu
```

## Design Options (saved automatically)

| Option | Values | Description |
|---|---|---|
| `-c, --color` | `inir` `ocean` `dracula` `cyberpunk` `forest` `vaporwave` | Theme colors — `inir` reads your live wallpaper palette |
| `-p, --preset` | `classic` `full` `boxes` `block` `dots` `nano` | Layout architecture |
| `-s, --size` | `compact` `normal` `large` | Line spacing |

```bash
vibefetch --color inir --preset boxes --size large
```

## Auto-Start

```bash
vibefetch --enable-startup    # detects bash / zsh / fish + your terminal
vibefetch --disable-startup   # removes every hook, including legacy ones
```

## Preset Showcase

```
classic                 full                    nano
VIBEFETCH               user@host               >> Bedrock Linux [1 day]
OS     | Bedrock        ───────────────
Kernel | 7.2.7          OS   Bedrock Linux
Uptime | 1 day          ENV  foot / fish
Memory | 6.6GB / 15.9GB SYS  7.2.7-arch1-1
                        UP   1 day
                        RAM  6678MB / 15897MB
```

## Uninstall (3 Seconds)

```bash
vibefetch --uninstall
```

Removes the startup hook **and** the binary in one shot. Startup hooks are
guarded (`command -v vibefetch`), so even a plain `sudo rm` never breaks your
terminal — the hook just silently does nothing.

## Config

Settings live in `~/.config/vibefetch/config` (auto-created, auto-saved).

## License

MIT
