{ config, pkgs, lib, ... }:
let 
in
{ 
  services.nginx.virtualHosts = {
      "guichet.desgrandsvoisins.org" = {
        serverAliases = ["app.lesgrandsvoisins.com" "guichet.lesgrandsvoisins.com"];
        globalRedirect = "guichet.desgrandsvoisins.com";
        enableACME = true; 
        forceSSL = true;    
      };
      "guichet.desgrandsvoisins.com" = {
        enableACME = true; 
        forceSSL = true;     
        # sslCertificate = "/var/lib/acme/guichet.lesgrandsvoisins.com/fullchain.pem";
        # sslCertificateKey = "/var/lib/acme/guichet.lesgrandsvoisins.com/key.pem";
        # sslTrustedCertificate = "/var/lib/acme/guichet.lesgrandsvoisins.com/fullchain.pem";
        root = "/var/www/guichet";
        locations."/" = {
          proxyPass = "http://[::1]:9991/";
          # proxyPass = "https://guichet.lesgrandsvoisins.com";
        };
        locations."/favicon.ico" = { proxyPass = null; };
        locations."/static" = { proxyPass = null; };
        locations."/media" = { proxyPass = null; };
        locations."/.well-known" = { proxyPass = null; };
      };

  };
}