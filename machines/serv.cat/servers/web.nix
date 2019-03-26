{ pkgs, ... }:

{
  imports = [
    ../../../common/nginx-with-passenger.nix
  ];

  services.nginx = {
    enable = true;

    # A sample proxy-pass server
    virtualHosts."3039.port.serv.cat" = {
      serverAliases = [
        "port-3039.serv.cat"
      ];
      enableACME = true;
      forceSSL = true; # Use addSSL = true; to enable SSL without force
      locations."/" = {
        proxyPass = "http://localhost:3039";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Ssl on; # Optional
          proxy_set_header X-Forwarded-Port $server_port;
          proxy_set_header X-Forwarded-Host $host;
        '';
      };
    };

    # A sample Rails app with Action Cable
    virtualHosts."rails.sample.serv.cat" = let
      mkSampleRailsAppDrv = import (pkgs.fetchFromGitHub {
        owner = "zetavg";
        repo = "rails-nix-sample";
        rev = "e64d8181396d92e62862f11fea540c0a68803315";
        sha256 = "10m4b9by7lzqgfjnjng0fhrqlpmn7iy1banyjm9hpylqbqz76d4k";
      });
      app = mkSampleRailsAppDrv {
        actionCableConfig = {
          adapter = "redis";
          url = "redis://localhost:6379/31";
          channel_prefix = "${app.name}-cable";
        };
      };
    in {
      serverAliases = [
        "rails-sample.serv.cat"
      ];
      enableACME = true;
      forceSSL = true; # Use addSSL = true; to enable SSL without force
      root = "${app}/public";
      extraConfig = ''
        passenger_enabled on;
        passenger_sticky_sessions on;
        passenger_ruby ${app.ruby}/bin/ruby;
        passenger_env_var GEM_HOME ${app.gemHome};
        passenger_env_var BUNDLE_GEMFILE ${app.bundleGemfile};
        passenger_env_var BUNDLE_PATH ${app.bundlePath};
        location /cable {
          passenger_app_group_name ${app.name}_action_cable;
          passenger_force_max_concurrent_requests_per_process 0;
        }
      '';
    };
  };
}
