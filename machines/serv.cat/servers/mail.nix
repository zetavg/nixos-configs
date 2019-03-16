{ ... }:

{
  imports = [
    ../../../common/postfix.nix
    ../../../common/dovecot.nix
  ];

  services.postfix = {
    hostname = "serv.cat";
    destination = ["serv.cat" "mail.serv.cat" "test.serv.cat"];
    rootAlias = "z";
    virtualMapType = "pcre";
    virtual = ''
      /^.*@test.*$/ test@test.serv.cat
      /^.*@(?!test).*$/ root
    '';
  };

  services.dovecot2 = {
    enablePop3 = true;
    enableImap = true;
  };
}
