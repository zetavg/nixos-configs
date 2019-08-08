{ lib, ... }:

{
  imports = [
    ../../common/elk.nix
    ../../services/filebeat.nix
    ../../common/filebeat/nginx.nix
    ../../common/filebeat/passenger.nix
    ../../services/elastic-apm-server.nix
  ];

  services.elasticsearch = {
    dataDir = "/home/var/lib/elasticsearch";
    extraJavaOptions = [ "-Xms128m" "-Xmx800m" ];
  };

  services.filebeat = {
    enable = true;
  };

  services.elasticApmServer = {
    enable = true;
  };
}
