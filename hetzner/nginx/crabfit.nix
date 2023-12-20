{ config, pkgs, lib, ... }:
let 
in
{ 
  services.nginx.virtualHosts = {
      "crabfit.resdigita.com" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:3080/";
        };
        locations."/api" = {
          proxyPass = "http://localhost:3000/";
        };
      };
      "crabfit.desgv.com" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:3080/";
        };
        locations."/api" = {
          proxyPass = "http://localhost:3000/";
        };
      };
      "crabfit.desgrandsvoisins.com" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:3080/";
        };
        locations."/api" = {
          proxyPass = "http://localhost:3000/";
        };
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