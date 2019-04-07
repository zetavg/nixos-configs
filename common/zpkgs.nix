/*
 * Package Collection At https://github.com/zetavg/nix-packages, a.k.a. zpkgs
 */

{ pkgs, config, options, ... }:


let
  # TODO: Make a option to select this
  zpkgs-source = builtins.fetchGit {
    url = "https://github.com/zetavg/nix-packages.git";
    ref = "master";
  };
  overlays-compat = let
    nixosExpectedSystem =
      if config.nixpkgs.crossSystem != null
      then config.nixpkgs.crossSystem.system
      else config.nixpkgs.localSystem.system;
  in with pkgs; derivation {
    name = "overlays-compat";
    system = nixosExpectedSystem;
    builder = "${bash}/bin/bash";
    args = [
      "-c"
      ''
        ${coreutils}/bin/mkdir -p $out && \
        echo "$src" > "$out/overlays.nix"
      ''
    ];
    src = ''
      self: super:
      with super.lib; let
        # Using the nixos plumbing that's used to evaluate the config...
        eval = import <nixpkgs/nixos/lib/eval-config.nix>;
        # Evaluate the config,
        paths = (eval {modules = [(import <nixos-config>)];})
          # then get the `nixpkgs.overlays` option.
          .config.nixpkgs.overlays
        ;
      in
      foldl' (flip extends) (_: super) paths self
    '';
  };
in {
  # Use the package collection as an overlay of nixpkgs
  nixpkgs.overlays =
    (options.nixpkgs.overlays.default or [ ]) ++
    (import "${zpkgs-source}/manifest.nix");

  # Also apply the zpkgs overlay to users under the system
  # http://bit.ly/using-overlays-from-config-as-nixpkgs-overlays-in-NIX_PATH
  # TODO: Make a option to disable this
  nix.nixPath =
    (options.nix.nixPath.default or [ ]) ++
    [ "nixpkgs-overlays=${overlays-compat}/" ]
  ;

  # Add binary cache servers for zpkgs
  nix.binaryCaches = (options.nix.binaryCaches.default or [ ]) ++ [
    https://zetavg.cachix.org/
  ];
  nix.binaryCachePublicKeys = (options.nix.binaryCachePublicKeys.default or [ ]) ++ [
    "zetavg.cachix.org-1:Sj61CXglgN8FnXEipp0T3WXTrgrnkwv2fIW/krLIT7Q="
  ];
}
