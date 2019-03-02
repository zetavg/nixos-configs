{ config, pkgs, lib, ... }:

{
  imports = [
    ../../common/zsh.nix
    ../../common/users.nix
  ];

  users.users.z.hashedPassword = "$6$fo3UzQiZE9RqlPeD$CNdw/X2RWwfc114kXbdJMXzY.YeIAIU6SAHcY4V1xmCDYXRbceDqo5d2tX8dn22.M43c0FOnzCyf7knz4NjYs1";

  users.users.test = {
    isNormalUser = true;
    uid = 9999;
    home = "/home/test";
    hashedPassword = "$6$ubSsx9x7Ks9iOCQz$pJHLYDlYhz4VOEGcMACxgg5bdiWJ1TyqnlxCefepF.pVGgG6PUcU5hDSjJJbHHuvvy1tejD/rEC6w4m10rjV9.";
  };
}
