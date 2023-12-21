{ config, pkgs, lib, ... }:
let 
in
{ 
  services.nginx.virtualHosts = {
      "dav.desgrandsvoisins.org" = {
        serverAliases = ["dav.lesgrandsvoisins.com" "dav.desgrandsvoisins.com"];
        enableACME = true;
        forceSSL = true;
        globalRedirect = "dav.resdigita.com";
      };
      "dav.resdigita.com" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "https://dav.resdigita.com:8443/";
        };
      };
      "secret.desgrandsvoisins.org" = {
        enableACME = true;
        forceSSL = true;
        serverAliases = ["secret.lesgrandsvoisins.com" "secret.desgrandsvoisins.com"];
        globalRedirect = "secret.resdigita.com";
      };
      "secret.resdigita.com" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "https://secret.resdigita.com:8443/";
        };
      };
  };
}