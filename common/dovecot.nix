{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; lib.mkAfter [
    dovecot
  ];

  services.dovecot2.enable = true;
}
