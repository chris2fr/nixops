{ config, pkgs, lib, ... }:
let 
in
{ 
  services.nginx.virtualHosts = {
    "crabfit.resdigita.com" = {
      enableACME = true;
      locations."/" = {
        proxyPass = "http://localhost:3080/";
      };
    };
    "crabfit.desgv.com" = {
      enableACME = true;
      forceSSL = true;
      serverAliases = ["crabfit.desgrandsvoisins.com"];
      globalRedirect = "crabfit.resdigita.com";
    };
    "apicrabfit.resdigita.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:3000/";
      };
    };
  };
}