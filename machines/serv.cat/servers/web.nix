{ pkgs, ... }:

{
  imports = [
    ../../../common/nginx-with-passenger.nix
  ];

  services.nginx = {
    enable = true;

    # Neofetch as server nameplate,
    # also a sample Node.js app
    virtualHosts."serv.cat" = let
      # To use the source code from git, write:
      # mkNeofetchWeb = import (builtins.fetchGit {
      #   url = "https://github.com/zetavg/neofetch-web.git";
      #   ref = "master";
      #   rev = "c6f3eee3fd8d7a688081e6b13c5c087a5ec66499";
      # });
      # app = mkNeofetchWeb {
      #   ...
      # };
      app = pkgs.neofetch-web.override {
        neofetchConfigFile = pkgs.writeText "neofetch-web.config" ''
          # See this wiki page for more info:
          # https://github.com/dylanaraps/neofetch/wiki/Customizing-Info
          print_info() {
            info title
            info underline
            info "OS" distro
            info "Host" model
            info "Kernel" kernel
            info "Uptime" uptime
            prin "Load Average" "$(uptime | awk -F' *,? *' '{print $(NF-2), $(NF-1), $NF}')"
            info "Packages" packages
            info "CPU" cpu
            info "CPU Usage" cpu_usage
            info "Memory" memory
            info "Disk" disk
            prin "System Time" "$(date)"

            prin
            info cols
          }
          distro_shorthand="on"
          os_arch="on"
          uptime_shorthand="on"
          memory_percent="on"
          package_managers="on"
          cpu_temp="C"
          gpu_brand="on"
          gpu_type="all"
          disk_show=('/' '/home')
          disk_subtitle="mount"
        '';
      };
    in {
      serverAliases = [
        "neofetch.serv.cat"
      ];
      enableACME = true;
      forceSSL = true; # Use addSSL = true; to enable SSL without force
      root = app.publicRoot;
      extraConfig = app.getNginxPassengerConfig {
        passenger = pkgs.nginx-with-passenger.passenger;
      };
    };

    # A sample Rails app with Action Cable
    virtualHosts."rails.sample.serv.cat" = let
      # To use the source code from git, write:
      # mkSampleRailsApp = import (builtins.fetchGit {
      #   url = "https://github.com/zetavg/rails-nix-sample.git";
      #   ref = "master";
      #   rev = "22b727b95ea7c9e5eca013a794e0d526caa7f4d5";
      # });
      # app = mkSampleRailsApp {
      #   ...
      # };
      app = pkgs.sample-rails-app.override {
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
      root = app.publicRoot;
      extraConfig = app.nginxPassengerConfig;
    };

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
  };
}
