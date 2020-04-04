{ lib, config, ... }:

{
  imports = [
    ../../services/filebeat.nix
  ];

  services.filebeat = {
    inputs = [
      {
        type = "log";
        enabled = true;
        paths = ["${config.services.nginx.stateDir}/logs/passenger.log"];
        fields = {
          type = "passenger";
        };
      }
    ];
  };
}
