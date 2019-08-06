{ ... }:

{
  imports = [
    ../../common/elk.nix
    ../../services/elastic-apm-server.nix
  ];

  services.elasticsearch = {
    dataDir = "/home/var/lib/elasticsearch";
    extraJavaOptions = [ "-Xms128m" "-Xmx800m" ];
  };

  services.elasticApmServer = {
    enable = true;
  };
}
