/*
 * Web Application Server
 */

{ pkgs, lib, config, ... }:

let
  nginx = pkgs.nginx-with-passenger;
  passenger = pkgs.nginx-with-passenger.passenger;
in {
  imports = [
    ./zpkgs.nix # nginx-with-passenger is in zpkgs
    ../services/passenger-log-systemd-cat.nix
  ];

  environment.systemPackages = lib.mkAfter [
    nginx
    passenger
  ];

  services.nginx = {
    enable = true;
    package = nginx;

    appendHttpConfig = ''
      passenger_root ${passenger};
      passenger_log_file /var/log/passenger.log;
    '';
  };
}
