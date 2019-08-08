# TODO: This depends on zpkgs and should be moved to nix-packages?

{ pkgs, lib, config, ... }:

with lib;

let

  cfg = config.services.elasticApmServer;

  cfgFile = pkgs.writeText "apm-server.json" (builtins.toJSON (
    (lib.filterAttrsRecursive (n: v: v != null) ({
      apm-server.host = "${cfg.listenAddress}:${builtins.toString cfg.port}";
      apm-server.secret_token = cfg.secretToken;

      output.elasticsearch.hosts = cfg.outputElasticsearch.hosts;

      # TODO: There're more configs!
      # See https://gist.github.com/6f52d851648507cc114d74805b778711
    } // cfg.extraConf)
  )));


in {
  options.services.elasticApmServer = {
    enable = mkEnableOption "Elastic APM Server";

    listenAddress = mkOption {
      description = "Elastic APM Server listening host";
      default = "127.0.0.1";
      type = types.str;
    };

    port = mkOption {
      description = "Elastic APM Server listening port";
      default = 8200;
      type = types.int;
    };

    secretToken = mkOption {
      description = "Authorization token to be checked";
      default = null;
      type = types.nullOr types.str;
    };

    outputElasticsearch = {
      hosts = mkOption {
        default = ["localhost:9200"];
        type = types.nullOr (types.listOf types.str);
      };
    };

    package = mkOption {
      description = "Elastic APM Server package to use";
      default = pkgs.elastic-apm-server;
      defaultText = "pkgs.elastic-apm-server";
      example = "pkgs.elastic-apm-server";
      type = types.package;
    };

    dataDir = mkOption {
      description = "Kibana data directory";
      default = "/var/lib/elastic-apm-server";
      type = types.path;
    };

    extraConf = mkOption {
      description = "Elastic APM Server extra configuration";
      default = {};
      type = types.attrs;
    };
  };

  config = lib.mkIf (cfg.enable) {
    environment.systemPackages = [ cfg.package ];

    users.users = singleton {
      name = "elastic-apm-server";
      uid = 216;
      description = "Elastic APM Server user";
      home = cfg.dataDir;
      createHome = true;
    };

    systemd.services.elastic-apm-server = {
      description = "Elastic APM Server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "elasticsearch.service" ];
      serviceConfig = {
        ExecStart =
          "${cfg.package}/bin/apm-server" +
          " -c ${cfgFile}" +
          " --path.data ${cfg.dataDir}" +
          " -e";
        User = "elastic-apm-server";
      };
    };
  };
}
