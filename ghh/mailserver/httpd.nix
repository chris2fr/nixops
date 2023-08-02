{ config, pkgs, lib, ... }:

let 
  domainName = "test.gvoisins.com";
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
    ProxyPass /SOGo http://[::1]:20000/SOGo retry=0
    ProxyPass / http://localhost:9991/ retry=0
    ProxyRequests Off
    SetEnv proxy-nokeepalive 1
    ProxyPreserveHost On
    CacheDisable /
    <Proxy http://127.0.0.1:20000/SOGo/ >
      SetEnvIf Host (.*) custom_host=$1
      RequestHeader set "x-webobjects-server-name" "%{custom_host}e"
      RequestHeader set "x-webobjects-server-url" "https://%{custom_host}e"
      RequestHeader set "x-webobjects-server-port" "443"
      # When using proxy-side autentication, you need to uncomment and
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
}