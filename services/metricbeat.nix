{ pkgs, lib, config, ... }:

with lib;

let
  serviceName = "metricbeat";

  # TODO: There're more options and configs!
  # See https://github.com/elastic/beats/blob/master/metricbeat/metricbeat.reference.yml
  # and https://github.com/elastic/beats/tree/master/metricbeat/modules.d
  options = {
    enable = mkEnableOption "Metricbeat";

    modules = mkOption {
      description = "Metricbeat modules config, see https://www.elastic.co/guide/en/beats/metricbeat/7.0/metricbeat-reference-yml.html";
      default = ''
        - module: system
          metricsets:
            - cpu             # CPU usage
            - load            # CPU load averages
            - memory          # Memory usage
            - network         # Network IO
            #- process         # Per process metrics # Takes up too much space - https://d.pr/i/pHkQZ5
            - process_summary # Process summary
            - uptime          # System Uptime
            - socket_summary  # Socket summary
            - core            # Per CPU core usage
            - diskio          # Disk IO
            #- filesystem      # File system usage for each mountpoint
            #- fsstat         # File system summary metrics
            #- raid           # Raid
            #- socket         # Sockets and connection info (linux only)
          enabled: true
          period: 10s
          processes: ['.*']

          # Configure the metric types that are included by these metricsets.
          cpu.metrics:  ["percentages"]  # The other available options are normalized_percentages and ticks.
          core.metrics: ["percentages"]  # The other available option is ticks.

        - module: system
          metricsets:
            - process
          enabled: true
          period: 60s
          processes: ['.*']
          # These options allow you to filter out all processes that are not
          # in the top N by CPU or memory, in order to reduce the number of documents created.
          # If both the `by_cpu` and `by_memory` options are used, the union of the two sets
          # is included.
          process.include_top_n:
            # Set to false to disable this feature and include all processes
            enabled: true
            # How many processes to include from the top by CPU. The processes are sorted
            # by the `system.process.cpu.total.pct` field.
            by_cpu: 32
            # How many processes to include from the top by memory. The processes are sorted
            # by the `system.process.memory.rss.bytes` field.
            by_memory: 32

        - module: system
          metricsets:
            - filesystem
          enabled: true
          period: 30s

        - module: system
          metricsets:
            - fsstat
          enabled: true
          period: 30s
      '';
      type = types.str;
    };

    outputElasticsearch = {
      hosts = mkOption {
        default = ["localhost:9200"];
        type = types.nullOr (types.listOf types.str);
      };
    };

    package = mkOption {
      description = "Metricbeat package to use";
      default = pkgs.metricbeat7;
      defaultText = "pkgs.metricbeat7";
      example = "pkgs.metricbeat7";
      type = types.package;
    };

    dataDir = mkOption {
      description = "Metricbeat data directory";
      default = "/var/lib/metricbeat";
      type = types.path;
    };

    extraConf = mkOption {
      description = "Metricbeat extra configuration";
      default = {};
      type = types.attrs;
    };
  };
  cfg = config.services."${serviceName}";
  modulesFile = pkgs.writeText "metricbeat-modules.yml" cfg.modules;
  cfgFile = pkgs.writeText "metricbeat.json" (builtins.toJSON (
    (lib.filterAttrsRecursive (n: v: v != null) ({
      metricbeat.config.modules = {
        path = modulesFile;
        reload.enabled = false;
      };
      output.elasticsearch.hosts = cfg.outputElasticsearch.hosts;

    } // cfg.extraConf)
  )));

in {
  options.services."${serviceName}" = options;

  config = lib.mkIf (cfg.enable) {
    environment.systemPackages = [ cfg.package ];

    users.users."${serviceName}" = {
      description = "Metricbeat user";
      home = cfg.dataDir;
      createHome = true;
    };

    systemd.services."${serviceName}" = {
      description = "Metricbeat";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart =
          "${cfg.package}/bin/metricbeat" +
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
