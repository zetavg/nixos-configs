{ ... }:

{
  imports = [
    ../../common/bind.nix
  ];

  services.bind.zones = [
    {
      name = "serv.cat";
      master = true;
      file = "/home/var/named/serv.cat";
    }
  ];
}
