{ config, pkgs, lib, ... }:
let 
    wagtailExtraConfig = ''
        CacheDisable /
        <Location />
          Require all granted
        </Location>
        ProxyPass /.well-known !
        ProxyPass /static !
        ProxyPass /media !
        ProxyPass /favicon.ico !
        CacheDisable /
        ProxyPass /  http://127.0.0.1:8000/
        # ProxyPassReverse /  http://127.0.0.1:8000/
        ProxyPreserveHost On
        ProxyVia On
        ProxyAddHeaders On
        # RequestHeader set X-Forwarded-Proto "https"
        # RequestHeader set X-Forwarded-Port "443"
    '';
in
{ 
  nix.settings.experimental-features = "nix-command flakes";
  users.users.mannchri.extraGroups = [ "wwwrun" ];
  services.httpd.enable = true;
  services.httpd.enablePHP = false;
  services.httpd.extraConfig = ''
  KeepAlive On
  MaxKeepAliveRequests 100
  KeepAliveTimeout 3
  Protocols h2 http/1.1
  # Listen [2a01:4f8:241:4faa::]:80
  # Listen [2a01:4f8:241:4faa::1]:80
  # Listen [2a01:4f8:241:4faa::2]:80
  # Listen [2a01:4f8:241:4faa::3]:80
  # Listen [2a01:4f8:241:4faa::4]:80
  # Listen [2a01:4f8:241:4faa::5]:80
  # Listen [2a01:4f8:241:4faa::]:80
  # Listen 116.202.236.241:80
  # Listen [2a01:4f8:241:4faa::]:443
  # Listen [2a01:4f8:241:4faa::1]:443
  # Listen [2a01:4f8:241:4faa::2]:443
  # Listen [2a01:4f8:241:4faa::3]:443
  # Listen [2a01:4f8:241:4faa::4]:443
  # Listen [2a01:4f8:241:4faa::5]:443
  # Listen [2a01:4f8:241:4faa::]:443
  # Listen 116.202.236.241:443
  '';
  services.httpd.adminAddr = "contact@gvois.in";
  services.httpd.extraModules = [ "proxy" "proxy_http" "dav" "ldap" "authnz_ldap" "alias" "ssl" "rewrite" "http2"
    { name = "auth_openidc"; path = "/usr/local/lib/modules/mod_auth_openidc.so"; }
     ];
  users.users.wwwrun.extraGroups = [ "acme" "wagtail" "users" "ghost" "ghostio" "guichet" ];
  services.httpd.virtualHosts."gvois.in" = {
    # listenAddresses = ["*" "[2a01:4f8:241:4faa::]" "[2a01:4f8:241:4faa::1]" "[2a01:4f8:241:4faa::2]" "[2a01:4f8:241:4faa::3]" "[2a01:4f8:241:4faa::4]" "[2a01:4f8:241:4faa::5]"];
    enableACME = true;
    forceSSL = true;
    globalRedirect = "https://www.gvois.in/";
  };
  services.httpd.virtualHosts."hetzner005.lesgrandsvoisins.com" = {
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

    ProxyPass / http://[::1]:8080/
    ProxyPreserveHost On
    CacheDisable /
    '';
  };
  services.httpd.virtualHosts."guichet.lesgrandsvoisins.com" = {
    serverAliases = ["app.lesgrandsvoisins.com"];
    enableACME = true;
    forceSSL = true;
    documentRoot =  "/var/www/guichet";
    extraConfig = ''
    <Location />
    Require all granted
    </Location>

    ProxyPass /.well-known !
    ProxyPass /static !
    ProxyPass /media !
    ProxyPass /favicon.ico !
    ProxyPass / http://[::1]:9991/
    ProxyPassReverse / http://[::1]:9991/
    ProxyPreserveHost On
    CacheDisable /
    <If "%{HTTP_HOST} != 'guichet.lesgrandsvoisins.com'">
      RedirectMatch /(.*)$ https://guichet.lesgrandsvoisins.com/$1
    </If>
    '';
  };
#   services.httpd.virtualHosts."guichet.lesgrandsvoisins.com" = {
#     enableACME = true;
#     forceSSL = true;
#     documentRoot =  "/var/www/";
#     extraConfig = ''
#     <Location />
#     Require all granted
#     </Location>

#     ProxyPass /.well-known !
# #    ProxyPass /static !
# #    ProxyPass /media !
# #    ProxyPass /favicon.ico !
#     ProxyPass / http://[::1]:9991/
#     ProxyPassReverse / http://[::1]:9991/
#     ProxyPreserveHost On
#     CacheDisable /
#       RewriteEngine On
#       RewriteRule ^/SOGo(.*)$ https://mail.lesgrandsvoisins.com$1
#     '';
#   };
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
  services.httpd.virtualHosts."hdoc.lesgrandsvoisins.com" = {
    serverAliases = [
      "hedgedoc.lesgrandsvoisins.com"
      "hdoc.lesgv.com"
      "hedgedoc.lesgv.com"
    ];
    enableACME = true;
    forceSSL = true;
    extraConfig = ''
        #ProxyPass /  http://10.245.101.35:3000/
        ProxyPass /  http://localhost:3000/
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
  services.httpd.virtualHosts."auth.lesgrandsvoisins.com" = {
    # serverAliases = [
    # ];
    enableACME = true;
    forceSSL = true;
    extraConfig = ''
        # RewriteEngine On
        #     RewriteCond %{HTTP:Connection} Upgrade [NC]
        #     RewriteCond %{HTTP:Upgrade} websocket [NC]
        #     RewriteRule /(.*) ws://10.245.101.35:9443/$1 [P,L]
        #ProxySet keepalive=On 
        #ProxyPass /  http://10.245.101.35:9000/
        #ProxyPass /  http://10.245.101.35:9000/
        #ProxyPass /  https://10.245.101.35:9443/ upgrade=websocket keepalive=on
        #ProxyPass /  https://10.245.101.35:9443/
        #ProxyPass /  https://localhost:8443/ upgrade=websocket keepalive=on
        ProxyPass /  https://localhost:8443/ upgrade=websocket
        SSLProxyEngine on
        SSLProxyVerify none 
        SSLProxyCheckPeerCN off
        SSLProxyCheckPeerName off
        SSLProxyCheckPeerExpire off
        #ProxyRequests Off
        ProxyPreserveHost On
        # proxy_http_version 1.1;
        RequestHeader set X-Forwarded-Proto "https"
        RequestHeader set X-Forwarded-Port "443"
        #KeepAlive On
        # RequestHeader set X-Forwarded-For "$proxy_add_x_forwarded_for
        # RequestHeader set Host $host
        # RequestHeader set Upgrade $http_upgrade
        # RequestHeader set Connection $connection_upgrade_keepalive
        ProxyPreserveHost On
        ProxyVia On
        ProxyAddHeaders On
        # <LimitExcept OPTIONS GET HEAD POST PUT DELETE TRACE CONNECT>
        #    Order allow,deny
        #    Allow from all
        # </LimitExcept>
    '';
  };
  services.httpd.virtualHosts."authentik.lesgrandsvoisins.com" = {
    serverAliases = [
      "auth.lesgv.com"
    ];
    enableACME = true;
    forceSSL = true;
    extraConfig = ''
        #ProxyPass /  http://10.245.101.35:9000/
        #ProxyPass /  http://10.245.101.35:9000/ 
        #ProxyPass /  https://localhost:8443/ upgrade=websocket keepalive=on
        ProxyPass /  https://localhost:8443/ upgrade=websocket
        #ProxyPass /  https://10.245.101.35:9443/
         #ProxySet keepalive=On 

        SSLProxyEngine on
        SSLProxyVerify none 
        SSLProxyCheckPeerCN off
        SSLProxyCheckPeerName off
        SSLProxyCheckPeerExpire off
        
        RequestHeader set X-Forwarded-Proto "https"
        RequestHeader set X-Forwarded-Port "443"
        # RequestHeader set X-Forwarded-For "$proxy_add_x_forwarded_for
        # RequestHeader set Host $host
        ProxyPreserveHost On
        ProxyVia On
        ProxyAddHeaders On
        <If "%{HTTP_HOST} != 'auth.lesgrandsvoisins.com'">
          RedirectMatch /(.*)$ https://auth.lesgrandsvoisins.com/$1
        </If>
    '';
  };
  services.httpd.virtualHosts."resdigita.com" = {
    serverAliases = ["resdigita.desgv.com" "resdigita.org"];
    documentRoot =  "/var/www/resdigitacom/";
    forceSSL = true;
    enableACME = true;
  };
  # services.httpd.virtualHosts."avmeet.com" = {
  #   enableACME = true;
  #   forceSSL = true;
  #   globalRedirect = "https://www.avmeet.com";
  # };
  # services.httpd.virtualHosts."davpass.desgv.com" = {
  #   enableACME = true;
  #   forceSSL = true;
  #   documentRoot = "/var/www/dav/";
  #   extraConfig = ''
  #     DavLockDB /tmp/DavLock
  #     <Location />
  #     AuthType Basic
  #     AuthBasicProvider ldap
  #     AuthName "DAV par LDAP"
  #     AuthLDAPBindDN cn=newuser@lesgv.com,ou=users,dc=resdigita,dc=org
  #     AuthLDAPBindPassword hxSXbHgnrwnIvu7XVsWE
  #     AuthLDAPURL "ldap:///ou=users,dc=resdigita,dc=org?cn?sub"
  #     </Location>
  #     <Location "/chris">
  #     #Require valid-user

  #     Require ldap-dn cn=chris@lesgrandsvoisins.com,ou=users,dc=resdigita,dc=org
  #     </Location>
  #     <Directory "/var/www/dav/">
  #       Dav On
  #     </Directory>
  #   '';
  # };

  # services.httpd.virtualHosts."www.shitmuststop.com" = {
  #   serverAliases = [
  #     "shitmuststop.com"
  #   ];
  #   enableACME = true;
  #   forceSSL = true;
  #   documentRoot =  "/var/www/wagtail/";
  #   extraConfig = ''
  #   <Location />
  #   Require all granted
  #   </Location>

  #   ProxyPass /.well-known !
  #   ProxyPass /static !
  #   ProxyPass /media !
  #   ProxyPass /favicon.ico !
  #   ProxyPass / unix:/var/lib/wagtail/wagtail-lesgv.sock|http://127.0.0.1/
  #   ProxyPassReverse / unix:/var/lib/wagtail/wagtail-lesgv.sock|http://127.0.0.1/
  #   ProxyPreserveHost On
  #   CacheDisable /
  #   <If "%{HTTP_HOST} != 'www.shitmuststop.com'">
  #       RedirectMatch /(.*)$ https://www.shitmuststop.com/$1
  #   </If>
  #   '';
  # };

  services.httpd.virtualHosts."secret.lesgrandsvoisins.com" = {
    enableACME = true;
    forceSSL = true;
    documentRoot = "/var/www/secret";
    extraConfig = ''
      Alias /static /var/www/wagtail/static
      Alias /media /var/www/wagtail/media
      DavLockDB /tmp/DavLockSecret
      OIDCProviderMetadataURL https://auth.lesgrandsvoisins.com/application/o/dav/.well-known/openid-configuration
      OIDCClientID V7p2o3hX6Im6crzdExLI1lb81zMJEjDO3mO3rNBk
      OIDCClientSecret Qgi9BFz7UOzwsJUAtN5Pa28sUL4oyrbkv2gvpsELMUgksPoLReS2eu9aHqJezyyoquJV02IX0UFPB8cvIB8uC9OW42MC4q8qswVeuM6aOUSvEXas1lQKnwAxad5sWrXc
      OIDCRedirectURI https://secret.lesgrandsvoisins.com/auth/redirect_uri_from_oauth2
      OIDCCryptoPassphrase JoWT5Mz1DIzsgI3MT2GH82aA6Xamp2ni
      <LocationMatch "^/(auth|pass|ldap|login)/(?<usernamedomain>[^/]+)/(?<usernameuser>[^/]+)/manifest.json$">
        Satisfy Any
        Allow from all
      </LocationMatch>
      <Location "/auth">
        AuthType openid-connect
        Require valid-user
      </Location>
      <Location "/redirect">
        AuthType openid-connect
        Require valid-user
        RewriteEngine On
        # Check for the presence of the OIDC_CLAIM_email header
        RewriteCond %{env:OIDC_CLAIM_sub} ^([^@]+)@(.+)$
        # Redirect to the specific path based on the header value
        RewriteRule ^(.*)$ /auth/keeweb/%2/%1 [R,L]
      </Location>
      <LocationMatch "^/auth/keeweb/(?<usernamedomain>[^/]+)/(?<usernameuser>[^/]+).*">
        AuthType openid-connect 
        # Should already be inherited
        # Allow https://httpd.apache.org/docs/2.4/mod/mod_dav.html
        Require claim sub:%{env:MATCH_USERNAMEUSER}@%{env:MATCH_USERNAMEDOMAIN}
        <LimitExcept OPTIONS GET HEAD POST PUT DELETE TRACE CONNECT>
           Require claim sub:%{env:MATCH_USERNAMEUSER}@%{env:MATCH_USERNAMEDOMAIN}
        </LimitExcept>
      </LocationMatch>
      <LocationMatch "^/auth/dav/(?<usernamedomain>[^/]+)/(?<usernameuser>[^/]+).*">
        AuthType openid-connect 
        # Should already be inherited
        # Allow https://httpd.apache.org/docs/2.4/mod/mod_dav.html
        Require claim sub:%{env:MATCH_USERNAMEUSER}@%{env:MATCH_USERNAMEDOMAIN}
        <LimitExcept OPTIONS GET HEAD POST PUT DELETE TRACE CONNECT>
           Require claim sub:%{env:MATCH_USERNAMEUSER}@%{env:MATCH_USERNAMEDOMAIN}
        </LimitExcept>
      </LocationMatch>
      <LocationMatch "^/pass/keeweb/(?<usernamedomain>[^/]+)/(?<usernameuser>[^/]+)">
        AuthType Basic
        AuthBasicProvider ldap
        AuthName "DAV par LDAP"
        AuthLDAPBindDN cn=newuser@lesgv.com,ou=users,dc=resdigita,dc=org
        AuthLDAPBindPassword hxSXbHgnrwnIvu7XVsWE
        AuthLDAPURL "ldap:///ou=users,dc=resdigita,dc=org?cn?sub"
        Require ldap-dn cn=%{env:MATCH_USERNAMEUSER}@%{env:MATCH_USERNAMEDOMAIN},ou=users,dc=resdigita,dc=org
        <LimitExcept OPTIONS GET HEAD POST PUT DELETE TRACE CONNECT>
          Require ldap-dn cn=%{env:MATCH_USERNAMEUSER}@%{env:MATCH_USERNAMEDOMAIN},ou=users,dc=resdigita,dc=org
        </LimitExcept>
      </LocationMatch>
      <LocationMatch "^/pass/dav/(?<usernamedomain>[^/]+)/(?<usernameuser>[^/]+)">
        AuthType Basic
        AuthBasicProvider ldap
        AuthName "DAV par LDAP"
        AuthLDAPBindDN cn=newuser@lesgv.com,ou=users,dc=resdigita,dc=org
        AuthLDAPBindPassword hxSXbHgnrwnIvu7XVsWE
        AuthLDAPURL "ldap:///ou=users,dc=resdigita,dc=org?cn?sub"
        Require ldap-dn cn=%{env:MATCH_USERNAMEUSER}@%{env:MATCH_USERNAMEDOMAIN},ou=users,dc=resdigita,dc=org
        <LimitExcept OPTIONS GET HEAD POST PUT DELETE TRACE PROPFIND CONNECT>
          Require ldap-dn cn=%{env:MATCH_USERNAMEUSER}@%{env:MATCH_USERNAMEDOMAIN},ou=users,dc=resdigita,dc=org
        </LimitExcept>
      </LocationMatch>
      <LocationMatch ^/$>
          Redirect /redirect
      </LocationMatch>

      AliasMatch "^/(auth|pass)/keeweb/([^/]+/[^/]+)/dav/(.*)" "/var/www/secret/dav/$2/$3"
      AliasMatch "^/(auth|pass)/keeweb/([^/]+/[^/]+)(.*)" "/var/www/secret/keeweb$3"

      Alias /auth/dav /var/www/secret/dav
      Alias /pass/dav /var/www/secret/dav

      <Directory "/var/www">
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
      </Directory>

      <Directory "/var/www/secret/dav">
        Dav On
        DavDepthInfinity On
      </Directory>

    '';
  };

  services.httpd.virtualHosts."dav.lesgrandsvoisins.com" = {
    # serverAliases = ["dav.lesgrandsvoisins.com"];
    enableACME = true;
    forceSSL = true;
    documentRoot = "/var/www/dav";
    # extraConfig = ''
    # ProxyPass / http://10.245.101.35:8080/
    # ProxyPassReverse / http://10.245.101.35:8080/
    # RequestHeader set X-Forwarded-Proto "https"
    # RequestHeader set X-Forwarded-Port "443"
    # ProxyPreserveHost On
    # ProxyVia On
    # ProxyAddHeaders On

    # CacheDisable /

    # '';
    extraConfig = lib.strings.concatStrings [ ''
      Alias /static /var/www/wagtail/static
      Alias /media /var/www/wagtail/media
    ''
    # wagtailExtraConfig
    ''
      DavLockDB /tmp/DavLock

        OIDCProviderMetadataURL https://auth.lesgrandsvoisins.com/application/o/dav/.well-known/openid-configuration
        OIDCClientID V7p2o3hX6Im6crzdExLI1lb81zMJEjDO3mO3rNBk
        OIDCClientSecret Qgi9BFz7UOzwsJUAtN5Pa28sUL4oyrbkv2gvpsELMUgksPoLReS2eu9aHqJezyyoquJV02IX0UFPB8cvIB8uC9OW42MC4q8qswVeuM6aOUSvEXas1lQKnwAxad5sWrXc
        OIDCRedirectURI https://dav.lesgrandsvoisins.com/auth/redirect_uri_from_oauth2
        OIDCCryptoPassphrase JoWT5Mz1DIzsgI3MT2GH82aA6Xamp2ni

        RedirectMatch ^/?$ /redirect

        <Location "/auth">
          AuthType openid-connect
          Require valid-user
        </Location>

        <LocationMatch "^/auth/(?<usernamedomain>[^/]+)/(?<usernameuser>[^/]+).*">
          AuthType openid-connect
          Require claim sub:%{env:MATCH_USERNAMEUSER}@%{env:MATCH_USERNAMEDOMAIN}
            
          <LimitExcept OPTIONS GET HEAD POST PUT DELETE TRACE PROPOFIND CONNECT>
             Require claim sub:%{env:MATCH_USERNAMEUSER}@%{env:MATCH_USERNAMEDOMAIN}
          </LimitExcept>
        </LocationMatch>

      <Location "/redirect">
        AuthType openid-connect
        Require valid-user
        RewriteEngine On
        # Check for the presence of the OIDC_CLAIM_email header
        RewriteCond %{env:OIDC_CLAIM_sub} ^([^@]+)@(.+)$
        # Redirect to the specific path based on the header value
        RewriteRule ^(.*)$ /auth/%2/%1 [R,L]
      </Location>
      



        Alias /ldap /var/www/dav/data
        Alias /auth /var/www/dav/data
        Alias /pass /var/www/dav/data
        Alias /login /var/www/dav/data

        <LocationMatch "^/(ldap|pass|login)/(?<usernamedomain>[^/]+)/(?<usernameuser>[^/]+)">
          AuthType Basic
          AuthBasicProvider ldap
          AuthName "DAV par LDAP"
          AuthLDAPBindDN cn=newuser@lesgv.com,ou=users,dc=resdigita,dc=org
          AuthLDAPBindPassword hxSXbHgnrwnIvu7XVsWE
          AuthLDAPURL "ldap:///ou=users,dc=resdigita,dc=org?cn?sub"
          #Require valid-user
          Require ldap-dn cn=%{env:MATCH_USERNAMEUSER}@%{env:MATCH_USERNAMEDOMAIN},ou=users,dc=resdigita,dc=org
          
          <LimitExcept OPTIONS GET HEAD POST PUT DELETE TRACE PROPFIND CONNECT>
            Require ldap-dn cn=%{env:MATCH_USERNAMEUSER}@%{env:MATCH_USERNAMEDOMAIN},ou=users,dc=resdigita,dc=org
          </LimitExcept>
        </LocationMatch>

        <Directory "/var/www">
          Options Indexes FollowSymLinks
          AllowOverride None
          Require all granted
        </Directory>

        # <Directory "/var/www/wagtail">
        # Options Indexes FollowSymLinks
        # AllowOverride None
        # Require all granted
        # </Directory>

      <Directory "/var/www/dav/data">
        Dav On
        DavDepthInfinity On
      </Directory>
      ''];
  };

  # services.httpd.virtualHosts."lesgrandsvoisins.com" = {
  #   documentRoot = "/var/www/wagtail/";
  #   enableACME = true;
  #   forceSSL = true;
  #   extraConfig = ''
  #     RedirectMatch /(.*)$ https://www.lesgrandsvoisins.com/$1
  #   '';
  # };
  services.httpd.virtualHosts."www.lesgrandsvoisins.fr" = {
     serverAliases = ["desgv.com" "www.lesgrandsvoisins.fr"  "francemali.org"
      "www.francemali.org" "shitmuststop.com" "www.shitmuststop.com" "www.desgv.com" "lesgrandsvoisins.fr"  "hopgv.com" "www.hopgv.com"  "www.lesgv.com" "lesgv.com"];
    documentRoot = "/var/www/wagtail/";
    enableACME = true;
     forceSSL = true;
         extraConfig = lib.strings.concatStrings [ wagtailExtraConfig ''
      <If "%{HTTP_HOST} == 'desgv.com'">
          RedirectMatch /(.*)$ https://www.desgv.com/$1
      </If>
      <If "%{HTTP_HOST} == 'francemali.org'">
          RedirectMatch /(.*)$ https://www.francemali.org/$1
      </If>
      <If "%{HTTP_HOST} == 'lesgv.com'">
          RedirectMatch /(.*)$ https://www.lesgv.com/$1
      </If>
      <If "%{HTTP_HOST} == 'lesgrandsvoisins.fr' || %{HTTP_HOST} == 'www.lesgrandsvoisins.fr' || %{HTTP_HOST} =~ /(www.)?lesgv.com/ || %{HTTP_HOST} =~ /(www.)?hopgv.com/">
          RedirectMatch /(.*)$ https://www.lesgrandsvoisins.com/$1
      </If>
        ProxyPreserveHost On
        CacheDisable /
    ''];
  };
  services.httpd.virtualHosts."www.lesgrandsvoisins.com" = {
    documentRoot = "/var/www/wagtail/";
    serverAliases = ["lesgrandsvoisins.com" ];
    forceSSL = true;
    # enableACME = true;
    # addSSL = true;
    sslServerKey = "/etc/ssl/lesgrandsvoisins.com.key";
    sslServerCert = "/etc/ssl/lesgrandsvoisins.com.crt";
    sslServerChain = "/etc/ssl/lesgrandsvoisins.com.ca-bundle";
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
      <If "%{HTTP_HOST} != 'www.lesgrandsvoisins.com'">
          RedirectMatch /(.*)$ https://www.lesgrandsvoisins.com/$1
      </If>
    ''];
    locations."/auth" = {
      # proxyPass = "https://localhost:8443/ upgrade=websocket";
      extraConfig = ''

        ProxyPass https://localhost:8443/ upgrade=websocket

        SSLProxyEngine on
        SSLProxyVerify none 
        SSLProxyCheckPeerCN off
        SSLProxyCheckPeerName off
        SSLProxyCheckPeerExpire off
        
        RequestHeader set X-Forwarded-Proto "https"
        RequestHeader set X-Forwarded-Port "443"
        ProxyPreserveHost On
        ProxyVia On
        ProxyAddHeaders On
      '';
    };
  #   locations."/blog/static".proxyPass = null;
  #   locations."/blog/media".proxyPass = null;
  #   locations."/blog" = {
  #     alias =  "/var/www/ghostio/";
  #     extraConfig = ''
  #     Require all granted

  #     # ProxyPass /.well-known !
  #     # ProxyPass /static !
  #     # ProxyPass /media !
  #     # ProxyPass /favicon.ico !
  #     ProxyPass http://localhost:2368/
  #     # ProxyPassReverse http://localhost:2368/
  #     RequestHeader set X-Forwarded-Proto "https"
  #     RequestHeader set X-Forwarded-Port "443"
  #     ProxyPreserveHost On
  #     ProxyVia On
  #     ProxyAddHeaders On

  #     # CacheDisable 
  #   '';
  #   };
  };
  # services.httpd.virtualHosts."blog.gvois.in" = {
  #   serverAliases = [
  #     "ghost.gvois.in"
  #     "blog.lesgrandsvoisins.com"
  #   ];
  services.httpd.virtualHosts."blog.lesgrandsvoisins.com" = {
    serverAliases = ["blog.gvois.in"];
    enableACME = true;
    forceSSL = true;
    documentRoot =  "/var/www/ghostio/";
    extraConfig = ''
    <Location />
    Require all granted
    </Location>
    # ProxyPass /.well-known !
    # ProxyPass /static !
    # ProxyPass /media !
    # ProxyPass /favicon.ico !
    ProxyPass / http://localhost:2368/
    # ProxyPassReverse / http://localhost:2368/
    RequestHeader set X-Forwarded-Proto "https"
    RequestHeader set X-Forwarded-Port "443"
    ProxyPreserveHost On
    ProxyVia On
    ProxyAddHeaders On

    CacheDisable /

    <If "%{HTTP_HOST} != 'blog.lesgrandsvoisins.com'">
      RedirectMatch /(.*)$ https://blog.lesgrandsvoisins.com/$1
    </If>
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
#    ProxyPass / http://10.245.101.35:8069/
#    ProxyPassReverse / http://10.245.101.35:8069/
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
       ProxyRequests On
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
      "maelanc.com"
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
#        ProxyPass http://10.245.101.35:8888/
#        # ProxyPassReverse http://10.245.101.35:8888/
#        ProxyPreserveHost On
#        </Location>
#
#        <Location /media/>
#        ProxyPass http://10.245.101.35:8889/
#        # ProxyPassReverse http://10.245.101.35:8889/
#        ProxyPreserveHost On
#        </Location>

    ProxyPass /.well-known !
    ProxyPass /static !
    ProxyPass /media !
    ProxyPass /favicon.ico !
        ProxyPass /  unix:/var/lib/wagtail/wagtail-lesgv.sock|http://127.0.0.1/
        ProxyPassReverse / unix:/var/lib/wagtail/wagtail-lesgv.sock|http://127.0.0.1/
        # ProxyPassReverse / http://10.245.101.35:8080/
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