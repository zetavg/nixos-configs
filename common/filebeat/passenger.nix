{ lib, ... }:

{
  imports = [
    ../../services/filebeat.nix
  ];

  services.filebeat = {
    inputs = [
      {
        type = "log";
        enabled = true;
        paths = ["/var/log/passenger.log"];
        fields = {
          type = "passenger";
        };
      }
    ];
  };
}
