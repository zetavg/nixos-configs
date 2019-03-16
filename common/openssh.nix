# SSH Server
{ lib, ... }:

{
  services.openssh = {
    enable = true;
    permitRootLogin = lib.mkForce "no";
    passwordAuthentication = false;
  };
}
