{ config, pkgs, lib, ... }:

{
  imports = [
    ./nix.nix
    <nixpkgs/nixos/modules/virtualisation/google-compute-config.nix>
    ./fstab.nix
    ./users.nix
    ./ssh.nix
    ./servers
    ./elk.nix
    ./metricbeat.nix
    ./heartbeat.nix
    ./torrent.nix
  ];

  # Auto resize takes too long (about 160s) on each boot
  fileSystems."/".autoResize = lib.mkForce false;

  networking.hostName = lib.mkOverride 800 "serv.cat";

  systemd.services.fetch-ssh-keys.enable = false;
  systemd.services.google-clock-skew-daemon.enable = false;
  systemd.services.google-instance-setup.enable = false;

  networking.timeServers = lib.mkForce [
    "0.nixos.pool.ntp.org"
    "1.nixos.pool.ntp.org"
    "2.nixos.pool.ntp.org"
    "3.nixos.pool.ntp.org"
  ];

  environment.systemPackages = with pkgs; lib.mkAfter [
    parted
    cloud-utils
    git
    vim
    direnv
    wakatime
  ];
}
