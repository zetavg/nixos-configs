{ ... }:

{
  fileSystems."/home" = {
    device = "/dev/disk/by-label/home";
    autoResize = true;
  };

  swapDevices = [
    {
      device = "/home/swapfile";
      size = 2048;
    }
  ];
}
