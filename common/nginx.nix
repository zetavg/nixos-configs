# Web Server
{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; lib.mkAfter [
    nginx
  ];

  services.nginx.enable = true;
}
