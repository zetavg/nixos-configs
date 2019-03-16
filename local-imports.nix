let
  paths = [
    ./configuration-local/default.nix
    ./configuration-local.nix
  ];
in
  builtins.filter (path: builtins.pathExists path) paths
