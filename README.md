# Vibefetch 🌊

A minimalist, aesthetic system fetch tool for Linux vibecoders.
Takes literally 3 seconds to install and removes all the bloat.

## Features

- 🐧 **Bedrock Linux Support:** Accurately detects `Bedrock Linux` natively!
- 🎨 **Layout Presets:** Choose between 6 designs (`full`, `classic`, `boxes`, `dots`, `block`, `nano`).
- 📏 **Size Scaling:** Adjust your terminal footprint dynamically (`compact`, `normal`, `large`). 
- 🖼️ **iNiR Support:** Uses the `inir` theme to dynamically extract wallpaper colors from your environment!
- 🚀 **Auto-Start:** Optionally launch automatically when you open a terminal (`vibefetch --enable-startup`).
- ⚡ **Extremely Fast:** Optimized with pure bash logic. Zero dependencies, instantaneous loads.

## Installation (3 Seconds)

```bash
sudo curl -sL "https://raw.githubusercontent.com/mundane-0/vibefetch/main/vibefetch.sh?v=$RANDOM" -o /usr/local/bin/vibefetch && sudo chmod +x /usr/local/bin/vibefetch
```

## Usage

```bash
# Preview all layouts!
vibefetch --preview

# Set a tiny minimalist fetch
vibefetch --size compact --preset nano

# Set a massive detailed fetch 
vibefetch --size large --preset full

# Set colors to strictly match your wallpaper Engine
vibefetch --color inir
```

## Uninstall

```bash
sudo rm -f /usr/local/bin/vibefetch
```
