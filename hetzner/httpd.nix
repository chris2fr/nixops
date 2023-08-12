  { config, pkgs, lib, ... }:

let 
in
{ 
  nix.settings.experimental-features = "nix-command flakes";
  users.users.mannchri.extraGroups = [ "wwwrun" ];
  services.httpd.enable = true;
  services.httpd.enablePHP = false;
  services.httpd.adminAddr = "contact@gvois.in";
  services.httpd.extraModules = [ "proxy" "proxy_http" ];
  users.users.wwwrun.extraGroups = [ "acme" "wagtail" ];
  services.httpd.virtualHosts."gvois.in" = {
    enableACME = true;
    forceSSL = true;
    globalRedirect = "https://www.gvois.in/";
  };
  services.httpd.virtualHosts."guichet.gvois.in" = {
    enableACME = true;
    forceSSL = true;
    documentRoot =  "/var/www/";
    extraConfig = ''
    <Location />
    Require all granted
    </Location>

    ProxyPass /.well-known !
#    ProxyPass /static !
#    ProxyPass /media !
#    ProxyPass /favicon.ico !
    ProxyPass / http://[::1]:9991/
    ProxyPassReverse / http://[::1]:9991/
    ProxyPreserveHost On
    CacheDisable /
    '';
  };
  services.httpd.virtualHosts."www.gvois.in" = {
    serverAliases = [
      "keycloak.gvois.in"
      "discourse.gvois.in"
      "meet.gvois.in"
      "jswiki.gvois.in"
      ];
    enableACME = true;
    forceSSL = true;
    documentRoot =  "/var/www/wagtail/";
    extraConfig = ''
    <Location />
    Require all granted
    </Location>

    ProxyPass /.well-known !
    ProxyPass /static !
    ProxyPass /media !
    ProxyPass /favicon.ico !
    ProxyPass / unix:/var/lib/wagtail/wagtail-lesgv.sock|http://127.0.0.1/
    ProxyPassReverse / unix:/var/lib/wagtail/wagtail-lesgv.sock|http://127.0.0.1/
    ProxyPreserveHost On
    CacheDisable /
    '';
  };
  services.httpd.virtualHosts."blog.gvois.in" = {
    serverAliases = [
      "ghost.gvois.in"
    ];
    enableACME = true;
    forceSSL = true;
    documentRoot =  "/var/www/ghostio/";
    extraConfig = ''
    <Location />
    Require all granted
    </Location>

    ProxyPass /.well-known !
    ProxyPass /static !
    ProxyPass /media !
    ProxyPass /favicon.ico !
    ProxyPass / http://localhost:2368/
    ProxyPassReverse / http://localhost:2368/
    ProxyPreserveHost On
    ProxyVia On
    ProxyAddHeaders On

    CacheDisable /
    '';
  };
  services.httpd.virtualHosts."odoo.gvois.in" = {
    enableACME = true;
    forceSSL = true;
    documentRoot =  "/var/www/";
    extraConfig = ''
    <Location />
    Require all granted
    </Location>
    
    ProxyPass /.well-known !
    ProxyPass /static !
    ProxyPass /media !
    ProxyPass /favicon.ico !
    ProxyPass / http://localhost:8069/
    ProxyPassReverse / http://localhost:8069/
    ProxyPreserveHost On
    ProxyVia On
    ProxyAddHeaders On

    CacheDisable /
    '';
  };
#  services.httpd.virtualHosts."www.resdigita.com" = {
#    enableACME = true;
#    forceSSL = true;
##    documentRoot =  "/var/www/wagtail/";
#    globalRedirect = "https://www.gvois.in/resdigita";
##    extraConfig = ''
##    <Location />
##    Require all granted
##    </Location>
##
##    ProxyPass /.well-known !
##    ProxyPass /static !
##    ProxyPass /media !
##    ProxyPass /favicon.ico !
##    ProxyPass / unix:/var/lib/wagtail/wagtail-lesgv.sock|http://127.0.0.1/
##    ProxyPassReverse / unix:/var/lib/wagtail/wagtail-lesgv.sock|http://127.0.0.1/
##    ProxyPreserveHost On
##    CacheDisable /
##    '';
#
#  };
#  services.httpd.virtualHosts."www.resdigita.org" = {
#    enableACME = true;
#    forceSSL = true;
##    documentRoot =  "/var/www/wagtail/";
#    globalRedirect = "https://www.gvois.in/resdigita";
##    extraConfig = ''
##    <Location />
##    Require all granted
##    </Location>
##
##    ProxyPass /.well-known !
##    ProxyPass /static !
##    ProxyPass /media !
##    ProxyPass /favicon.ico !
##    ProxyPass / unix:/var/lib/wagtail/wagtail-lesgv.sock|http://127.0.0.1/
##    ProxyPassReverse / unix:/var/lib/wagtail/wagtail-lesgv.sock|http://127.0.0.1/
##    ProxyPreserveHost On
##    CacheDisable /
##    '';
##
#  };

  services.httpd.virtualHosts."odoo1.gvois.in" = {
    serverAliases = [
      "actentioncom.gvois.in"
      "gvoisorg.gvois.in"
      "manndigital.gvois.in"
      "mannfr.gvois.in"
    ];
    documentRoot = "/var/www/sites/";
    enableACME = true;
    forceSSL = true;
    extraConfig = ''
      Alias "/html/" "/var/www/sites/goodv.org/"
      ProxyPreserveHost On
      RequestHeader set X-Forwarded-Proto "https"
      RequestHeader set X-Forwarded-Port "443"
      ProxyPass /html/ !
      ProxyPass / http://10.245.101.158:8069/
      ProxyPassReverse / http://10.245.101.158:8069/
      ProxyPreserveHost on
      CacheDisable /
    '';
  };

  services.httpd.virtualHosts."odoo2.gvois.in" = {
    serverAliases = [
      "lgvcoop.gvois.in"
    ];
    documentRoot = "/var/www/sites/";
    enableACME = true;
    forceSSL = true;
    extraConfig = ''
      Alias "/html/" "/var/www/sites/goodv.org/"
      ProxyPreserveHost On
      RequestHeader set X-Forwarded-Proto "https"
      RequestHeader set X-Forwarded-Port "443"
      ProxyPass /html/ !
      ProxyPass / http://10.245.101.128:8069/
      ProxyPassReverse / http://10.245.101.128:8069/
      ProxyPreserveHost on
      CacheDisable /
    '';
  };

  services.httpd.virtualHosts."ghostio.gvois.in" = {
    serverAliases = [
      "coopgvcom.gvois.in"
      "coopgvorg.gvois.in"
      "lesgrandsvoisinsfr.gvois.in"
      "bloglesgrandsvoisinscom.gvois.in"
      "ghostgvoisorg.gvois.in"
      ];
    documentRoot =  "/var/www/ghostio/";
    enableACME = true;
    forceSSL = true;
    extraConfig = ''
    <Location />
    Require all granted
    </Location>

    ProxyPass /.well-known !
    ProxyPass /static !
    ProxyPass /media !
    ProxyPass /favicon.ico !
    ProxyPass / http://fd42:48f1:fe79:8c4b:216:3eff:fec9:de31:2368/
#    ProxyPassReverse / http://fd42:48f1:fe79:8c4b:216:3eff:fec9:de31:2368/
    ProxyPreserveHost On
    ProxyVia On
    ProxyAddHeaders On

    CacheDisable /
    '';
  };
}