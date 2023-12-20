{ config, pkgs, lib, ... }:
let 
in
{ 
  services.nginx.virtualHosts = {
      "hdoc.lesgrandsvoisins.com" = {
        serverAliases = [
          "hedgedoc.lesgrandsvoisins.com"
          "hdoc.lesgv.com"
          "hedgedoc.lesgv.com"
          "hdoc.desgrandsvoisins.org"
          "hedgedoc.resdigita.com"
          "hdoc.resdigita.com"
          "hdoc.desgv.com"
          "hedgedoc.desgv.com"
          "hdoc.desgrandsvoisins.com"
          "hedgedoc.desgrandsvoisins.com"
        ];
        enableACME = true;
        locations."/".proxyPass = "http://localhost:3333/";
        forceSSL = true;
      };

  };
}