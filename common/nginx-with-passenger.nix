{ pkgs, lib, config, ... }:

let
  pkgs = import ../pkgs { };
  nginx = pkgs.nginx-with-passenger;
  passenger = pkgs.nginx-with-passenger.passenger;
in {
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

  imports = [
    ../services/passenger-log-systemd-cat.nix
  ];
}
