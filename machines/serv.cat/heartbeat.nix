{ lib, ... }:

{
  imports = [
    ../../common/heartbeat.nix
  ];

  services.heartbeat7.monitors = lib.mkBefore [
    {
      name = "Kibana";
      type = "http";
      urls = "http://localhost:5601/api/status";
      schedule = "@every 10s";
      check.response = {
        status = 200;
        json = [
          {
            description = "check status (status.overall.state = 'green')";
            condition = { equals = { "status.overall.state" = "green"; }; };
          }
        ];
      };
    }
  ];
}
