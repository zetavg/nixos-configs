{ pkgs, lib, config, ... }:

with lib;

let
  serviceName = "filebeat";
  # TODO: There're more options and configs!
  # See https://github.com/elastic/beats/blob/master/filebeat/filebeat.yml
  options = {
    enable = mkEnableOption "Filebeat";

    inputs = mkOption {
      default = [];
      example = literalExample ''
        [{ type = "log"; enabled = true; paths = "/var/log/*.log"; }]
      '';
      type = types.nullOr (types.listOf (types.submodule {
        options = {
          type = mkOption {
            type = types.str;
            default = "log";
          };
          enabled = mkOption {
            type = types.bool;
            default = true;
          };
          paths = mkOption {
            type = types.listOf types.str;
            default = [];
          };
          fields = mkOption {
            type = types.nullOr types.attrs;
            default = null;
          };
        };
      }));
    };

    outputLogstash = {
      hosts = mkOption {
        default = ["localhost:5044"];
        type = types.nullOr (types.listOf types.str);
      };
    };

    package = mkOption {
      description = "Filebeat package to use";
      default = pkgs.filebeat7;
      defaultText = "pkgs.filebeat7";
      example = "pkgs.filebeat7";
      type = types.package;
    };

    dataDir = mkOption {
      description = "Filebeat data directory";
      default = "/var/lib/filebeat";
      type = types.path;
    };

    extraConf = mkOption {
      description = "Filebeat extra configuration";
      default = {};
      type = types.attrs;
    };
  };
  cfg = config.services."${serviceName}";
  cfgFile = pkgs.writeText "filebeat.json" (builtins.toJSON (
    (lib.filterAttrsRecursive (n: v: v != null) ({
      filebeat.inputs = cfg.inputs;
      output.logstash.hosts = cfg.outputLogstash.hosts;

    } // cfg.extraConf)
  )));

in {
  options.services."${serviceName}" = options;

  config = lib.mkIf (cfg.enable) {
    environment.systemPackages = [ cfg.package ];

    users.users = singleton {
      name = serviceName;
      description = "Filebeat user";
      # Need permission to read Nginx logs.
      # TODO: Make this configurable?
      extraGroups = [ "nginx" ];
      home = cfg.dataDir;
      createHome = true;
    };

    systemd.services."${serviceName}" = {
      description = "Filebeat";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart =
          "${cfg.package}/bin/filebeat" +
          " -c ${cfgFile}" +
          " --path.data ${cfg.dataDir}" +
          " -e";
        User = serviceName;
      };
    };
  };
}
