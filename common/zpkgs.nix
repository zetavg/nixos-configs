/*
 * Package Collection At https://github.com/zetavg/nix-packages, a.k.a. zpkgs
 */

{ pkgs, config, options, ... }:

let
  # TODO: Make a option to select this
  zpkgs-source = builtins.fetchGit {
    url = "https://github.com/zetavg/nix-packages.git";
    ref = "master";
    # Get the latest commit rev on
    # https://github.com/zetavg/nix-packages/commits/master
    rev = "aca64f412ab2b7a9d3809def7d2423d78cf63871";
  };
in {
  # Use the package collection as an overlay of nixpkgs
  nixpkgs.overlays =
    (options.nixpkgs.overlays.default or [ ]) ++
    (import "${zpkgs-source}/manifest.nix");

  # Also apply the zpkgs overlay to users under the system
  # See:
  #  - http://bit.ly/using-overlays-from-config-as-nixpkgs-overlays-in-NIX_PATH
  #  - http://bit.ly/overlays-compat-in-zpkgs
  # TODO: Make a option to disable this
  nix.nixPath = with pkgs;
    (options.nix.nixPath.default or [ ]) ++
    [ "nixpkgs-overlays=${overlays-compat}/" ]
  ;

  nix.useSandbox = false;

  # Add binary cache servers for zpkgs
  nix.binaryCaches = (options.nix.binaryCaches.default or [ ]) ++ [
    https://zetavg.cachix.org/
  ];
  nix.binaryCachePublicKeys = (options.nix.binaryCachePublicKeys.default or [ ]) ++ [
    "zetavg.cachix.org-1:Sj61CXglgN8FnXEipp0T3WXTrgrnkwv2fIW/krLIT7Q="
  ];
}
