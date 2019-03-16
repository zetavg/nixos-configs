{ lib, ... }:

{
  fileSystems."/home" = lib.mkDefault {
    device = "/dev/disk/by-label/home";
    autoResize = true;
  };

  swapDevices = lib.mkDefault [
    {
      device = "/home/swapfile";
      size = 2048;
    }
  ];
}
