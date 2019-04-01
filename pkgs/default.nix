let
  src = (import <nixpkgs> { }).fetchFromGitHub {
    owner = "zetavg";
    repo = "nix-packages";
    rev = "357a51ab14ed1f9fd5f0ff19f1560f4a1f02d5fc";
    sha256 = "0bhkx9sagwssx9daxnh2bcvjvjqdynvbyfmhnz2pzmxpdylri95q";
  };
in import src
