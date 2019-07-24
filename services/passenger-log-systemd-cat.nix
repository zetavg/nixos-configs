{ pkgs, lib, config, ... }:
{
  options = {
    services.passengerLogSystemdCat = {
      enable = lib.mkOption {
        default = true;
        type = with lib.types; bool;
        description = ''
          Pipe Passenger log file to systemd-cat.
        '';
      };

      logFile = lib.mkOption {
        default = "/var/log/passenger.log";
        type = with lib.types; uniq string;
        description = ''
          Location of the log file.
        '';
      };
    };
  };

  config = lib.mkIf config.services.passengerLogSystemdCat.enable {
    environment.systemPackages = [ pkgs.coreutils pkgs.systemd ];

    systemd.services.passengerLogSystemdCat = {
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      description = "Start piping Passenger log file to systemd-cat.";
      preStart = ''
        ${pkgs.coreutils}/bin/mkdir -p /var/log
        ${pkgs.coreutils}/bin/touch /var/log/passenger.log
        ${pkgs.coreutils}/bin/touch /var/log/passenger-log-systemd-cat
      '';
      script = ''
        ${pkgs.coreutils}/bin/tail -f ${config.services.passengerLogSystemdCat.logFile} | ${pkgs.systemd}/bin/systemd-cat -t passenger
      '';
    };
  };
}
