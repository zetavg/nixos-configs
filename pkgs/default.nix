let
  src = (import <nixpkgs> { }).fetchFromGitHub {
    owner = "zetavg";
    repo = "nix-packages";
    rev = "a1078f6795ed3f5cd0ae29c86acbd6ca58107ee0";
    sha256 = "0r1khcrbfdlpgv8w710mr1rnzdw89177r8hp3x86dfx5wp5gdnbd";
  };
in import src
