{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; lib.mkAfter [
    zsh
    antibody
  ];

  programs.zsh.enable = true;
  programs.zsh.shellInit = ''
    PATH=$PATH:/run/current-system/sw/bin/
    zsh-newuser-install() { :; }
  '';
}
