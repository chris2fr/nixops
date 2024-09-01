{ config, pkgs, lib, ... }:
let 
in
{ 
  services.nginx.virtualHosts = {
      "guichet.lesgrandsvoisins.com" = {
        serverAliases = ["app.lesgrandsvoisins.com"];
        globalRedirect = "guichet.resdigita.com";
        enableACME = true; 
        forceSSL = true;    
      };
      "guichet.resdigita.com" = {
        serverAliases = ["guichet.gv.coop" "guichet.lesgv.org"];
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
      # "base.mann.fr" = {
      #   root = "/home/guichet/";
      # };
      "newguichet.resdigita.com" = {
        serverAliases = ["guichet.gv.coop" "guichet.lesgv.org"];
        enableACME = true; 
        forceSSL = true;     
        # sslCertificate = "/var/lib/acme/guichet.lesgrandsvoisins.com/fullchain.pem";
        # sslCertificateKey = "/var/lib/acme/guichet.lesgrandsvoisins.com/key.pem";
        # sslTrustedCertificate = "/var/lib/acme/guichet.lesgrandsvoisins.com/fullchain.pem";
        root = "/var/www/guichet";
        locations."/" = {
          proxyPass = "http://[::1]:9992/";
          # proxyPass = "https://guichet.lesgrandsvoisins.com";
        };
        locations."/favicon.ico" = { proxyPass = null; };
        locations."/static" = { proxyPass = null; };
        locations."/media" = { proxyPass = null; };
        locations."/.well-known" = { proxyPass = null; };
      };
  };
}