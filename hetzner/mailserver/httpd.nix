{ config, pkgs, lib, ... }:
let 
  # Each domain alias needs to always point here 
  domainRedirectAliases = [
    "mail.resdigita.org" 
    "www.lesgv.com" 
    "lesgv.org" 
    "www.lesgv.org" 
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
    ];
    domainNameForEmail = import ./vars/domain-name.nix;
    ldapBaseDCDN = import ./vars/ldap-base-dc-dn.nix;
    domainName = import /etc/nixos/mailserver/vars/domain-name-mail.nix;
in
{
  services.httpd.virtualHosts."${domainName}" = {
    enableACME = true;
    forceSSL = true;
    documentRoot =  "/var/www/SOGo";
    extraConfig = ''
    Alias /SOGo.woa/WebServerResources/js/theme.js /var/www/SOGo/WebServerResources/theme.js
    Alias /.woa/WebServerResources/ /var/www/SOGo/WebServerResources/
    Alias /SOGo.woa/WebServerResources/ /var/www/SOGo/WebServerResources/
    Alias /SOGo/WebServerResources/ /var/www/SOGo/WebServerResources/
    Alias /WebServerResources/ /var/www/SOGo/WebServerResources/
    RedirectMatch ^/$ /SOGo/
    <Directory /var/www/SOGo/WebServerResources/>
      AllowOverride none
      Require all granted
      <IfModule expires_module>
        ExpiresActive On
        ExpiresDefault "access plus 1 year"
      </IfModule>
    </Directory>
    ProxyPass /.well-known !
    ProxyPass /.woa/WebServerResources/ !
    ProxyPass /SOGo.woa/WebServerResources/  !
    ProxyPass /SOGo/WebServerResources/  !
    ProxyPass /WebServerResources/  !
    ProxyPass /SOGo/ http://[::1]:20000/SOGo/ retry=0
    # ProxyPass /SOGo/ http://[::1]:20000/SOGo/ retry=0

    ProxyRequests Off
    SetEnv proxy-nokeepalive 1
    ProxyPreserveHost On
    CacheDisable /
    <Proxy http://[::1]:20000/ >
      SetEnvIf Host (.*) custom_host=$1
      RequestHeader set "x-webobjects-server-name" "%{custom_host}e"
      RequestHeader set "x-webobjects-server-url" "https://%{custom_host}e/SOGo/"
      RequestHeader set "x-webobjects-server-port" "443"
      # When using proxy-side autentication, you need to uncomment and
      ## adjust the following line:
      RequestHeader unset "x-webobjects-remote-user"
      #  RequestHeader set "x-webobjects-remote-user" "%{REMOTE_USER}e" env=REMOTE_USER
      RequestHeader set "x-webobjects-server-protocol" "HTTP/1.0"
      AddDefaultCharset UTF-8
      Order allow,deny
      Allow from all
      # RewriteEngine On
      # RewriteRule SOGo/(.*)$ $1 [P]
      # Header edit Location ^https://%{custom_host}e/SOGo/(.*) http://%{custom_host}e/$1
    </Proxy>
    '';
  };
  services.httpd.virtualHosts."app.lesgrandsvoisins.com" = {
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