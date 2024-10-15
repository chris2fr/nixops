{ config, pkgs, lib, ... }:
let 
  # Each domain alias needs to always point here 
  domainRedirectAliases = [
    "mail.resdigita.org" 
    "lesgv.org" 
    "lesgv.com"
    "gvoisin.com" 
    "www.gvoisin.com"
    "mail.gvoisin.com"
    "gvoisin.org"
    "www.gvoisin.org"
    "gvoisins.org"
    "www.gvoisins.org"
    "gvoisins.com"
    "www.gvoisins.com"
    "mail.resdigita.com"
    "www.lesgv.org"
    ];
    #     "www.lesgv.com" 
    domainNameForEmail = import ./vars/domain-name.nix;
    ldapBaseDCDN = import ./vars/ldap-base-dc-dn.nix;
    domainName = import /etc/nixos/mailserver/vars/domain-name-mail.nix;
in
{
  # services.phpfpm.pools."roundcubedesgv" = {
  #   user = "roundcube";
  #   settings = {
  #     "listen.owner" = config.services.httpd.user;
  #     "pm" = "dynamic";
  #     "pm.max_children" = 32;
  #     "pm.max_requests" = 500;
  #     "pm.start_servers" = 2;
  #     "pm.min_spare_servers" = 2;
  #     "pm.max_spare_servers" = 5;
  #     "php_admin_value[error_log]" = "stderr";
  #     "php_admin_flag[log_errors]" = true;
  #     "catch_workers_output" = true;
  #   };
  #    phpEnv."PATH" = lib.makeBinPath [ pkgs.php ];
  # };
  
  # services.httpd.virtualHosts."${domainName}" = {
  #   listen = [{port = 8443; ssl=true;}];
  #   sslServerCert = "/var/lib/acme/${domainName}/fullchain.pem";
  #   sslServerChain = "/var/lib/acme/${domainName}/fullchain.pem";
  #   sslServerKey = "/var/lib/acme/${domainName}/key.pem";

  #   # documentRoot =  "/var/www/SOGo";

  #   extraConfig = ''
  #   Alias /SOGo.woa/WebServerResources/js/theme.js /var/www/SOGo/WebServerResources/theme.js
  #   Alias /.woa/WebServerResources/ /var/www/SOGo/WebServerResources/
  #   Alias /SOGo.woa/WebServerResources/ /var/www/SOGo/WebServerResources/
  #   Alias /SOGo/WebServerResources/ /var/www/SOGo/WebServerResources/
  #   Alias /WebServerResources/ /var/www/SOGo/WebServerResources/
  #   # RedirectMatch ^/$ /SOGo/
  #   <Directory /var/www/SOGo/WebServerResources/>
  #     AllowOverride none
  #     Require all granted
  #     <IfModule expires_module>
  #       ExpiresActive On
  #       ExpiresDefault "access plus 1 year"
  #     </IfModule>
  #   </Directory>
  #   ProxyPass /.well-known !
  #   ProxyPass /.woa/WebServerResources/ !
  #   ProxyPass /SOGo.woa/WebServerResources/  !
  #   ProxyPass /SOGo/WebServerResources/  !
  #   ProxyPass /WebServerResources/  !
  #   ProxyPass /SOGo/ http://[::1]:20000/SOGo/ retry=0
  #   # ProxyPass /SOGo/ http://[::1]:20000/SOGo/ retry=0

  #   ProxyRequests Off
  #   SetEnv proxy-nokeepalive 1
  #   ProxyPreserveHost On
  #   CacheDisable /
  #   <Proxy http://[::1]:20000/ >
  #     SetEnvIf Host (.*) custom_host=$1
  #     RequestHeader set "x-webobjects-server-name" "%{custom_host}e"
  #     RequestHeader set "x-webobjects-server-url" "https://%{custom_host}e/SOGo/"
  #     RequestHeader set "x-webobjects-server-port" "443"
  #     # When using proxy-side autentication, you need to uncomment and
  #     ## adjust the following line:
  #     RequestHeader unset "x-webobjects-remote-user"
  #     #  RequestHeader set "x-webobjects-remote-user" "%{REMOTE_USER}e" env=REMOTE_USER
  #     RequestHeader set "x-webobjects-server-protocol" "HTTP/1.0"
  #     AddDefaultCharset UTF-8
  #     Order allow,deny
  #     Allow from all
  #     # RewriteEngine On
  #     # RewriteRule SOGo/(.*)$ $1 [P]
  #     # Header edit Location ^https://%{custom_host}e/SOGo/(.*) http://%{custom_host}e/$1
  #   </Proxy>

  #       ProxyPreserveHost On
  #       ProxyVia On
  #       ProxyAddHeaders On
  #       RequestHeader set X-Original-URL "expr=%{THE_REQUEST}"
  #       RequestHeader edit* X-Original-URL ^[A-Z]+\s|\sHTTP/1\.\d$ ""
  #       RequestHeader set X-Forwarded-Proto "https"
  #       RequestHeader set X-Forwarded-Port "443"
       
  #       <Directory />
  #           Options FollowSymLinks
  #           AllowOverride None
  #       </Directory>
  #       <Directory ${pkgs.roundcube}>
  #           Options -Indexes +FollowSymLinks +MultiViews
  #           AllowOverride None
  #           Order allow,deny
  #           allow from all
  #           DirectoryIndex /index.php index.php
  #       </Directory>
  #       # CacheDisable /
  #       DocumentRoot ${pkgs.roundcube}
  #       ProxyPassMatch ^/(.*\.php(/.*)?)$  unix:/run/phpfpm/roundcubedesgv.sock|fcgi://mail.lesgrandsvoisins.com${pkgs.roundcube}
  #       # ProxyPass / https://mail.lesgrandsvoisins.com:8443/
  #     '';
  # };
  services.httpd.virtualHosts."app.lesgrandsvoisins.com" = {
     listen = [{port = 8443; ssl=true;}];
    sslServerCert = "/var/lib/acme/app.lesgrandsvoisins.com/fullchain.pem";
    sslServerChain = "/var/lib/acme/app.lesgrandsvoisins.com/fullchain.pem";
    sslServerKey = "/var/lib/acme/app.lesgrandsvoisins.com/key.pem";

    documentRoot =  "/var/www/";
    extraConfig = ''
      RewriteEngine On
      RewriteRule ^(.*)$ https://guichet.resdigita.com$1
    '';
  };

#  services.httpd.virtualHosts."mail.resdigita.com" = {
#    serverAliases = ["gvoisin.com" "www.gvoisin.com" "mail.gvoisin.com" "gvoisin.org" "www.gvoisin.org" "gvoisins.org" "www.gvoisins.org" "gvoisins.com" "www.gvoisins.com" "app.lesgrandsvoisins.com"];
#    enableACME = true;
#    forceSSL = true;
#    documentRoot =  "/var/www/SOGo";
#    extraConfig = ''
#    Alias /SOGo.woa/WebServerResources/js/theme.js /var/www/SOGo/WebServerResources/theme.js
#    Alias /.woa/WebServerResources/ /var/www/SOGo/WebServerResources/
#    Alias /SOGo.woa/WebServerResources/ /var/www/SOGo/WebServerResources/
#    Alias /SOGo/WebServerResources/ /var/www/SOGo/WebServerResources/
#    Alias /WebServerResources/ /var/www/SOGo/WebServerResources/
# 
#    <Directory /var/www/SOGo/WebServerResources/>
#      AllowOverride none
#      Require all granted
#      <IfModule expires_module>
#        ExpiresActive On
#        ExpiresDefault "access plus 1 year"
#      </IfModule>
#    </Directory>
#    ProxyPass /.well-known !
#    ProxyPass /.woa/WebServerResources/ !
#    ProxyPass /SOGo.woa/WebServerResources/  !
#    ProxyPass /SOGo/WebServerResources/  !
#    ProxyPass /WebServerResources/  !
#    ProxyPass /SOGo/ http://[::1]:20000/SOGo/ retry=0
#    ProxyPass /SOGo http://[::1]:20000/SOGo retry=0
#    ProxyPass / http://localhost:9991/ retry=0
#    ProxyRequests Off
#    SetEnv proxy-nokeepalive 1
#    ProxyPreserveHost On
#    CacheDisable /
#    <Proxy http://127.0.0.1:20000/SOGo/ >
#      SetEnvIf Host (.*) custom_host=$1
#      RequestHeader set "x-webobjects-server-name" "%{custom_host}e"
#      RequestHeader set "x-webobjects-server-url" "https://%{custom_host}e"
#      RequestHeader set "x-webobjects-server-port" "443"
#      # When using proxy-side autentication, you need to uncomment and
#      ## adjust the following line:
#      RequestHeader unset "x-webobjects-remote-user"
#      #  RequestHeader set "x-webobjects-remote-user" "%{REMOTE_USER}e" env=REMOTE_USER
#      RequestHeader set "x-webobjects-server-protocol" "HTTP/1.0"
#      AddDefaultCharset UTF-8
#      Order allow,deny
#      Allow from all
#    </Proxy>
#    '';
#  };
}