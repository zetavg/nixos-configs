{ lib, ... }:

{
  imports = [
    ../../common/openssh.nix
    ../../common/mosh.nix
  ];

  # Close the connection after 4 × 8 = 32 secs of unreachability
  # to prevent dead connections occupying the port.
  services.openssh.extraConfig = ''
    ClientAliveInterval 4
    ClientAliveCountMax 8
  '';
}
