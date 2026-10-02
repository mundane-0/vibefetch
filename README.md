# Vibefetch 🌊

A minimal, aesthetic system fetch tool for Linux vibecoders. No bloat, just the essentials in your terminal.

## Example

```text
  VIBEFETCH 
  OS     | Ubuntu 24.04 LTS
  Kernel | 6.8.0-31-generic
  Uptime | 2 hours, 15 minutes
  Memory | 3245MB / 15892MB
```

## Features

- 🐧 **Fast & Lightweight:** Pure Bash, no heavy dependencies.
- 🎨 **Aesthetic:** Clean layout with bash ANSI colors.
- ⚡ **Accurate:** Instant detection of OS, Kernel, Uptime, and Memory usage.

## Installation

Clone the repository and install using `make`:

```bash
git clone https://github.com/mundane-0/vibefetch.git
cd vibefetch
sudo make install
```

## Usage

Simply run `vibefetch` in your terminal:

```bash
vibefetch
```

## Uninstall

To remove it from your system:

```bash
sudo make uninstall
```
