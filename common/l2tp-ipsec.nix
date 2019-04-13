/*
 * VPN Server
 */

{ pkgs, lib, ... }:

{
  boot.kernel.sysctl."net.ipv4.ip_forward" = "1";

  environment.systemPackages = with pkgs; lib.mkAfter [
    xl2tpd strongswan
  ];

  networking.nat = {
    enable = true;
    externalInterface = "eth0";
    internalInterfaces = lib.mkAfter [ "ppp0" ];
    internalIPs = lib.mkAfter [ "10.125.125.0/24" ];
    # Hack: The script below is for configuring ppp to authenticate all login users,
    #       since options provided by services.xl2tpd cannot do this, we place it
    #       here as extraCommands of networking.nat.
    # Ref: https://git.io/fhAQ5
    extraCommands = lib.mkAfter ''
      mkdir -p -m 700 /etc/xl2tpd

      pushd /etc/xl2tpd > /dev/null

      mkdir -p -m 700 ppp

      cat > ppp/pap-secrets << EOF
      # Secrets for authentication using pap
      # client  server  secret  IP addresses
        *       *       ""      *
      EOF

      chown root.root ppp/pap-secrets
      chmod 600 ppp/pap-secrets

      popd > /dev/null
    '';
  };

  # Set this in a separate file, by machine basis:
  # services.strongswan.secrets = [ "/home/etc/ipsec.secrets" ];

  services.xl2tpd = {
    enable = true;
    serverIp = "10.125.125.1";
    clientIpRange = "10.125.125.2-254";
    # Hack: Overriding the whole pppoptfile to get rid of "require-mschap-v2",
    #       which will disable "require-pap".
    extraXl2tpOptions = ''
      unix authentication = yes
      pppoptfile = ${pkgs.writeText "ppp-options-xl2tpd.conf" ''
        refuse-pap
        refuse-chap
        refuse-mschap
        # require-mschap-v2
        # require-mppe-128
        asyncmap 0
        auth
        crtscts
        idle 1800
        mtu 1200
        mru 1200
        lock
        hide-password
        local
        # debug
        name xl2tpd
        # proxyarp
        lcp-echo-interval 30
        lcp-echo-failure 4

        # Extra:
        require-pap
        login

        ms-dns 8.8.8.8
        ms-dns 8.8.4.4

        modem
        proxyarp
      ''}
    '';
    # extraPppdOptions = ''
    #   refuse-mschap-v2
    #   require-pap
    #   login

    #   ms-dns 8.8.8.8
    #   ms-dns 8.8.4.4

    #   modem
    #   proxyarp
    # '';
  };

  services.strongswan = {
    enable = true;
    connections = {
      "%default" = {
        ikelifetime = "1h";
        keylife = "30m";
        rekeymargin = "5m";
        keyingtries = "3";
      };
      "l2tp" = {
        keyexchange = "ikev1";
        left = "%SERVERIP%";
        leftsubnet = "0.0.0.0/0";
        leftprotoport = "17/1701";
        authby = "secret";
        right = "%any";
        type = "transport";
        auto = "add";
      };
    };
  };
}
