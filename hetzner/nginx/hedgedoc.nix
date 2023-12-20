{ config, pkgs, lib, ... }:
let 
in
{ 
  services.nginx.virtualHosts = {
      "hdoc.desgrandsvoisins.org" = {
        serverAliases = [
          "hedgedoc.lesgrandsvoisins.com"
          "hdoc.lesgv.com"
          "hedgedoc.lesgv.com"
          "hdoc.desgrandsvoisins.com"
          "hdoc.resdigita.com"
          "hdoc.desgv.com"
          "hedgedoc.desgv.com"
          "hdoc.desgrandsvoisins.com"
          "hedgedoc.desgrandsvoisins.com"
          "hdoc.lesgrandsvoisins.com"
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