# BitTorrent Client
{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; lib.mkAfter [
    transmission
  ];

  services.transmission.enable = true;
}
