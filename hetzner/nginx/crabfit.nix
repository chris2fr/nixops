{ config, pkgs, lib, ... }:
let 
in
{ 
  services.nginx.virtualHosts = {
    "crabfit.resdigita.com" = {
      serverAliases = [
        "crabfit.gv.coop" 
        "crabfit.lesgv.org"];
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:3080/";
      };
    };
    "crabfit.desgv.com" = {
      enableACME = true;
      forceSSL = true;
      # serverAliases = ["crabfit.desgrandsvoisins.com"];
      globalRedirect = "crabfit.resdigita.com";
      # rencontre-avec-bgeparif-sviatlana-et-dea-ladapt-visio-243095
    };
    "apicrabfit.resdigita.com" = {
      serverAliases = ["apicrabfit.lesgv.org"];
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:3000/";
      };
    };
  };
}