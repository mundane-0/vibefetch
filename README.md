# Vibefetch 🌊

A minimalist, aesthetic system fetch tool for Linux vibecoders.
Takes literally 3 seconds to install and removes all the bloat.

## Features

- 🐧 **Bedrock Linux Support:** Accurately detects `Bedrock Linux` natively!
- 🎨 **Colors & Presets:** Choose from 5 colors (`ocean`, `dracula`, `cyberpunk`, `forest`, `vaporwave`) and 4 beautiful layout presets (`classic`, `boxes`, `dots`, `block`).
- ⚙️ **Configurable:** Settings auto-saved on the fly to `~/.config/vibefetch/config`.

## Installation (3 Seconds)

Copy and paste this single block into your terminal to safely install `vibefetch` globally (cache-busting URL ensures you always get the latest version):

```bash
sudo curl -sL "https://raw.githubusercontent.com/mundane-0/vibefetch/main/vibefetch.sh?v=$RANDOM" -o /usr/local/bin/vibefetch && sudo chmod +x /usr/local/bin/vibefetch
```

## Usage

```bash
# Preview all layouts!
vibefetch --preview

# Run normally
vibefetch

# Override layout and color on the fly (it will remember this for next time!)
vibefetch --color dracula --preset boxes
```

## Uninstall (3 Seconds)

If you ever want to remove it:

```bash
sudo rm -f /usr/local/bin/vibefetch
```
