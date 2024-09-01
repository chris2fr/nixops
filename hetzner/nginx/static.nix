{ config, pkgs, lib, ... }:
let 
in
{ 
  services.nginx.virtualHosts = {
    "doc.lesgrandsvoisins.com" = {
      # serverAliases = ["resdigita.org" "www.resdigita.org" "doc.desgrandsvoisins.com"  "doc.lesgrandsvoisins.com" "doc.resdigita.com"];
      serverAliases = ["doc.resdigita.com"];
       globalRedirect = "quartz.resdigita.com";
      enableACME = true;
      forceSSL = true;
      root = "/var/www/resdigitacom";
    };
    "quartz.resdigita.com" = {
      serverAliases = [
        "quartz.gv.coop" 
        "quartz.lesgv.org"];
      enableACME = true;
      forceSSL = true;
      root = "/var/www/resdigitacom";
    };
  };
}