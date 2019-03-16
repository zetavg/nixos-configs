# NixOS Configurations

My NixOS configurations.

## Usage

1. Clone this repo to `/etc/nixos`.
2. `cp -n /etc/nixos/configuration.nix.sample /etc/nixos/configuration.nix`.
3. Edit `configuration.nix`.
4. Clone or copy local configuration to `/etc/nixos/configuration-local` or `/etc/nixos/configuration-local.nix`.
5. `nixos-rebuild switch`.
