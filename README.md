# Vibefetch 🌊

A minimal, aesthetic system fetch tool for Linux vibecoders.

## Features

- 🐧 **Bedrock Linux Support:** Accurately detects `Bedrock Linux` natively!
- 🎨 **Colors & Presets:** Choose from 5 colors (`ocean`, `dracula`, `cyberpunk`, `forest`, `vaporwave`) and 4 vastly different layout presets (`classic`, `inline`, `minimal`, `block`).
- ⚙️ **Configurable:** Settings auto-generated at `~/.config/vibefetch/config`.

## Installation

```bash
git clone https://github.com/mundane-0/vibefetch.git
cd vibefetch
sudo make install
```

## Usage

```bash
# Preview all layouts!
vibefetch --preview

# Run normally
vibefetch

# Override layout and color on the fly
vibefetch --color cyberpunk --preset block
```
