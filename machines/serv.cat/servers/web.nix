{ ... }:

{
  imports = [
    ../../../common/nginx-with-passenger.nix
  ];

  services.nginx = {
    enable = true;

    # A sample Rails app with Action Cable
    virtualHosts."rails.sample.serv.cat" = let
      pkgs = import ../../../pkgs { };
      app = pkgs.sample-rails-app.override {
        actionCable = {
          adapter = "redis";
          url = "redis://localhost:6379/31";
          channel_prefix = "${app.name}-cable";
        };
      };
    in {
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
