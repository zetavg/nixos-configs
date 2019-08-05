{ ... }:

{
  imports = [
    ../../common/elk.nix
  ];

  services.elasticsearch = {
    dataDir = "/home/var/lib/elasticsearch";
  };
}
