{ config, pkgs, lib, ... }:
let 
in
{ 
  services.nginx.virtualHosts = {
      "dav.desgrandsvoisins.org" = {
        enableACME = true;
        forceSSL = true;
        globalRedirect = "dav.desgrandsvoisins.com";
      };
      "dav.lesgrandsvoisins.com" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "https://dav.lesgrandsvoisins.com:8443/";
        };
      };
      "dav.desgrandsvoisins.com" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "https://dav.desgrandsvoisins.com:8443/";
        };
      };
      "secret.desgrandsvoisins.org" = {
        enableACME = true;
        forceSSL = true;
        globalRedirect = "secret.desgrandsvoisins.com";
      };
      "secret.lesgrandsvoisins.com" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "https://secret.lesgrandsvoisins.com:8443/";
        };
      };
      "secret.desgrandsvoisins.com" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "https://secret.desgrandsvoisins.com:8443/";
        };
      };
  };
}