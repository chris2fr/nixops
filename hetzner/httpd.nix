  { config, pkgs, lib, ... }:

let 
in
{ 
  nix.settings.experimental-features = "nix-command flakes";
  users.users.mannchri.extraGroups = [ "wwwrun" ];
  services.httpd.enable = true;
  services.httpd.enablePHP = false;
  services.httpd.adminAddr = "contact@villagevoisin.org";
  services.httpd.extraModules = [ "proxy" "proxy_http" ];
  users.users.wwwrun.extraGroups = [ "acme" "wagtail" ];
  services.httpd.virtualHosts."villagevoisin.org" = {
    serverAliases = [
      "villagevoisin.com"
      "www.villagevoisin.com"
    ];
    enableACME = true;
    forceSSL = true;
    globalRedirect = "https://www.villagevoisin.org/";
  };
  services.httpd.virtualHosts."www.villagevoisin.org" = {
    serverAliases = [
      "guichet.villagevoisin.org"
      "odoo.villagevoisin.org"
      "keycloak.villagevoisin.org"
      "discourse.villagevoisin.org"
      "meet.villagevoisin.org"
      "jswiki.villagevoisin.org"
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
#  services.httpd.virtualHosts."www.resdigita.com" = {
#    enableACME = true;
#    forceSSL = true;
##    documentRoot =  "/var/www/wagtail/";
#    globalRedirect = "https://www.villagevoisin.org/resdigita";
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
#    globalRedirect = "https://www.villagevoisin.org/resdigita";
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
}