# SMTP Mail Server
{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; lib.mkAfter [
    postfix
  ];

  services.postfix.enable = true;
}
