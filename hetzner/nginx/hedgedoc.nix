{ config, pkgs, lib, ... }:
let 
in
{ 
  services.nginx.virtualHosts = {
      "hdoc.desgrandsvoisins.org" = {
        enableACME = true;
        forceSSL = true;
        serverAliases = [
          "hdoc.desgrandsvoisins.com"
          "hdoc.desgv.com"
          "hdoc.lesgrandsvoisins.com"
          "hdoc.lesgv.com"
          "hdoc.resdigita.com"
          "hedgedoc.desgrandsvoisins.com"
          "hedgedoc.desgv.com"
          "hedgedoc.lesgrandsvoisins.com"
          "hedgedoc.lesgv.com"
          "hedgedoc.gv.coop"
        ];
        globalRedirect = "hedgedoc.resdigita.com";
      };
      "hedgedoc.resdigita.com" = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://localhost:3333/";
      };
  };
}