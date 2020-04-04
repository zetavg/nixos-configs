{ lib, ... }:

{
  imports = [
    ../../common/elk
    ../../services/filebeat.nix
    ../../common/filebeat/nginx.nix
    ../../common/filebeat/nginx-passenger.nix
    ../../services/elastic-apm-server.nix
    ../../services/elastic-app-search.nix
  ];

  services.elasticsearch = {
    dataDir = "/home/var/lib/elasticsearch";
    extraJavaOptions = [
      "-Xms128m"
      "-Xmx1024m"
    ];
    extraConf = ''
      cluster.routing.allocation.disk.watermark.low: 4gb
      cluster.routing.allocation.disk.watermark.high: 3gb
      cluster.routing.allocation.disk.watermark.flood_stage: 2gb
    '';
  };

  services.logstash = {
    dataDir = "/home/var/lib/logstash";
  };

  services.kibana = {
    dataDir = "/home/var/lib/kibana";
  };

  services.filebeat = {
    enable = true;
  };

  services.elasticApmServer = {
    enable = true;
  };

  services.elasticAppSearch = {
    enable = true;
    extraJavaOptions = [
      "-Xms16m"
      "-Xmx512m"
    ];
  };
}
