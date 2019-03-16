{ ... }:

{
  imports = [
    ../../../common/l2tp-ipsec.nix
  ];

  services.strongswan.secrets = [ "/home/etc/ipsec.secrets" ];
}
