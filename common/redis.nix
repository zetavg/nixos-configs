# In-memory Key-value Data Structure Store
{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; lib.mkAfter [
    redis
  ];

  services.redis = {
    enable = true;
    databases = 64;
  };
}
