{ pkgs, lib, config, ... }:

let
  options = with lib; {
    enable = mkEnableOption "Elastic App Search";

    package = mkOption {
      description = "Elastic App Search package to use";
      default = pkgs.elastic-app-search;
      defaultText = "pkgs.elastic-app-search";
      example = "pkgs.elastic-app-search";
      type = types.package;
    };

    allowEsSettingsModification = mkOption {
      description = "App Search needs one-time permission to alter Elasticsearch settings. Ensure the Elasticsearch settings are correct, then set this to true";
      default = false;
      type = types.bool;
    };

    externalUrl = mkOption {
      description = "Define the exposed URL at which users will reach App Search";
      default = "http://localhost:3002";
      type = types.str;
    };

    listenHost = mkOption {
      description = "Elastic App Search listening host";
      default = "127.0.0.1";
      type = types.str;
    };

    listenPort = mkOption {
      description = "Elastic App Search listening port";
      default = 3002;
      type = types.int;
    };

    dataDir = mkOption {
      description = "Elastic App Search data directory";
      default = "/var/lib/elastic-app-search";
      type = types.path;
    };

    logDir = mkOption {
      description = "Choose your log export path";
      default = "${cfg.dataDir}/logs";
      type = types.path;
    };

    logLevel = mkOption {
      description = "Log level can be: debug, info, warn, error, fatal, or unknown";
      default = "info";
      type = types.str;
    };

    logFormat = mkOption {
      description = "Log format can be: default, json";
      default = "default";
      type = types.str;
    };

    filebeatLogDir = mkOption {
      description = "Choose your Filebeat logs export path";
      default = "${cfg.dataDir}/logs/filebeat";
      type = types.path;
    };

    logRotationKeepFiles = mkOption {
      description = "The number of files to keep on disk when rotating logs, no rotation will take place when set to 0";
      default = 10;
      type = types.int;
    };

    extraJavaOptions = mkOption {
      description = "Extra Java options";
      default = [ "-Xms2g" "-Xmx2g" ];
      type = types.listOf types.str;
    };

    extraConf = mkOption {
      description = "Elastic App Search extra configuration";
      default = {};
      type = types.attrs;
    };

    extraEnv = mkOption {
      description = "Elastic App Search extra env";
      default = "";
      type = types.str;
    };
  };

  cfg = config.services.elasticAppSearch;

  cfgFile = pkgs.writeText "app-search.yml" (pkgs.lib.toYaml (
    (lib.filterAttrsRecursive (n: v: v != null) ({
      allow_es_settings_modification = cfg.allowEsSettingsModification;

      app_search.external_url = cfg.externalUrl;
      app_search.listen_host = cfg.listenHost;
      app_search.listen_port = cfg.listenPort;

      log_directory = cfg.logDir;
      log_level = cfg.logLevel;
      log_format = cfg.logFormat;
      filebeat_log_directory = cfg.filebeatLogDir;
      log_rotation.keep_files = cfg.logRotationKeepFiles;

    } // cfg.extraConf)
  )));

  envFile = pkgs.writeText "env.sh" ''
    export JAVA_OPTS=''${JAVA_OPTS:-"${builtins.concatStringsSep " " cfg.extraJavaOptions}"}
    export APP_SERVER_JAVA_OPTS=''${APP_SERVER_JAVA_OPTS:-$JAVA_OPTS}
  '' + cfg.extraEnv;

  configDir = pkgs.linkFarm "elastic-app-search-config" [
    { name = "app-search.yml"; path = cfgFile; }
    { name = "env.sh"; path = envFile; }
  ];

in {
  options.services.elasticAppSearch = options;

  config = lib.mkIf (cfg.enable) {
    environment.systemPackages = [ cfg.package ];

    users.users."elastic-app-search" = {
      description = "Elastic App Search user";
      home = cfg.dataDir;
      createHome = true;
    };

    systemd.services.elastic-app-search = {
      description = "Elastic App Search";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "elasticsearch.service" ];
      environment = {
        APP_SEARCH_CONFIG_DIR = configDir;
        APP_SEARCH_FILEBEAT_DIR = "${cfg.dataDir}/filebeat";
      };
      preStart = ''
        test -d ${cfg.dataDir} || mkdir -m 750 -p ${cfg.dataDir}
        test `stat -c %a ${cfg.dataDir}` = "750" || chmod 750 ${cfg.dataDir}
        chown -R elastic-app-search ${cfg.dataDir}

        test -d ${cfg.logDir} || mkdir -m 750 -p ${cfg.logDir}
        test `stat -c %a ${cfg.logDir}` = "750" || chmod 750 ${cfg.logDir}
        chown -R elastic-app-search ${cfg.logDir}

        test -d ${cfg.filebeatLogDir} || mkdir -m 750 -p ${cfg.filebeatLogDir}
        test `stat -c %a ${cfg.filebeatLogDir}` = "750" || chmod 750 ${cfg.filebeatLogDir}
        chown -R elastic-app-search ${cfg.filebeatLogDir}
      '';
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/app-search";
        User = "elastic-app-search";
      };
    };
  };
}
