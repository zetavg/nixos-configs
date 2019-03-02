{ lib, ... }:

{
  imports = [
    ../../common/openssh.nix
    ../../common/mosh.nix
  ];
}
