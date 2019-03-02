{ ... }:

{
  imports = [
    ../../common/transmission.nix
  ];

  services.transmission = {
    home = "/home/transmission";
  };
}
