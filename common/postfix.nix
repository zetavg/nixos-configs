/*
 * SMTP Mail Server
 */

{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; lib.mkAfter [
    postfix
  ];

  services.postfix.enable = true;
  services.postfix.extraConfig = ''
    message_size_limit = 104857600
    mailbox_size_limit = 1048576000
  '';
}
