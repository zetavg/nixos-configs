/*
 * DNS Server
 */

{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; lib.mkAfter [
    bind
  ];

  services.bind.enable = true;
}
