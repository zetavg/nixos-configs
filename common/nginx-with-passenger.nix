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
    # ../services/passenger-log-systemd-cat.nix # We use Filebeat to pipe logs to Logstash now
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
      passenger_log_file ${config.services.nginx.stateDir}/logs/passenger.log;
    '';
  };

  # Give Nginx a home so Passenger can have a place to store built native support files
  users.users.nginx.home = "/home/nginx";
}
