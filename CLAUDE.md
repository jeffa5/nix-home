# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal NixOS and home-manager configuration repository managing multiple machines (laptops, desktops, and Raspberry Pi devices) and user environments. The configuration uses Nix flakes and is structured around reusable modules.

## Core Commands

### Building and Testing

```bash
# Build a NixOS configuration (creates ./result symlink)
nixos-rebuild build --flake .

# Switch to a new configuration (current system)
nixos-rebuild switch --flake .

# Switch with a specific host
nixos-rebuild switch --flake .#x1c6

# Build home-manager configuration
home-manager switch --flake .#andrew

# Show differences before upgrading
make nvd

# Alternative diff commands
make diff       # using nix store diff-closures
make diff-all   # show all profile generations

# Check formatting and dead code
nix flake check
```

### Formatting and Linting

```bash
# Format all Nix files
nix fmt

# Check for dead code
nix build .#deadnix

# Check formatting
nix build .#nixfmt
```

### Remote Deployment

```bash
# Deploy to remote host (requires passwordless SSH as root)
nix run .#deploy <hostname>

# Or manually
nixos-rebuild switch .#<host> --build-host root@<ip> --target-host root@<ip> --no-reexec

# Hosts and IPs are defined in nixos/hosts.nix
```

The `deploy` script uses `nh` (nix-helper) internally and references `nixos/hosts.nix` for IP addresses. Hosts include: carbide, xps15, x1c6, cubenas, and various Raspberry Pi devices.

## Repository Architecture

### Flake Structure

- **flake.nix**: Entry point defining all configurations, inputs, and outputs
- **Inputs**: External flake dependencies including custom packages (papers, tasknet, waytext, wordnet-ls, maills, icalls, stagix, stafil)
- **Overlays**: Custom packages are made available via overlays (sway-overlay, custom-overlay)
- **Outputs**:
  - `nixosConfigurations`: Full system configs (carbide, xps15, x1c6, cubenas)
  - `homeConfigurations`: Standalone home-manager configs for different users
  - `packages`: Custom packages including deployment tools
  - `checks`: Formatting and linting checks
  - `formatter`: Uses alejandra

### Directory Layout

```
.
├── flake.nix              # Main flake configuration
├── nixos/                 # NixOS system configurations
│   ├── default.nix        # Shared system config (locale, users, services)
│   ├── modules/           # Reusable system modules (sway, nix, tailscale, etc.)
│   ├── carbide/           # Desktop machine config
│   ├── xps15/             # Dell XPS 15 laptop config
│   ├── x1c6/              # ThinkPad X1 Carbon 6th gen config
│   ├── cubenas/           # NAS server config
│   └── rpi*/              # Raspberry Pi configs
├── home/                  # Home-manager configurations
│   ├── default.nix        # Entry point for home config
│   └── modules/           # Reusable home modules (GUI, TUI, specific apps)
├── packages/              # Custom package definitions
│   ├── colemakdh/         # Colemak DH keyboard layout
│   ├── status-bar/        # Sway status bar
│   └── sway-scripts/      # Helper scripts for Sway
├── deploy.nix             # Remote deployment script generator
└── Makefile               # Convenience targets for diffs and dconf
```

### Machine Configuration Pattern

Each machine is created with `mkMachine` which takes:
- `modules`: List of machine-specific modules (hardware config, etc.)
- `users`: List of usernames to configure
- `gui`: Boolean for GUI vs headless

Example: `x1c6` uses ThinkPad-specific hardware module from nixos-hardware and includes GUI.

### Home Configuration Pattern

Home configurations support GUI and TUI variants:
- `andrew`: Full GUI home config
- `andrew-tui`: Terminal-only config
- Pattern allows standalone home-manager usage on non-NixOS systems

The split is controlled by the `gui` parameter which conditionally imports `./modules/gui.nix`.

### Special Machine Types

- **Standard machines** (carbide, xps15, x1c6): Use current nixpkgs (25.11)
- **cubenas** (NAS): Uses stableNixpkgs explicitly for stability
- **Raspberry Pi**: Uses stableNixpkgs + nixos-hardware Raspberry Pi 4 module, aarch64-linux architecture

## Key Configuration Details

### Keyboard Layout

- Uses Colemak DH layout (custom package in `packages/colemakdh/`)
- Applied at console level (`console.keyMap`) and X11/Wayland level
- Console keymap: `iso-uk-colemak-dh`
- XKB layout: `uk-cdh` (custom) with fallback to `gb`

### GUI Environment

- Default GUI: Sway (Wayland compositor)
- Previously used GNOME/Plasma (modules still available but not default)
- GUI-specific modules in `nixos/modules/sway.nix` and `home/modules/gui.nix`

### User Configuration

- Primary user: `andrew` (also `apj39` for alternate environments)
- Shell: Fish (with vendor completions/config/functions enabled)
- User groups: wheel, docker, plugdev, adbusers, libvirtd

### System Features

- Bluetooth enabled with experimental features for battery status
- Pipewire for audio (ALSA + PulseAudio compatibility)
- iwd for wireless networking (not NetworkManager)
- Automatic system upgrades disabled by default (module commented out)
- System shows diff on activation via userActivationScript

## Module Organization

### NixOS Modules (nixos/modules/)

Reusable system-level functionality:
- **nix.nix**: Nix daemon settings, flakes, trusted users
- **sway.nix**: Sway window manager setup
- **tailscale.nix**: Tailscale VPN
- **openssh.nix**: SSH server config
- **printing.nix**, **scanning.nix**: Printer/scanner support
- **nextcloud.nix**: Nextcloud client/server
- **mosquitto.nix**: MQTT broker
- **grafana.nix**, **influxdb.nix**, **loki.nix**: Monitoring stack
- **authelia.nix**: Authentication proxy
- **nodeboard.nix**, **homeboard.nix**: Custom dashboard services

### Home Modules (home/modules/)

User-level application configuration:
- **home.nix**: Core home-manager settings
- **tui.nix**: Terminal applications (varies by gui flag)
- **gui.nix**: Graphical applications (Sway, terminal emulators, etc.)
- **cargo.nix**: Rust toolchain
- **nix.nix**: User-level Nix settings
- Specific apps: alacritty, foot, fuzzel, wofi, zathura, imv, bat, helix, papers, etc.

## External Dependencies

This configuration imports several custom packages maintained in separate repositories:
- **papers**: PDF/paper management tool
- **tasknet**: Task networking utility
- **waytext**: Wayland text input tool
- **wordnet-ls**: WordNet language server
- **maills**: Mail language server
- **icalls**: iCal language server
- **stagix**: Static site generator (fork)
- **stafil**: Custom tool from git.jeffas.net
- **prometheus-restic-exporter**: Restic backup monitoring

These are integrated via flake inputs and made available through custom overlays.

## Testing Configuration Changes

1. Build first to check for errors: `nixos-rebuild build --flake .`
2. Review differences: `make nvd` or `make diff`
3. Apply changes: `nixos-rebuild switch --flake .`
4. For remote systems: `nix run .#deploy <hostname>`

The system automatically shows closure diffs on activation via the userActivationScript in nixos/default.nix.

## Notes

- Experimental Nix features (nix-command, flakes) are enabled by default
- Allows unfree packages system-wide
- Uses systemd in initrd
- /tmp mounted as tmpfs for performance
- Console keyboard layout applied early in boot process
- Nix daemon uses /var/tmp to avoid tmpfs space issues
