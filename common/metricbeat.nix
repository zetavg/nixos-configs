{ lib, ... }:

{
  imports = [
    ../services/metricbeat.nix
  ];

  services.metricbeat = {
    enable = true;
  };
}
