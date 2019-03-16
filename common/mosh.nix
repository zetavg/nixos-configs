# Mosh: The Mobile Shell
{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; lib.mkAfter [
    mosh
  ];

  programs.mosh.enable = true;
}
