  { config, pkgs, lib, ... }:

let 
in
{ 
  nix.settings.experimental-features = "nix-command flakes";
  users.users.mannchri.extraGroups = [ "wwwrun" ];
  services.httpd.enable = true;
  services.httpd.enablePHP = false;
  services.httpd.adminAddr = "contact@lesgrandsvoisins.com";
  services.httpd.extraModules = [ "proxy" "proxy_http" ];
  users.users.wwwrun.extraGroups = [ "acme" "wagtail" ];
  services.httpd.virtualHosts."www.resdigita.com" = {
    serverAliases = [
      "www.resdigita.org"
      "resdigita.org"
      "resdigita.com"
    ];
    documentRoot =  "/var/www/resdigitacom/";
    forceSSL = true;
    enableACME = true;
    extraConfig = ''
      <If "%{HTTP_HOST} != 'www.resdigita.com'">
          RedirectMatch /(.*)$ https://www.resdigita.com/$1
      </If>
    '';
  };
  services.httpd.virtualHosts."lesgrandsvoisins.com" = {
    enableACME = true;
    forceSSL = true;
    serverAliases = [ 
      "gvois.in"
      "www.gvois.in" 
      "gvcoop.org"
      "www.gvcoop.org"
      "gvcoop.com"
      "www.gvcoop.com"
      "coopgv.org"
      "www.coopgv.org"
      "coopgv.com"
      "www.coopgv.com"
      "wagtail.l-g-v.com"
    ];
    globalRedirect = "https://www.lesgrandsvoisins.com/";
  };
  services.httpd.virtualHosts."avmeet.com" = {
    enableACME = true;
    forceSSL = true;
    globalRedirect = "https://www.avmeet.com";
  };
#  services.httpd.virtualHosts."resdigita.com" = {
#    enableACME = true;
#    forceSSL = true;
#    globalRedirect = "https://www.lesgrandsvoisins.com/resdigita";
#  };
#  services.httpd.virtualHosts."resdigita.org" = {
#    enableACME = true;
#    forceSSL = true;
#    globalRedirect = "https://www.lesgrandsvoisins.com/resdigita";
#  };
  services.httpd.virtualHosts."www.lesgrandsvoisins.com" = {
    serverAliases = [
      "app.lesgrandsvoisins.com"
      "www.avmeet.com"
      "biz.lesgrandsvoisins.com"
      "auth.lesgrandsvoisins.com"
      "forum.lesgrandsvoisins.com"
      "meet.lesgrandsvoisins.com"
      "wiki.lesgrandsvoisins.com" ];
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
#    globalRedirect = "https://www.lesgrandsvoisins.com/resdigita";
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
#    globalRedirect = "https://www.lesgrandsvoisins.com/resdigita";
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