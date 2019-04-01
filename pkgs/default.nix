let
  src = (import <nixpkgs> { }).fetchFromGitHub {
    owner = "zetavg";
    repo = "nix-packages";
    rev = "09993f5abf7ea7b07b4f24eec7dab6ddd33f0cef";
    sha256 = "0ca1mnbc378bl0xln71fp3m9sv29ik1yac108mhry1lir287n0mf";
  };
in import src
