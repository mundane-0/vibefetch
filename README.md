# Vibefetch 🌊

A minimal, aesthetic system fetch tool for Linux vibecoders.

## Features

- 🐧 **Bedrock Linux Support:** Accurately detects `Bedrock Linux` natively!
- 🎨 **Minimal & Aesthetic:** Clean ANSI layout with 5 built-in preset themes (`ocean`, `dracula`, `cyberpunk`, `forest`, `vaporwave`).
- ⚙️ **Configurable:** Automatically creates `~/.config/vibefetch/config` on first run to toggle display components or set themes.

## Installation

```bash
git clone https://github.com/mundane-0/vibefetch.git
cd vibefetch
sudo make install
```

## Usage

```bash
# Preview all themes (the hover experience)
vibefetch --preview

# Run normally
vibefetch

# Override theme on the fly
vibefetch -t cyberpunk
```

## Settings

Settings are generated at `~/.config/vibefetch/config`:

```bash
# Example Config
THEME="dracula" 
SHOW_KERNEL=true
SHOW_UPTIME=true
SHOW_MEMORY=false # Toggle off to hide memory
```
