{ config, pkgs, lib, ... }:
let 
in
{ 
  services.nginx.virtualHosts = {
    "doc.desgrandsvoisins.org" = {
      serverAliases = ["resdigita.com" "resdigita.org" "www.resdigita.org" "doc.desgrandsvoisins.com"  "doc.lesgrandsvoisins.com" "doc.resdigita.com"];
       globalRedirect = "quartz.resdigita.com";
      enableACME = true;
      forceSSL = true;
      root = "/var/www/resdigitacom";
    };
    "quartz.resdigita.com" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/resdigitacom";
    };
  };
}