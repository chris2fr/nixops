{ config, pkgs, lib, ... }:
let 
in
{ 

  nix.settings.experimental-features = "nix-command flakes";
  users.users.mannchri.extraGroups = [ "wwwrun" ];
  services.httpd.enable = true;
  # services.httpd.enablePHP = false;
  services.httpd.adminAddr = "contact@lesgrandsvoisins.com";
  # services.httpd.extraConfig = ''
  #   Listen 0.0.0.0:443 https
  #   Listen 0.0.0.0:80 http
  # '';
  services.httpd.extraModules = [ "proxy" "proxy_http" ]; # 2025-10-18
  users.users.wwwrun.extraGroups = [ "acme" "wagtail" ];
  services.httpd.virtualHosts."mann.vpsfree.gdvoisins.com" = {
    # serverAliases = [
    #   "mann.fr"
    # ];
    enableACME = true;
    forceSSL = true;
    documentRoot =  "/var/www/wagtail/";
    listenAddresses = [
      "[::]"
      "0.0.0.0"
    ];
    extraConfig = ''
    # <If "%{HTTP_HOST} != 'www.mann.fr'">
    #   RedirectMatch /(.*)$ https://www.mann.fr/$1
    # </If>
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
  services.httpd.virtualHosts."resdigita.vpsfree.gdvoisins.com" = {
    # serverAliases = [
    #   "www.resdigita.com"
    #   "resdigita.org"
    #   "www.resdigita.org"
    #   "resdigita.com"
    # ];
    documentRoot =  "/var/www/resdigitacom/";
    forceSSL = true;
    enableACME = true;
    # listenAddress = [
    #   "[::]"
    #   "0.0.0.0"
    # ];
    # extraConfig = ''
    #   <If "%{HTTP_HOST} != 'www.resdigita.org'">
    #       RedirectMatch /(.*)$ https://www.resdigita.org/$1
    #   </If>
    # '';
  };
  services.httpd.virtualHosts."lesgrandsvoisinsblog.vpsfree.gdvoisins.com" = {
    documentRoot =  "/var/www/resdigitacom/";
    forceSSL = true;
    enableACME = true;
    # extraConfig = ''
    #    RedirectMatch /(.*)$ https://blog.gvois.in/$1
    # '';
  };
#   services.httpd.virtualHosts."lesgrandsvoisins.com" = {
#     enableACME = true;
#     forceSSL = true;
# #    serverAliases = [ 
# #      "gvois.in"
# #      "www.gvois.in" 
# #      "gvcoop.org"
# #      "www.gvcoop.org"
# #      "gvcoop.com"
# #      "www.gvcoop.com"
# #      "coopgv.org"
# #      "www.coopgv.org"
# #      "coopgv.com"
# #      "www.coopgv.com"
# #      "wagtail.l-g-v.com"
# #      "gvoisins.org"
# #      "gvoisins.com"
# #      "www.gvoisins.com"
# #      "www.gvoisins.org"
# #    ];
#     globalRedirect = "https://www.lesgrandsvoisins.com/";
#   };
  # services.httpd.virtualHosts."avmeet.com" = {
  #   enableACME = true;
  #   forceSSL = true;
  #   globalRedirect = "https://www.avmeet.com";
  # };
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
services.httpd.virtualHosts."app.gvois.in" = {
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
  services.httpd.virtualHosts."shitmuststop.vpsfree.gdvoisins.com" = {
    # serverAliases = [
    #   "shitmuststop.org"
    #   "shitmuststop.com"
    #   "www.shitmuststop.com"
    #   "www.shitmuststop.org"
    # ];
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
    # <If "%{HTTP_HOST} != 'www.shitmuststop.org'">
    #     RedirectMatch /(.*)$ https://www.shitmuststop.org/$1
    # </If>
    '';
  };
  services.httpd.virtualHosts."lesartsvoisins.gdvoisins.com" = {
    serverAliases = [
      "lesartsvoisins.org"
      "www.lesartsvoisins.org"
      "lesartsvoisins.com"
      "www.lesartsvoisins.com"
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
    # <If "%{HTTP_HOST} != 'www.lesartsvoisins.org'">
    #     RedirectMatch /(.*)$ https://www.lesartsvoisins.org/$1
    # </If>
    '';
  };
  services.httpd.virtualHosts."lesgrandsvoisinsfr.vpsfree.gdvoisins.com" = {
    serverAliases = [
      "lesgrandsvoisins.fr"
      "www.lesgrandsvoisins.fr"
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
    # <If "%{HTTP_HOST} != 'www.lesgrandsvoisins.fr'">
    #     RedirectMatch /(.*)$ https://www.lesgrandsvoisins.fr/$1
    # </If>
    '';
  };
  # services.httpd.virtualHosts."desgrandsvoisins.com" = {
  #    extraConfig = ''
  #     Dav On
  #     DavLockDB /tmp/DavLock

  #    '';
  # };
  services.httpd.virtualHosts."lesgrandsvoisins.vpsfree.gdvoisins.com" = {
#     serverAliases = [
#       "www.avmeet.com"
#       "www.lesgrandsvoisins.com"
#       "biz.lesgrandsvoisins.com"
#       "auth.lesgrandsvoisins.com"
# #      "forum.lesgrandsvoisins.com"
#       "meet.lesgrandsvoisins.com"
#       "wiki.lesgrandsvoisins.com"
# #      "app.gvoisins.org"
# #      "guichet.gvoisins.org"
# #      "odoo.gvoisins.org"
# #      "discourse.gvoisins.org"
# #      "keycloak.gvoisins.org"
# #      "meet.gvoisins.org"
# #      "meet.gvoisins.com"
# #      "wiki.gvoisins.org"
# #       "lesgrandsvoisins.fr"
# #       "www.lesgrandsvoisins.fr"
#         "biglibre.org"
#         "biglibre.com"
#         "www.biglibre.org"
#         "www.biglibre.com"
#         "warfour.biglibre.org"
#         "warfur.org"
#         "www.warfur.org"
#         "partagemoi.lesgrandsvoisins.com"
#         "desgrandsvoisins.org"
#         "www.desgrandsvoisins.org"
        
#         "www.desgrandsvoisins.com"
#         "francemali.lesgrandsvoisins.com"
#       ];
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
    # <If "%{HTTP_HOST} == 'warfur.org'">
    #     RedirectMatch /(.*)$ https://www.warfur.org/$1
    # </If>
    # <If "%{HTTP_HOST} == 'desgrandsvoisins.com' || %{HTTP_HOST} == 'desgrandsvoisins.org' || %{HTTP_HOST} == 'www.desgrandsvoisins.org'" >
    #     RedirectMatch /(.*)$ https://www.desgrandsvoisins.com/$1
    # </If>
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