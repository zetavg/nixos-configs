{ ... }:

{
  # This is currently not enabled since the DNS server of the domain serv.cat is Gandi.
  # imports = [
  #   ../../../common/bind.nix
  # ];

  # services.bind.zones = [
  #   {
  #     name = "serv.cat";
  #     master = true;
  #     file = "/home/var/named/serv.cat";
  #   }
  # ];
}
