{ pkgs, lib, config, ... }:

with lib;

let
  serviceName = "heartbeat7";

  # TODO: There're more options and configs!
  options = {
    enable = mkEnableOption "Heartbeat";

    monitors = mkOption {
      description = "Heartbeat monitors config, see https://www.elastic.co/guide/en/beats/heartbeat/7.x/configuration-heartbeat-options.html";
      default = [];
      example = [
        {
          type = "http";
          urls = [ "http://localhost:5601" ];
          schedule = "@every 10s";
        }
      ];
      type = types.listOf types.attrs;
    };

    outputElasticsearch = {
      hosts = mkOption {
        default = [ "localhost:9200" ];
        type = types.nullOr (types.listOf types.str);
      };
    };

    package = mkOption {
      description = "Heartbeat package to use";
      default = pkgs.heartbeat7;
      defaultText = "pkgs.heartbeat7";
      example = "pkgs.heartbeat7";
      type = types.package;
    };

    dataDir = mkOption {
      description = "Heartbeat data directory";
      default = "/var/lib/heartbeat";
      type = types.path;
    };

    extraConf = mkOption {
      description = "Heartbeat extra configuration";
      default = {};
      type = types.attrs;
    };
  };
  cfg = config.services."${serviceName}";
  cfgFile = pkgs.writeText "heartbeat.json" (builtins.toJSON (
    (lib.filterAttrsRecursive (n: v: v != null) ({
      heartbeat.monitors = cfg.monitors;
      output.elasticsearch.hosts = cfg.outputElasticsearch.hosts;
    } // cfg.extraConf)
  )));

in {
  options.services."${serviceName}" = options;

  config = lib.mkIf (cfg.enable) {
    environment.systemPackages = [ cfg.package ];

    users.users."${serviceName}" = {
      description = "Heartbeat user";
      home = cfg.dataDir;
      createHome = true;
    };

    systemd.services."${serviceName}" = {
      description = "Heartbeat";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart =
          "${cfg.package}/bin/heartbeat" +
          " -c ${cfgFile}" +
          " --path.data ${cfg.dataDir}" +
          " -e";
        User = serviceName;
        Restart = "on-failure";
        RestartSec = "10";
        TimeoutStartSec = "3600";
      };
    };
  };
}
