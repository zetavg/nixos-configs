{ ... }:

{
  imports = [
    ../../common/transmission.nix
  ];

  services.transmission = {
    home = "/home/transmission";
    settings = {
      rpc-whitelist = "127.0.0.1,192.168.*.*,10.*.*.*";
    };
  };
}
