{ config, pkgs, lib, ... }:
let 
    wagtailExtraConfig = ''
        CacheDisable /
        ProxyVia On
        <Location />
          Require all granted
        </Location>
        ProxyPass /.well-known !
        ProxyPass /static !
        ProxyPass /media !
        ProxyPass /favicon.ico !
        CacheDisable /
        ProxyPass /  http://127.0.0.1:8000/
        ProxyPassReverse /  http://127.0.0.1:8000/
    '';
in
{ 
  nix.settings.experimental-features = "nix-command flakes";
  users.users.mannchri.extraGroups = [ "wwwrun" ];
  services.httpd.enable = true;
  services.httpd.enablePHP = false;
  services.httpd.adminAddr = "contact@gvois.in";
  services.httpd.extraModules = [ "proxy" "proxy_http" "dav"
   { name = "oauth2"; path = "/usr/local/lib/modules/mod_oauth2.so"; } ];
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
  services.httpd.virtualHosts."authentik.lesgrandsvoisins.com" = {
    enableACME = true;
    forceSSL = true;
    extraConfig = ''
        ProxyPass /  http://10.245.101.35:9000/
        # proxy_http_version 1.1;
        RequestHeader set X-Forwarded-Proto "https"
        RequestHeader set X-Forwarded-Port "443"
        #RequestHeader set X-Forwarded-For "$proxy_add_x_forwarded_for
        #RequestHeader set Host $host
        #RequestHeader set Upgrade $http_upgrade
        #RequestHeader set Connection $connection_upgrade_keepalive
        ProxyPreserveHost On
        ProxyVia On
        ProxyAddHeaders On
    '';
  };
  services.httpd.virtualHosts."resdigita.desgv.com" = {
    serverAliases = [
    ];
    documentRoot =  "/var/www/resdigitacom/";
    forceSSL = true;
    enableACME = true;
    extraConfig = ''
      <If "%{HTTP_HOST} != 'resdigita.desgv.com'">
          RedirectMatch /(.*)$ https://resdigita.desgv.com/$1
      </If>
    '';
  };

  services.httpd.virtualHosts."dav.desgv.com" = {
    enableACME = true;
    forceSSL = true;
    documentRoot = "/var/www/dav/";
    extraConfig = ''
      DavLockDB /tmp/DavLock

      <Directory "/var/www/dav/">

        Dav On

        # AuthName DAV
        AuthType oauth2
        OAuth2TokenVerify jwks_uri https://authentik.lesgrandsvoisins.com/application/o/dav/jwks/ jwks_uri.ssl_verify=false
        Require oauth2_claim 

        # AuthType Basic
        # 
        # AuthUserFile /var/www/.htpasswd
        # require valid-user 

        # <LimitExcept GET HEAD OPTIONS>
        #   require user admin
        # </LimitExcept>
      </Directory>
      '';
  };

  services.httpd.virtualHosts."www.desgv.com" = {
    serverAliases = ["desgv.com" "www.lesgrandsvoisins.com"];
    documentRoot = "/var/www/wagtail/";
    enableACME = true;
    forceSSL = true;
    #locations = wagtailHttpdLocations;
    # {
    #   "/.well-known".proxyPass = "!";
    #   "/static".proxyPass = "!";
    #   "/media".proxyPass = "!";
    #   "/favicon.ico".proxyPass = "!";
    #   "/" = {
    #     proxyPass = "http://127.0.0.1:8000/";
    #     extraConfig = ''
    #        Require all granted
    #        RequestHeader set X-Forwarded-Proto "https"
    #        RequestHeader set X-Forwarded-Port "443"
    #        ProxyPreserveHost On
    #        ProxyAddHeaders On
    #     '';
    #     priority = 1500;
    #   };

    # };
    extraConfig = lib.strings.concatStrings [ wagtailExtraConfig ''
      <If "%{HTTP_HOST} == 'desgv.com'">
          RedirectMatch /(.*)$ https://www.desgv.com/$1
      </If>
    ''];
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
    RequestHeader set X-Forwarded-Proto "https"
    RequestHeader set X-Forwarded-Port "443"
    ProxyPreserveHost On
    ProxyVia On
    ProxyAddHeaders On

    CacheDisable /
    '';
  };
#  services.httpd.virtualHosts."odoo.gvois.in" = {
#    enableACME = true;
#    forceSSL = true;
#    documentRoot =  "/var/www/";
#    extraConfig = ''
#    <Location />
#    Require all granted
#    </Location>
#    
#    ProxyPass /.well-known !
#    ProxyPass /static !
#    ProxyPass /media !
#    ProxyPass /favicon.ico !
#    ProxyPass / http://localhost:8069/
#    ProxyPassReverse / http://localhost:8069/
#    ProxyPreserveHost On
#    ProxyVia On
#    ProxyAddHeaders On
#
#    CacheDisable /
#    '';
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
      "manngvoisorg.gvois.in"
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
      ProxyPass /.well-known !
      ProxyPass / http://10.245.101.158:8069/
      # ProxyPassReverse / http://10.245.101.158:8069/
      ProxyPreserveHost on
      CacheDisable /
    '';
  };

  services.httpd.virtualHosts."odoo3.gvois.in" = {
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
      ProxyPass /.well-known !
      ProxyPass / http://10.245.101.128:8069/
      # ProxyPassReverse / http://10.245.101.128:8069/
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
    ProxyPass / http://[fd42:48f1:fe79:8c4b:216:3eff:fec9:de31]:2368/
#    ProxyPassReverse / http://[fd42:48f1:fe79:8c4b:216:3eff:fec9:de31]:2368/
    ProxyPreserveHost On
    ProxyVia On
    ProxyAddHeaders On
    RequestHeader set X-Forwarded-Proto "https"
    RequestHeader set X-Forwarded-Port "443"
    CacheDisable /
    '';
  };
  services.httpd.virtualHosts."tel.gvois.in" = {
    enableACME = true;
    forceSSL = true;
    documentRoot = "/var/www/sites/meet";
    extraConfig = ''
       ProxyRequests Off
       SetEnv proxy-nokeepalive 1
       ProxyPreserveHost On
       ProxyPass /.well-known !
       ProxyPass / http://10.245.101.19/ retry=0
       <Proxy http://10.245.101.19/>
       ## adjust the following to your configuration
       RequestHeader set "x-webobjects-server-port" "443"
       RequestHeader set "x-webobjects-server-name" "tel.lgv.coop"
       RequestHeader set "x-webobjects-server-url" "https://tel.gvois.in"
      ## When using proxy-side autentication, you need to uncomment and
      ## adjust the following line:
        RequestHeader unset "x-webobjects-remote-user"
      #  RequestHeader set "x-webobjects-remote-user" "%{REMOTE_USER}e" env=REMOTE_USER

        RequestHeader set "x-webobjects-server-protocol" "HTTP/1.0"

        AddDefaultCharset UTF-8

        Order allow,deny
        Allow from all
      </Proxy>
    '';
  };
  services.httpd.virtualHosts."wagtail.gvois.in" = {
    enableACME = true;
    forceSSL = true;
    documentRoot = "/var/www/wagtail";
    serverAliases = [
      "manncoach.gvois.in"
      "resdigitacom.gvois.in"
      "distractivescom.gvois.in"
      "whowhatetccom.gvois.in"
      "voisandcom.gvois.in"
      "coopgvcom.gvois.in"
      "voisandorg.gvois.in"
      "lesgvcom.gvois.in"
      "popuposcom.gvois.in"
      "grandsvoisinscom.gvois.in"
      "forumgrandsvoisinscom.gvois.in"
      "baldridgegvoisorg.gvois.in"
      "discourselesgvcom.gvois.in"
      "iriviorg.gvois.in"
      "ooolesgrandsvoisinscom.gvois.in"
      "hyperattentioncom.gvois.in"
      "forumgdvoisinscom.gvois.in"
      "forumgrandsvoisinscom.gvois.in"
      "agoodvillagecom.gvois.in"
      "lgvcoop.gvois.in"
      "configmagiccom.gvois.in"
      "caplancitycom.gvois.in"
      "quiquoietccom.gvois.in"
      "lesartsvoisinscom.gvois.in"
      "maelanccom.gvois.in"
      "manncity.gvois.in"
      "focusplexcom.gvois.in"
      "gvoisorg.gvois.in"
      "vlgorg.gvois.in"
      "oldlesgrandsvoisinscom.gvois.in"
      "cooptellgv.gvois.in"
      "howwownowcom.gvois.in"
      "aaalesgrandsvoisinscom.gvois.in"
      "oldmanndigital.gvois.in"
      "resolvactivecom.gvois.in"
      "gvcity.gvois.in"
      "toutdouxlissecom.gvois.in"
      "iciwowcom.gvois.in"
      ];
      extraConfig = ''
          <Location />
          Require all granted
          </Location>
#        SSLProxyEngine on
#        RewriteEngine on
#
#        RequestHeader set X-Forwarded-Proto "https"
#        RequestHeader set X-Forwarded-Port "443"
#
#        <Location /static/>
#        ProxyPass http://localhost:8888/
#        # ProxyPassReverse http://localhost:8888/
#        ProxyPreserveHost On
#        </Location>
#
#        <Location /media/>
#        ProxyPass http://localhost:8889/
#        # ProxyPassReverse http://localhost:8889/
#        ProxyPreserveHost On
#        </Location>

    ProxyPass /.well-known !
    ProxyPass /static !
    ProxyPass /media !
    ProxyPass /favicon.ico !
        ProxyPass /  unix:/var/lib/wagtail/wagtail-lesgv.sock|http://127.0.0.1/
        ProxyPassReverse / unix:/var/lib/wagtail/wagtail-lesgv.sock|http://127.0.0.1/
        # ProxyPassReverse / http://localhost:8080/
        ProxyPreserveHost On
        CacheDisable /
      '';
  };


  services.httpd.virtualHosts."odoo4.gvois.in" = {
    enableACME = true;
    forceSSL = true;
    documentRoot = "/var/www/wagtail";
    serverAliases = [
      "voisandcom.gvois.in"
      "voisandorg.gvois.in"
      "lesgvcom.gvois.in"
      "villagevoisincom.gvois.in"
      "baldridgegvoisorg.gvois.in"
      "ooolesgrandsvoisinscom.gvois.in"
      "lesgrandsvoisinscom.gvois.in"
    ];
    extraConfig = ''
      Alias "/html/" "/var/www/sites/goodv.org/"
      ProxyPreserveHost On
      RequestHeader set X-Forwarded-Proto "https"
      RequestHeader set X-Forwarded-Port "443"
      ProxyPass /html/ !
      ProxyPass /.well-known !
      ProxyPass / http://10.245.101.173:8069/
      # ProxyPassReverse / http://10.245.101.173:8069/
      ProxyPreserveHost on
      CacheDisable /
    '';
  };

services.httpd.virtualHosts."odoo2.gvois.in" = {
    enableACME = true;
    forceSSL = true;
    documentRoot = "/var/www";
    serverAliases = [
      "ooolgvcoop.gvois.in"
    ];
  extraConfig = ''
      Alias "/html/" "/var/www/sites/goodv.org/"
      ProxyPreserveHost On
      RequestHeader set X-Forwarded-Proto "https"
      RequestHeader set X-Forwarded-Port "443"
      ProxyPass /html/ !
      ProxyPass /.well-known !
      ProxyPass / http://10.245.101.82:8069/
      # ProxyPassReverse / http://10.245.101.82:8069/
      ProxyPreserveHost on
      CacheDisable /
    '';
  };
}