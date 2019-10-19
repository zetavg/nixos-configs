{ pkgs, lib, ... }:

{
  imports = [
    ../services/heartbeat7.nix
  ];

  services.heartbeat7 = {
    enable = true;
  };
}
