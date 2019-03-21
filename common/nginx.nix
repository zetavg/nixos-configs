{ pkgs, lib, ... }:

let
  customPkgs = import ../pkgs { };
  nginx = pkgs.nginx.override {
    modules = [ "${customPkgs.passenger}/src/nginx_module" ];
  };
in {
  environment.systemPackages = with pkgs; lib.mkAfter [
    nginx
  ];

  services.nginx.enable = true;
}
