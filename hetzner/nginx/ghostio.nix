{ config, pkgs, lib, ... }:
let 
in
{ 
  services.nginx.virtualHosts = {
    # "blog.desgrandsvoisins.org" = {
    #   root = "/var/www/ghostio/";
    #   enableACME = true;
    #   forceSSL = true;
    #   serverAliases = ["blog.resdigita.com" "blog.desgrandsvoisins.com"];
    #   globalRedirect = "blog.lesgrandsvoisins.com";
    # };
    "blog.lesgrandsvoisins.com" = {
      serverAliases = ["ghost.lesgv.org"];
      root = "/var/www/ghostio/";
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:2368/";
      };
    };
  };
}