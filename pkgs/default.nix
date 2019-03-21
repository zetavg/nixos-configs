{ ... }:

let
  nixpkgs = import <nixpkgs> { };
  callPackage = nixpkgs.lib.callPackageWith (nixpkgs // pkgs);
  pkgs = rec {
    passenger = callPackage ./servers/passenger { };
    nginx-mod-passenger = callPackage ./servers/nginx-mod-passenger.nix { };
    nginx-with-passenger = callPackage ./servers/nginx-with-passenger.nix { };
    sample-rails-app = callPackage ./samples/rails-app { };
  };
in pkgs
