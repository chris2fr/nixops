{ config, pkgs, lib, ... }:
let 
in
{ 
  services.nginx.virtualHosts = {
      "blog.desgrandsvoisins.org" = {
        root = "/var/www/ghostio/";
        enableACME = true;
        forceSSL = true;
        serverAliases = ["blog.resdigita.com" "blog.lesgrandsvoisins.com"];
        globalRedirect = "blog.desgrandsvoisins.com";
      };
      "blog.desgrandsvoisins.com" = {
        root = "/var/www/ghostio/";
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:2368/";
        };
      };

  };
}