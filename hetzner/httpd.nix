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
    ProxyPass /  http://127.0.0.1:8008/
    # ProxyPassReverse /  http://127.0.0.1:8000/
    ProxyPreserveHost On
    ProxyVia On
    ProxyAddHeaders On
    RequestHeader set X-Original-URL "expr=%{THE_REQUEST}"
    RequestHeader edit* X-Original-URL ^[A-Z]+\s|\sHTTP/1\.\d$ ""
    # RequestHeader set X-Forwarded-Proto "https"
    # RequestHeader set X-Forwarded-Port "443"
  '';
  fileBrowserSecret = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.filebrowser));
  keewebSecret = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.keeweb));
  keewebSecretPassphrase = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.keeweb.passphrase));
  keepasswebSecretPassphrase = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.keepassweb.passphrase));
  httpd-radicale-oidcclientsecret = builtins.readFile /etc/nixos/.secrets.httpd.radicale.oidcclientsecret;
  httpd-dav-oidcclientsecret = builtins.readFile /etc/nixos/.secrets.httpd.dav.oidcclientsecret;
  SECRETS_NEWUSER_PASSWORD = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.newuser));           
  keepasswebSecret = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.keepassweb));
  chrisSecret = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.chris));
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
  services.httpd.adminAddr = "chris@lesgrandsvoisins.com";
  services.httpd.extraModules = [ "proxy" "proxy_http" "dav" "ldap" "authnz_ldap" "alias" "ssl" "rewrite" "proxy_fcgi" "http2" "proxy_uwsgi"
    { name = "auth_openidc"; path = "/usr/local/lib/modules/mod_auth_openidc.so"; }
     ];
  users.users.wwwrun.extraGroups = [ "acme" "wagtail" "users" "ghost" "ghostio" "guichet" ];
   
  services.httpd.virtualHosts = {
     "maruftuyel.resdigita.com" = {
      listen = [{port = 8443; ssl=true;}];
      sslServerCert = "/var/lib/acme/maruftuyel.resdigita.com/fullchain.pem";
      sslServerChain = "/var/lib/acme/maruftuyel.resdigita.com/fullchain.pem";
      sslServerKey = "/var/lib/acme/maruftuyel.resdigita.com/key.pem";
      documentRoot = "/var/www/wagtail";
      extraConfig = ''
        ProxyPreserveHost On
        # ProxyVia On
        ProxyAddHeaders On
        OIDCProviderMetadataURL https://keycloak.village.ngo/realms/master/.well-known/openid-configuration
        OIDCClientID filebrowser
        OIDCClientSecret ${fileBrowserSecret}
        OIDCRedirectURI https://maruftuyel.resdigita.com/redirect_uri_from_oauth2
        OIDCCryptoPassphrase UMU0I51HADokJraIaBSjpI89zhnGjuhv
        <Location "/">
          AuthType openid-connect
          Require valid-user
          ProxyPass unix:/opt/filebrowser/dbs/filebrowser/maruftuyel/filebrowser.sock|http://127.0.0.1/
          # ProxyPass unix:/opt/filebrowser/dbs/filebrowser/%{env:MATCH_USERNAME}/filebrowser.sock|http://filebrowser.resdigita.com/
          RequestHeader set FileBrowserUser %{env:OIDC_CLAIM_username}s  
          RequestHeader set X-Forwarded-Proto "https"
          RequestHeader set X-Forwarded-Port "443"
          RequestHeader set X-Forwarded-For "$proxy_add_x_forwarded_for"
          RequestHeader set Host $host
        </Location>
      '';
    };
    "axel.resdigita.com" = {
      listen = [{port = 8443; ssl=true;}];
      sslServerCert = "/var/lib/acme/axel.resdigita.com/fullchain.pem";
      sslServerChain = "/var/lib/acme/axel.resdigita.com/fullchain.pem";
      sslServerKey = "/var/lib/acme/axel.resdigita.com/key.pem";
      documentRoot = "/var/www/wagtail";
      extraConfig = ''
        ProxyPreserveHost On
        # ProxyVia On
        ProxyAddHeaders On
        ProxyRequests Off
        OIDCProviderMetadataURL https://keycloak.village.ngo/realms/master/.well-known/openid-configuration
        OIDCClientID filebrowser
        OIDCClientSecret ${fileBrowserSecret}
        OIDCRedirectURI https://axel.resdigita.com/redirect_uri_from_oauth2
        OIDCCryptoPassphrase UMU0I51HADokJraIaBSjpI89zhnGjuhv
        <Location "/">
          AuthType openid-connect
          Require valid-user
          # Require user axel.leroux
          ProxyPass unix:/opt/filebrowser/dbs/filebrowser/axel.leroux/filebrowser.sock|http://127.0.0.1/
          # ProxyPass unix:/opt/filebrowser/dbs/filebrowser/%{env:MATCH_USERNAME}/filebrowser.sock|http://filebrowser.resdigita.com/
          RequestHeader set FileBrowserUser %{env:OIDC_CLAIM_username}s  
          RequestHeader set X-Forwarded-Proto "https"
          RequestHeader set X-Forwarded-Port "443"
          RequestHeader set X-Forwarded-For "$proxy_add_x_forwarded_for"
          RequestHeader set Host $host
        </Location>
      '';
    };
    "chris.resdigita.com" = {
      listen = [{port = 8443; ssl=true;}];
      sslServerCert = "/var/lib/acme/chris.resdigita.com/fullchain.pem";
      sslServerChain = "/var/lib/acme/chris.resdigita.com/fullchain.pem";
      sslServerKey = "/var/lib/acme/chris.resdigita.com/key.pem";
      documentRoot = "/var/www/wagtail";
      extraConfig = ''
        ProxyPreserveHost On
        # ProxyVia On
        ProxyAddHeaders On
        OIDCProviderMetadataURL https://keycloak.village.ngo/realms/master/.well-known/openid-configuration
        OIDCClientID filebrowser
        OIDCClientSecret ${fileBrowserSecret}
        OIDCRedirectURI https://chris.resdigita.com/redirect_uri_from_oauth2
        OIDCCryptoPassphrase UMU0I51HADokJraIaBSjpI89zhnGjuhv
        <Location "/">
          AuthType openid-connect
          Require valid-user
          ProxyPass unix:/opt/filebrowser/dbs/filebrowser/chris/filebrowser.sock|http://127.0.0.1/
          # ProxyPass unix:/opt/filebrowser/dbs/filebrowser/%{env:MATCH_USERNAME}/filebrowser.sock|http://filebrowser.resdigita.com/
          RequestHeader set FileBrowserUser %{env:OIDC_CLAIM_username}s  
          RequestHeader set X-Forwarded-Proto "https"
          RequestHeader set X-Forwarded-Port "443"
          RequestHeader set X-Forwarded-For "$proxy_add_x_forwarded_for"
          RequestHeader set Host $host
        </Location>
      '';
    };
    "filebrowser.resdigita.com" = {
      listen = [{port = 8443; ssl=true;}];
      sslServerCert = "/var/lib/acme/filebrowser.resdigita.com/fullchain.pem";
      sslServerChain = "/var/lib/acme/filebrowser.resdigita.com/fullchain.pem";
      sslServerKey = "/var/lib/acme/filebrowser.resdigita.com/key.pem";
      documentRoot = "/var/www/wagtail";
      extraConfig = ''
        ProxyPreserveHost On
        # ProxyVia On
        ProxyAddHeaders On
        ProxyRequests Off
        OIDCProviderMetadataURL https://keycloak.village.ngo/realms/master/.well-known/openid-configuration
        OIDCClientID filebrowser
        OIDCClientSecret ${fileBrowserSecret}
        OIDCRedirectURI https://filebrowser.resdigita.com/redirect_uri_from_oauth2
        OIDCCryptoPassphrase UMU0I51HADokJraIaBSjpI89zhnGjuhv
        # <LocationMatch "^/u/redirect$">
        #   AuthType openid-connect
        #   Require valid-user
        #   # RewriteEngine On
        #   # Redirect to the specific path based on the header value
        #   # RewriteRule ^(.*)$ /u/%{env:OIDC_CLAIM_username}/ [R,L]
        # </LocationMatch>      
        # <LocationMatch "/u/(?<username>[^/]+)/">
        <Location "/">
          AuthType openid-connect
          Require valid-user
          ProxyPass unix:/opt/filebrowser/dbs/filebrowser/multi-user/filebrowser.sock|http://127.0.0.1/
          RequestHeader set FileBrowserUser %{env:OIDC_CLAIM_username}s  
          RequestHeader set X-Forwarded-Proto "https"
          RequestHeader set X-Forwarded-Port "443"
          RequestHeader set X-Forwarded-For "$proxy_add_x_forwarded_for"
          RequestHeader set Host $host
        </Location>
        # <LocationMatch "^/u/(?<username>[^/]+)">
        #   AuthType openid-connect
        #   Require valid-user      
        #   ProxyPass unix:/opt/filebrowser/dbs/filebrowser/%{env:MATCH_USERNAME}/filebrowser.sock|http://127.0.0.1/
        #   RequestHeader set FileBrowserUser %{env:OIDC_CLAIM_username}s  
        #   RequestHeader set X-Forwarded-Proto "https"
        #   RequestHeader set X-Forwarded-Port "443"
        #   RequestHeader set X-Forwarded-For "$proxy_add_x_forwarded_for"
        #   RequestHeader set Host $host
        # </LocationMatch>
        # </LocationMatch>
        # <LocationMatch ^/(u/)?$>
        #     Redirect /u/redirect
        # </LocationMatch>
        # <Location "/u">
        #   AuthType openid-connect
        #   Require valid-user
        #   # ProxyPass unix:/opt/filebrowser/dbs/filebrowser/filebrowser/filebrowser.sock|http://filebrowser.resdigita.com/
        #   # ProxyPass "http://filebrowser.resdigita.com:8334/"
        #   # RequestHeader set FileBrowserUser "admin"   
        #   RequestHeader set FileBrowserUser %{env:OIDC_CLAIM_username}s  
        #   # RequestHeader set FileBrowserUser "admin"        
        #   RequestHeader set X-Forwarded-Proto "https"
        #   RequestHeader set X-Forwarded-Port "443"
        #   RequestHeader set X-Forwarded-For "$proxy_add_x_forwarded_for"
        #   RequestHeader set Host $host
        #   #RequestHeader set Upgrade $http_upgrade
        #   #RequestHeader set Connection $connection_upgrade_keepalive
        # </Location>
      '';
    };
    "keeweb.resdigita.com" = {
      listen = [{port = 8443; ssl=true;}];

      sslServerCert = "/var/lib/acme/keeweb.resdigita.com/fullchain.pem";
      sslServerChain = "/var/lib/acme/keeweb.resdigita.com/fullchain.pem";
      sslServerKey = "/var/lib/acme/keeweb.resdigita.com/key.pem";
      
      documentRoot = "/var/www";
      
      extraConfig = ''
        Alias /static /var/www/wagtail/static
        Alias /media /var/www/wagtail/media
        # User access to own password files
        AliasMatch "^/([^/]+)/dav/(.*)" "/var/keepass/dav/$1/$2"
        # User acces to web application
        AliasMatch "^/([^/]+)/(.+)$" "/var/www/keeweb/$2"

        DavLockDB /tmp/DavLockKeeWeb

        OIDCProviderMetadataURL https://keycloak.village.ngo/realms/master/.well-known/openid-configuration
        OIDCClientID keeweb
        OIDCClientSecret ${keewebSecret}
        OIDCRedirectURI https://keeweb.resdigita.com/redirect_uri_from_oauth2
        OIDCCryptoPassphrase ${keewebSecretPassphrase}
        
        <LocationMatch "^/redirect$">
          AuthType openid-connect
          Require valid-user
          RewriteEngine on
          RewriteCond %{env:OIDC_CLAIM_username} ^(.+)$
          RewriteRule ^(.*)$ /%1/index.html [R,L]
        </LocationMatch>
        <Location "/">
          AuthType openid-connect
          Require valid-user
        </Location>

        <LocationMatch "^/(?<username>[^/]+)/manifest.json$">
          Satisfy Any
          Allow from all
        </LocationMatch>

        <LocationMatch "^/(?<username>[^/]+)/.*">
          AuthType openid-connect 
          Require claim username:%{env:MATCH_USERNAME}
          <LimitExcept OPTIONS GET HEAD POST PUT DELETE TRACE CONNECT>
             Require claim useername:%{env:MATCH_USERNAME}
          </LimitExcept>
        </LocationMatch>
        <LocationMatch ^/$>
            Redirect /redirect
        </LocationMatch>

        <Directory "/var/keepass">
          Options +Indexes +FollowSymLinks
          AllowOverride None
          Require all granted
          DirectoryIndex index.html
        </Directory>

        <Directory "/var/www">
          # Options +Indexes +FollowSymLinks
          # AllowOverride None
          # Require all granted
          # DirectoryIndex index.html
          Options Indexes FollowSymLinks
          AllowOverride None
          Require all granted
        </Directory>

        <Directory "/var/keepass/dav">
          Dav On
          DavDepthInfinity On
          Options +Indexes +FollowSymLinks
          # AllowOverride None
          Require all granted
        </Directory>
      '';
    };   
    "keepass.resdigita.com" = {
      listen = [{port = 8443; ssl=true;}];
      sslServerCert = "/var/lib/acme/keepass.resdigita.com/fullchain.pem";
      sslServerChain = "/var/lib/acme/keepass.resdigita.com/fullchain.pem";
      sslServerKey = "/var/lib/acme/keepass.resdigita.com/key.pem";
      documentRoot = "/var/www/secret";
      extraConfig = ''
        Alias /static /var/www/wagtail/static
        Alias /media /var/www/wagtail/media
        DavLockDB /tmp/DavLockSecret
        OIDCProviderMetadataURL https://keycloak.village.ngo/realms/master/.well-known/openid-configuration
        OIDCClientID keepassweb
        OIDCClientSecret  ${keepasswebSecret}
        OIDCRedirectURI https://keepass.resdigita.com/auth/redirect_uri_from_oauth2
        OIDCCryptoPassphrase ${keepasswebSecretPassphrase}
        <LocationMatch "^/(auth|pass|ldap|login)/(?<username>[^/]+)/manifest.json$">
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
          # RewriteCond %{env:OIDC_CLAIM_email} ^([^@]+)@(.+)$
          # Redirect to the specific path based on the header value
          # RewriteRule ^(.*)$ /auth/web/%2/%1 [R,L]
          # RewriteCond %{env:OIDC_CLAIM_username} ^(.+)$
          RewriteCond %{env:OIDC_CLAIM_preferred_username} ^(.+)$
          RewriteRule ^(.*)$ /auth/web/%1 [R,L]
        </Location>
        <LocationMatch "^/auth/web/(?<username>[^/]+)">
          AuthType openid-connect 
          # Should already be inherited
          # Allow https://httpd.apache.org/docs/2.4/mod/mod_dav.html
          # Require claim username:%{env:MATCH_USERNAME}
          Require claim preferred_username:%{env:MATCH_USERNAME}
          <LimitExcept OPTIONS GET HEAD POST PUT DELETE TRACE CONNECT>
             # Require claim username:%{env:MATCH_USERNAME}
             Require claim preferred_username:%{env:MATCH_USERNAME}
          </LimitExcept>
        </LocationMatch>
        # <LocationMatch "^/auth/dav/(?<username>[^/]+).*">
        # Require claim email:%{env:MATCH_USERNAME}@%{env:MATCH_USERNAMEDOMAIN}
        <LocationMatch "^/auth/dav/(?<username>[^/]+)">
          AuthType openid-connect 
          # Should already be inherited
          # Allow https://httpd.apache.org/docs/2.4/mod/mod_dav.html
          Require claim username:%{env:MATCH_USERNAME}
          <LimitExcept OPTIONS GET HEAD POST PUT DELETE TRACE CONNECT>
             Require claim username:%{env:MATCH_USERNAME}
          </LimitExcept>
        </LocationMatch>
        <LocationMatch "^/pass/web/(?<username>[^/]+)">
          AuthType Basic
          AuthBasicProvider ldap
          AuthName "DAV par LDAP"
          AuthLDAPBindDN cn=newuser,ou=users,dc=resdigita,dc=org
          AuthLDAPBindPassword ${SECRETS_NEWUSER_PASSWORD}
          AuthLDAPURL "ldaps://ldap.lesgrandsvoisins.com:14636/ou=users,dc=lesgrandsvoisins,dc=com?cn"
          # Require valid-user
          Require ldap-attribute cn=%{env:MATCH_USERNAME}
          <LimitExcept OPTIONS GET HEAD POST PUT DELETE TRACE CONNECT>
            # Require valid-user
            Require ldap-attribute cn=%{env:MATCH_USERNAME}
          </LimitExcept>
        </LocationMatch>
        <LocationMatch "^/pass/dav/(?<username>[^/]+)">
          AuthType Basic
          AuthBasicProvider ldap
          AuthName "DAV par LDAP"
          AuthLDAPBindDN cn=newuser,ou=users,dc=resdigita,dc=org
          AuthLDAPBindPassword ${SECRETS_NEWUSER_PASSWORD}
          AuthLDAPURL "ldaps://ldap.lesgrandsvoisins.com:14636/ou=users,dc=lesgrandsvoisins,dc=com?cn"
          # Require ldap-dn cn=%{env:MATCH_USERNAME},ou=users,dc=resdigita,dc=org
          # Require valid-user
          Require ldap-attribute cn=%{env:MATCH_USERNAME}
          <LimitExcept OPTIONS GET HEAD POST PUT DELETE TRACE PROPFIND CONNECT>
            # Require valid-user
            Require ldap-attribute cn=%{env:MATCH_USERNAME}
          </LimitExcept>
        </LocationMatch>
        <LocationMatch ^/$>
            Redirect /redirect
        </LocationMatch>

        AliasMatch "^/(auth|pass)/web/([^/]+)/dav/(.*)" "/var/keepass/dav/$2/$3"
        AliasMatch "^/(auth|pass)/web/([^/]+)(.*)" "/var/www/secret/keeweb$3"

        Alias /auth/dav /var/keepass/dav
        Alias /pass/dav /var/keepass/dav

        # AliasMatch "^/(auth|pass)/web/([^/]+)/dav/(.*)" "/var/www/secret/dav/$2/$3"
        # AliasMatch "^/(auth|pass)/web/([^/]+)(.*)" "/var/www/secret/keeweb$3"

        # Alias /auth/dav /var/www/secret/dav
        # Alias /pass/dav /var/www/secret/dav

        <Directory "/var/www">
          Options Indexes FollowSymLinks
          AllowOverride None
          Require all granted
        </Directory>

        <Directory "/var/keepass/dav">
          Dav On
          DavDepthInfinity On
        </Directory>

      '';
    };
    "radicale.resdigita.com" = {
      listen = [{port = 8443; ssl=true;}];
      documentRoot = "/var/www/radicale";

      sslServerCert = "/var/lib/acme/radicale.resdigita.com/fullchain.pem";
      sslServerChain = "/var/lib/acme/radicale.resdigita.com/fullchain.pem";
      sslServerKey = "/var/lib/acme/radicale.resdigita.com/key.pem";
      extraConfig = ''
        Alias /auth /var/www/radicale
        RedirectMatch ^/$ https://radicale.resdigita.com/auth/
        OIDCProviderMetadataURL https://keycloak.village.ngo/realms/master/.well-known/openid-configuration
        OIDCClientID radicale
        OIDCClientSecret ${httpd-radicale-oidcclientsecret}
        OIDCRedirectURI https://radicale.resdigita.com/auth/keycloak-radicale-openid
        OIDCCryptoPassphrase jksdjflskfjslkfjSAFSAFDSADF
        OIDCRemoteUserClaim username
        RewriteEngine On
        RewriteRule ^/auth$ /auth/ [R,L]
        RewriteRule ^/pass$ /pass/ [R,L]
        <Location "/auth/index.html">
          ProxyPass !
          AuthType openid-connect
          Require valid-user
        </Location>
        <Location "/auth/">
          AuthType openid-connect
          Require valid-user
          RequestHeader    set X-Script-Name /auth
          RequestHeader    set X-Remote-User expr=%{env:OIDC_CLAIM_username}
          ProxyPass        http://localhost:5232/ retry=0
          ProxyPassReverse http://localhost:5232/
          ProxyAddHeaders On
          # ProxyPass uwsgi://localhost:5232/
       </Location>
      #  <LocationMatch "/pass/(?<username>[^/]+)">
      #       AuthType Basic
      #       AuthBasicProvider ldap
      #       AuthName "Radicale CalDAV et CardDAV par LDAP"
      #       AuthLDAPBindDN cn=newuser,ou=users,dc=resdigita,dc=org
      #       AuthLDAPBindPassword ${SECRETS_NEWUSER_PASSWORD}
      #       AuthLDAPURL "ldaps://ldap.lesgrandsvoisins.com:14636/ou=users,dc=lesgrandsvoisins,dc=com?cn"
      #       #Require valid-user
      #       Require ldap-dn cn=%{env:MATCH_USERNAME},ou=users,dc=resdigita,dc=org

      #     RequestHeader    set X-Script-Name /radicale
      #     RequestHeader    set X-Remote-User expr=%{env:MATCH_USERNAME}
      #     ProxyPass        http://localhost:5232/ retry=0
      #     ProxyPassReverse http://localhost:5232/
      #  </LocationMatch>
       <Location "/pass/">
            AuthType Basic
            AuthBasicProvider ldap
            AuthName "Radicale CalDAV et CardDAV par LDAP"
            AuthLDAPBindDN cn=newuser,ou=users,dc=resdigita,dc=org
            AuthLDAPBindPassword ${SECRETS_NEWUSER_PASSWORD}
            AuthLDAPURL "ldaps://ldap.lesgrandsvoisins.com:14636/ou=users,dc=lesgrandsvoisins,dc=com?cn"
            AuthLDAPRemoteUserAttribute cn
            Require valid-user
            #Require ldap-dn cn=%{env:MATCH_USERNAME},ou=users,dc=resdigita,dc=org

          RequestHeader    set X-Script-Name /pass
          RequestHeader    set X-Remote-User expr=%{env:AUTHENTICATE_cn}
          ProxyAddHeaders On
          ProxyPass        http://localhost:5232/ retry=0
          ProxyPassReverse http://localhost:5232/
       </Location>
      '';
    };
    
    "dav.lesgrandsvoisins.com" = {
      listen = [{port = 8443; ssl=true;}];
      sslServerCert = "/var/lib/acme/dav.lesgrandsvoisins.com/fullchain.pem";
      sslServerChain = "/var/lib/acme/dav.lesgrandsvoisins.com/fullchain.pem";
      sslServerKey = "/var/lib/acme/dav.lesgrandsvoisins.com/key.pem";
      documentRoot = "/var/www/dav";
      extraConfig = ''
        Alias /static /var/www/wagtail/static
        Alias /media /var/www/wagtail/media
        DavLockDB /tmp/DesGVDavLock

        OIDCProviderMetadataURL https://key.lesgrandsvoisins.com/realms/master/.well-known/openid-configuration
        OIDCClientID dav
        OIDCClientSecret ${httpd-dav-oidcclientsecret}
        OIDCRedirectURI https://dav.lesgrandsvoisins.com/auth/redirect_uri_from_oauth2
        OIDCCryptoPassphrase JoWT5Mz1DIzsgI3MT2GH82aA6Xamp2ni

        RedirectMatch ^/?$ /redirect

        <Location "/auth">
          AuthType openid-connect
          Require valid-user
        </Location>

        <LocationMatch "^/auth/(?<username>[^/]+)">
          AuthType openid-connect
          Require claim preferred_username:%{env:MATCH_USERNAME}
            
          <LimitExcept OPTIONS GET HEAD POST PUT DELETE TRACE PROPOFIND CONNECT>
              Require claim preferred_username:%{env:MATCH_USERNAME}
          </LimitExcept>
        </LocationMatch>

        <Location "/redirect">
          AuthType openid-connect
          Require valid-user
          RewriteEngine On
          # Check for the presence of the OIDC_CLAIM_email header
          # RewriteCond %{env:OIDC_CLAIM_email} ^(.+)$
          RewriteCond %{env:OIDC_CLAIM_preferred_username} ^(.+)$
          # Redirect to the specific path based on the header value
          RewriteRule ^(.*)$ /auth/%1 [R,L]
        </Location>
        RedirectMatch ^/$ /redirect
      
        Alias /auth /var/www/dav/data
        Alias /pass /var/www/dav/data

        <LocationMatch "^/pass/(?<username>[^/]+)">
          AuthType Basic
          AuthBasicProvider ldap
          AuthName "DAV par LDAP"
          AuthLDAPBindDN cn=newuser,ou=users,dc=lesgrandsvoisins,dc=com
          AuthLDAPBindPassword ${SECRETS_NEWUSER_PASSWORD}
          AuthLDAPURL "ldaps://ldap.lesgrandsvoisins.com:14636/ou=users,dc=lesgrandsvoisins,dc=com?cn"
          # Require valid-user
          # Require ldap-dn cn=%{env:MATCH_USERNAME},ou=users,dc=lesgrandsvoisins,dc=com
          Require ldap-attribute cn=%{env:MATCH_USERNAME}
          
          <LimitExcept OPTIONS GET HEAD POST PUT DELETE TRACE PROPFIND CONNECT>
            # Require ldap-dn cn=%{env:MATCH_USERNAME},ou=users,dc=lesgrandsvoisins,dc=com
            Require ldap-attribute cn=%{env:MATCH_USERNAME}
            # Require valid-user
          </LimitExcept>
        </LocationMatch>

        <Directory "/var/www">
          Options Indexes FollowSymLinks
          AllowOverride None
          Require all granted
        </Directory>

      <Directory "/var/www/dav/data">
        Dav On
        DavDepthInfinity On
      </Directory>
      '';
    };

    "dav.resdigita.com" = {
      # serverAliases = ["dav.gv.coop"];
      # serverAliases = ["dav.lesgrandsvoisins.com"];
      listen = [{port = 8443; ssl=true;}];
      sslServerCert = "/var/lib/acme/dav.resdigita.com/fullchain.pem";
      sslServerChain = "/var/lib/acme/dav.resdigita.com/fullchain.pem";
      sslServerKey = "/var/lib/acme/dav.resdigita.com/key.pem";
      documentRoot = "/var/www/dav";
      extraConfig = lib.strings.concatStrings [ ''
        Alias /static /var/www/wagtail/static
        Alias /media /var/www/wagtail/media
      ''
      # wagtailExtraConfig
      ''
          DavLockDB /tmp/DesGVDavLock

          OIDCProviderMetadataURL https://key.lesgrandsvoisins.com/realms/master/.well-known/openid-configuration
          OIDCClientID dav
          OIDCClientSecret ${httpd-dav-oidcclientsecret}
          OIDCRedirectURI https://dav.resdigita.com/auth/redirect_uri_from_oauth2
          OIDCCryptoPassphrase JoWT5Mz1DIzsgI3MT2GH82aA6Xamp2ni

          RedirectMatch ^/?$ /redirect

          <Location "/auth">
            AuthType openid-connect
            Require valid-user
          </Location>

          <LocationMatch "^/auth/(?<username>[^/]+)">
            AuthType openid-connect
            Require claim preferred_username:%{env:MATCH_USERNAME}
              
            <LimitExcept OPTIONS GET HEAD POST PUT DELETE TRACE PROPOFIND CONNECT>
               Require claim preferred_username:%{env:MATCH_USERNAME}
            </LimitExcept>
          </LocationMatch>

          <Location "/redirect">
            AuthType openid-connect
            Require valid-user
            RewriteEngine On
            # Check for the presence of the OIDC_CLAIM_email header
            # RewriteCond %{env:OIDC_CLAIM_email} ^(.+)$
            RewriteCond %{env:OIDC_CLAIM_preferred_username} ^(.+)$
            # Redirect to the specific path based on the header value
            RewriteRule ^(.*)$ /auth/%1 [R,L]
          </Location>
          RedirectMatch ^/$ /redirect
       
          Alias /auth /var/www/dav/data
          Alias /pass /var/www/dav/data

          <LocationMatch "^/pass/(?<username>[^/]+)">
            AuthType Basic
            AuthBasicProvider ldap
            AuthName "DAV par LDAP"
            AuthLDAPBindDN cn=newuser,ou=users,dc=lesgrandsvoisins,dc=com
            AuthLDAPBindPassword ${SECRETS_NEWUSER_PASSWORD}
            AuthLDAPURL "ldaps://ldap.lesgrandsvoisins.com:14636/ou=users,dc=lesgrandsvoisins,dc=com?cn"
            # Require valid-user
            # Require ldap-dn cn=%{env:MATCH_USERNAME},ou=users,dc=lesgrandsvoisins,dc=com
            Require ldap-attribute cn=%{env:MATCH_USERNAME}
            
            <LimitExcept OPTIONS GET HEAD POST PUT DELETE TRACE PROPFIND CONNECT>
              # Require ldap-dn cn=%{env:MATCH_USERNAME},ou=users,dc=lesgrandsvoisins,dc=com
              Require ldap-attribute cn=%{env:MATCH_USERNAME}             
              # Require valid-user
            </LimitExcept>
          </LocationMatch>

          <Directory "/var/www">
            Options Indexes FollowSymLinks
            AllowOverride None
            Require all granted
          </Directory>

        <Directory "/var/www/dav/data">
          Dav On
          DavDepthInfinity On
        </Directory>
        ''];
    };
    "wagtail.resdigita.com" = {
       listen = [{port = 8443; ssl=true;}];
      sslServerCert = "/var/lib/acme/wagtail.resdigita.com/fullchain.pem";
      sslServerChain = "/var/lib/acme/wagtail.resdigita.com/fullchain.pem";
      sslServerKey = "/var/lib/acme/wagtail.resdigita.com/key.pem";

      documentRoot = "/var/www/wagtail";
      serverAliases = [
        "manncoach.resdigita.com"
        "resdigitacom.resdigita.com"
        "distractivescom.resdigita.com"
        "whowhatetccom.resdigita.com"
        "voisandcom.resdigita.com"
        "coopgvcom.resdigita.com"
        "voisandorg.resdigita.com"
        "lesgvcom.resdigita.com"
        "popuposcom.resdigita.com"
        "grandsvoisinscom.resdigita.com"
        "forumgrandsvoisinscom.resdigita.com"
        "baldridgegvoisorg.resdigita.com"
        "discourselesgvcom.resdigita.com"
        "iriviorg.resdigita.com"
        "ooolesgrandsvoisinscom.resdigita.com"
        "hyperattentioncom.resdigita.com"
        "forumgdvoisinscom.resdigita.com"
        "forumgrandsvoisinscom.resdigita.com"
        "agoodvillagecom.resdigita.com"
        "lgvcoop.resdigita.com"
        "configmagiccom.resdigita.com"
        "caplancitycom.resdigita.com"
        "quiquoietccom.resdigita.com"
        "lesartsvoisinscom.resdigita.com"
        "maelanccom.resdigita.com"
        "manncity.resdigita.com"
        "focusplexcom.resdigita.com"
        "gvoisorg.resdigita.com"
        "vlgorg.resdigita.com"
        "oldlesgrandsvoisinscom.resdigita.com"
        "cooptellgv.resdigita.com"
        "howwownowcom.resdigita.com"
        "aaalesgrandsvoisinscom.resdigita.com"
        "oldmanndigital.resdigita.com"
        "resolvactivecom.resdigita.com"
        "gvcity.resdigita.com"
        "toutdouxlissecom.resdigita.com"
        "iciwowcom.resdigita.com"
        ];
        extraConfig = ''
            <Location />
            Require all granted
            </Location>
            # SSLProxyEngine on
            # RewriteEngine on

            # RequestHeader set X-Forwarded-Proto "https"
            # RequestHeader set X-Forwarded-Port "443"

            # <Location /static/>
            # ProxyPass http://10.245.101.35:8888/
            # # ProxyPassReverse http://10.245.101.35:8888/
            # ProxyPreserveHost On
            # </Location>

            # <Location /media/>
            # ProxyPass http://10.245.101.35:8889/
            # # ProxyPassReverse http://10.245.101.35:8889/
            # ProxyPreserveHost On
            # </Location>

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
    

    # "resdigita.com" = {
    #   # listenAddresses = ["*" "[2a01:4f8:241:4faa::]" "[2a01:4f8:241:4faa::1]" "[2a01:4f8:241:4faa::2]" "[2a01:4f8:241:4faa::3]" "[2a01:4f8:241:4faa::4]" "[2a01:4f8:241:4faa::5]"];
    #   enableACME = true;
    #   #forceSSL = true;
    #   globalRedirect = "www.resdigita.com/";
    # };

    #   documentRoot =  "/var/www/";
    #   extraConfig = ''
    #   <Location />
    #   Require all granted
    #   </Location>
    #   # <If "%{HTTPS} == 'on'">
    #   # # HTTPS-specific configuration here
    #   #  ProxyPass / http://[::1]:8843/
    #   # </If>
    #   # <If "%{HTTPS} != 'on'">
    #   # # HTTPS-specific configuration here
    #   #  ProxyPass / http://[::1]:8088/
    #   # </If>

    # #    ProxyPass /.well-known !
    # #    ProxyPass /static !
    # #    ProxyPass /media !
    # #    ProxyPass /favicon.ico !

     
    #   ProxyPreserveHost On
    #   CacheDisable /
    #   '';
    # };
    # "guichet.lesgrandsvoisins.com" = {
    #   serverAliases = ["app.lesgrandsvoisins.com"];
    #   listen = [{port = 8443; ssl=true;}];
    #   sslServerCert = "/var/lib/acme/guichet.lesgrandsvoisins.com/fullchain.pem";
    #   sslServerChain = "/var/lib/acme/guichet.lesgrandsvoisins.com/fullchain.pem";
    #   sslServerKey = "/var/lib/acme/guichet.lesgrandsvoisins.com/key.pem";
    #   documentRoot =  "/var/www/guichet";
    #   extraConfig = ''
    #   <Location />
    #   Require all granted
    #   </Location>

    #   ProxyPass /.well-known !
    #   ProxyPass /static !
    #   ProxyPass /media !
    #   ProxyPass /favicon.ico !
    #   ProxyPass / http://[::1]:9991/
    #   ProxyPassReverse / http://[::1]:9991/
    #   ProxyPreserveHost On
    #   CacheDisable /
    #   <If "%{HTTP_HOST} != 'guichet.lesgrandsvoisins.com'">
    #     RedirectMatch /(.*)$ https://guichet.lesgrandsvoisins.com/$1
    #   </If>
    #   '';
    # };
    # "guichet.lesgrandsvoisins.com" = {
    #   enableACME = true;
    #   forceSSL = true;
    #   documentRoot =  "/var/www/";
    #   extraConfig = ''
    #   <Location />
    #   Require all granted
    #   </Location>

    #   ProxyPass /.well-known !
    # #    ProxyPass /static !
    # #    ProxyPass /media !
    # #    ProxyPass /favicon.ico !
    #   ProxyPass / http://[::1]:9991/
    #   ProxyPassReverse / http://[::1]:9991/
    #   ProxyPreserveHost On
    #   CacheDisable /
    #     RewriteEngine On
    #     RewriteRule ^/SOGo(.*)$ https://mail.lesgrandsvoisins.com$1
    #   '';
    # };
    # "gvoisin.resdigita.com" = {
    #   serverAliases = [
    #     "keycloak.village.ngo"
    #     "discourse.resdigita.com"
    #     "meet.resdigita.com"
    #     "jswiki.resdigita.com"
    #     ];
    #   listen = [{port = 8443; ssl=true;}];
    #   sslServerCert = "/var/lib/acme/gvoisin.resdigita.com/fullchain.pem";
    #   sslServerChain = "/var/lib/acme/gvoisin.resdigita.com/fullchain.pem";
    #   sslServerKey = "/var/lib/acme/gvoisin.resdigita.com/key.pem";

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
    #   '';
    # };
    # "hdoc.lesgrandsvoisins.com" = {
    #   serverAliases = [
    #     "hedgedoc.lesgrandsvoisins.com"
    #     "hdoc.lesgv.com"
    #     "hedgedoc.lesgv.com"
    #   ];
    #   listen = [{port = 8443; ssl=true;}];
    #   sslServerCert = "/var/lib/acme/hdoc.lesgrandsvoisins.com/fullchain.pem";
    #   sslServerChain = "/var/lib/acme/hdoc.lesgrandsvoisins.com/fullchain.pem";
    #   sslServerKey = "/var/lib/acme/hdoc.lesgrandsvoisins.com/key.pem";

    #   extraConfig = ''
    #       #ProxyPass /  http://10.245.101.35:3000/
    #       ProxyPass /  http://localhost:3333/
    #       # proxy_http_version 1.1;
    #       RequestHeader set X-Forwarded-Proto "https"
    #       RequestHeader set X-Forwarded-Port "443"
    #       #RequestHeader set X-Forwarded-For "$proxy_add_x_forwarded_for
    #       #RequestHeader set Host $host
    #       #RequestHeader set Upgrade $http_upgrade
    #       #RequestHeader set Connection $connection_upgrade_keepalive
    #       ProxyPreserveHost On
    #       ProxyVia On
    #       ProxyAddHeaders On
    #   '';
    # };
    # "auth.lesgrandsvoisins.com" = {
    #   # serverAliases = [
    #   # ];
    #   # enableACME = true;
    #   # forceSSL = true;
    #   listen = [{port = 8443; ssl=true;}];
    #   sslServerCert = "/var/lib/acme/auth.lesgrandsvoisins.com/fullchain.pem";
    #   sslServerChain = "/var/lib/acme/auth.lesgrandsvoisins.com/fullchain.pem";
    #   sslServerKey = "/var/lib/acme/auth.lesgrandsvoisins.com/key.pem";

    #   extraConfig = ''
    #       # RewriteEngine On
    #       #     RewriteCond %{HTTP:Connection} Upgrade [NC]
    #       #     RewriteCond %{HTTP:Upgrade} websocket [NC]
    #       #     RewriteRule /(.*) ws://10.245.101.35:9443/$1 [P,L]
    #       #ProxySet keepalive=On 
    #       #ProxyPass /  http://10.245.101.35:9000/
    #       #ProxyPass /  http://10.245.101.35:9000/
    #       #ProxyPass /  https://10.245.101.35:9443/ upgrade=websocket keepalive=on
    #       #ProxyPass /  https://10.245.101.35:9443/
    #       #ProxyPass /  https://localhost:8443/ upgrade=websocket keepalive=on
    #       ProxyPass /  https://localhost:8443/ upgrade=websocket
    #       SSLProxyEngine on
    #       SSLProxyVerify none 
    #       SSLProxyCheckPeerCN off
    #       SSLProxyCheckPeerName off
    #       SSLProxyCheckPeerExpire off
    #       #ProxyRequests Off
    #       ProxyPreserveHost On
    #       # proxy_http_version 1.1;
    #       RequestHeader set X-Forwarded-Proto "https"
    #       RequestHeader set X-Forwarded-Port "443"
    #       #KeepAlive On
    #       # RequestHeader set X-Forwarded-For "$proxy_add_x_forwarded_for
    #       # RequestHeader set Host $host
    #       # RequestHeader set Upgrade $http_upgrade
    #       # RequestHeader set Connection $connection_upgrade_keepalive
    #       ProxyPreserveHost On
    #       ProxyVia On
    #       ProxyAddHeaders On
    #       # <LimitExcept OPTIONS GET HEAD POST PUT DELETE TRACE CONNECT>
    #       #    Order allow,deny
    #       #    Allow from all
    #       # </LimitExcept>
    #   '';
    # };
    # "authentik.lesgrandsvoisins.com" = {
    #   serverAliases = [
    #     "auth.lesgv.com"
    #   ];
    #   enableACME = true;
    #   forceSSL = true;
    #   extraConfig = ''
    #       #ProxyPass /  http://10.245.101.35:9000/
    #       #ProxyPass /  http://10.245.101.35:9000/ 
    #       #ProxyPass /  https://localhost:8443/ upgrade=websocket keepalive=on
    #       ProxyPass /  https://localhost:8443/ upgrade=websocket
    #       #ProxyPass /  https://10.245.101.35:9443/
    #        #ProxySet keepalive=On 

    #       SSLProxyEngine on
    #       SSLProxyVerify none 
    #       SSLProxyCheckPeerCN off
    #       SSLProxyCheckPeerName off
    #       SSLProxyCheckPeerExpire off
          
    #       RequestHeader set X-Forwarded-Proto "https"
    #       RequestHeader set X-Forwarded-Port "443"
    #       # RequestHeader set X-Forwarded-For "$proxy_add_x_forwarded_for
    #       # RequestHeader set Host $host
    #       ProxyPreserveHost On
    #       ProxyVia On
    #       ProxyAddHeaders On
    #       <If "%{HTTP_HOST} != 'auth.lesgrandsvoisins.com'">
    #         RedirectMatch /(.*)$ https://auth.lesgrandsvoisins.com/$1
    #       </If>
    #   '';
    # };
    # "resdigita.com" = {
    #   serverAliases = ["www.resdigita.com" "resdigita.org" "resdigita.desgv.com" "doc.resdigita.com"];
    #   documentRoot =  "/var/www/resdigitacom/";
    #   listen = [{port = 8443; ssl=true;}];
    #   sslServerCert = "/var/lib/acme/resdigita.com/fullchain.pem";
    #   sslServerChain = "/var/lib/acme/resdigita.com/fullchain.pem";
    #   sslServerKey = "/var/lib/acme/resdigita.com/key.pem";
    # };
    # "hetzner005.lesgrandsvoisins.com" = {
    #   documentRoot =  "/var/www/resdigitacom/";
    #    listen = [{port = 8443; ssl=true;}];
    #   sslServerCert = "/var/lib/acme/hetzner005.lesgrandsvoisins.com/fullchain.pem";
    #   sslServerChain = "/var/lib/acme/hetzner005.lesgrandsvoisins.com/fullchain.pem";
    #   sslServerKey = "/var/lib/acme/hetzner005.lesgrandsvoisins.com/key.pem";

    # };
    # "avmeet.com" = {
    #   enableACME = true;
    #   forceSSL = true;
    #   globalRedirect = "www.avmeet.com";
    # };
    # "davpass.desgv.com" = {
    #   enableACME = true;
    #   forceSSL = true;
    #   documentRoot = "/var/www/dav/";
    #   extraConfig = ''
    #     DavLockDB /tmp/DavLock
    #     <Location />
    #     AuthType Basic
    #     AuthBasicProvider ldap
    #     AuthName "DAV par LDAP"
    #     AuthLDAPBindDN cn=newuser,ou=users,dc=resdigita,dc=org
    #     AuthLDAPBindPassword ${SECRETS_NEWUSER_PASSWORD}
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

    # "www.shitmuststop.com" = {
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
    # "secret.desgrandsvoisins.com" = {
    #   listen = [{port = 8443; ssl=true;}];
    #   sslServerCert = "/var/lib/acme/secret.desgrandsvoisins.com/fullchain.pem";
    #   sslServerChain = "/var/lib/acme/secret.desgrandsvoisins.com/fullchain.pem";
    #   sslServerKey = "/var/lib/acme/secret.desgrandsvoisins.com/key.pem";
    #   documentRoot = "/var/www/secret";
    #   extraConfig = ''
    #     Alias /static /var/www/wagtail/static
    #     Alias /media /var/www/wagtail/media
    #     DavLockDB /tmp/DavLockSecret
    #     OIDCProviderMetadataURL https://authentik.resdigita.com/application/o/dav/.well-known/openid-configuration
    #     OIDCClientID V7p2o3hX6Im6crzdExLI1lb81zMJEjDO3mO3rNBk
    #     OIDCClientSecret 
    #     OIDCRedirectURI https://secret.desgrandsvoisins.com/auth/redirect_uri_from_oauth2
    #     OIDCCryptoPassphrase JoWT5Mz1DIzsgI3MT2GH82aA6Xamp2ni
    #     <LocationMatch "^/(auth|pass|ldap|login)/(?<username>[^/]+)/manifest.json$">
    #       Satisfy Any
    #       Allow from all
    #     </LocationMatch>
    #     <Location "/auth">
    #       AuthType openid-connect
    #       Require valid-user
    #     </Location>
    #     <Location "/redirect">
    #       AuthType openid-connect
    #       Require valid-user
    #       RewriteEngine On
    #       # Check for the presence of the OIDC_CLAIM_email header
    #       RewriteCond %{env:OIDC_CLAIM_sub} ^([^@]+)@(.+)$
    #       # Redirect to the specific path based on the header value
    #       RewriteRule ^(.*)$ /auth/web/%2/%1 [R,L]
    #     </Location>
    #     <LocationMatch "^/auth/web/(?<username>[^/]+)">
    #       AuthType openid-connect 
    #       # Should already be inherited
    #       # Allow https://httpd.apache.org/docs/2.4/mod/mod_dav.html
    #       Require claim sub:%{env:MATCH_USERNAME}@%{env:MATCH_USERNAMEDOMAIN}
    #       <LimitExcept OPTIONS GET HEAD POST PUT DELETE TRACE CONNECT>
    #          Require claim sub:%{env:MATCH_USERNAME}@%{env:MATCH_USERNAMEDOMAIN}
    #       </LimitExcept>
    #     </LocationMatch>
    #     <LocationMatch "^/auth/dav/(?<username>[^/]+)">
    #       AuthType openid-connect 
    #       # Should already be inherited
    #       # Allow https://httpd.apache.org/docs/2.4/mod/mod_dav.html
    #       Require claim sub:%{env:MATCH_USERNAME}@%{env:MATCH_USERNAMEDOMAIN}
    #       <LimitExcept OPTIONS GET HEAD POST PUT DELETE TRACE CONNECT>
    #          Require claim sub:%{env:MATCH_USERNAME}@%{env:MATCH_USERNAMEDOMAIN}
    #       </LimitExcept>
    #     </LocationMatch>
    #     <LocationMatch "^/pass/web/(?<username>[^/]+)">
    #       AuthType Basic
    #       AuthBasicProvider ldap
    #       AuthName "DAV par LDAP"
    #       AuthLDAPBindDN cn=newuser,ou=users,dc=resdigita,dc=org
    #       AuthLDAPBindPassword ${SECRETS_NEWUSER_PASSWORD}
    #       AuthLDAPURL "ldap:///ou=users,dc=resdigita,dc=org?cn?sub"
    #       Require ldap-dn cn=%{env:MATCH_USERNAME}@%{env:MATCH_USERNAMEDOMAIN},ou=users,dc=resdigita,dc=org
    #       <LimitExcept OPTIONS GET HEAD POST PUT DELETE TRACE CONNECT>
    #         Require ldap-dn cn=%{env:MATCH_USERNAME}@%{env:MATCH_USERNAMEDOMAIN},ou=users,dc=resdigita,dc=org
    #       </LimitExcept>
    #     </LocationMatch>
    #     <LocationMatch "^/pass/dav/(?<username>[^/]+)">
    #       AuthType Basic
    #       AuthBasicProvider ldap
    #       AuthName "DAV par LDAP"
    #       AuthLDAPBindDN cn=newuser,ou=users,dc=resdigita,dc=org
    #       AuthLDAPBindPassword ${SECRETS_NEWUSER_PASSWORD}
    #       AuthLDAPURL "ldap:///ou=users,dc=resdigita,dc=org?cn?sub"
    #       Require ldap-dn cn=%{env:MATCH_USERNAME}@%{env:MATCH_USERNAMEDOMAIN},ou=users,dc=resdigita,dc=org
    #       <LimitExcept OPTIONS GET HEAD POST PUT DELETE TRACE PROPFIND CONNECT>
    #         Require ldap-dn cn=%{env:MATCH_USERNAME}@%{env:MATCH_USERNAMEDOMAIN},ou=users,dc=resdigita,dc=org
    #       </LimitExcept>
    #     </LocationMatch>
    #     <LocationMatch ^/$>
    #         Redirect /redirect
    #     </LocationMatch>

    #     AliasMatch "^/(auth|pass)/web/([^/]+/[^/]+)/dav/(.*)" "/var/www/secret/dav/$2/$3"
    #     AliasMatch "^/(auth|pass)/web/([^/]+/[^/]+)(.*)" "/var/www/secret/keepass$3"

    #     Alias /auth/dav /var/www/secret/dav
    #     Alias /pass/dav /var/www/secret/dav

    #     <Directory "/var/www">
    #       Options Indexes FollowSymLinks
    #       AllowOverride None
    #       Require all granted
    #     </Directory>

    #     <Directory "/var/www/secret/dav">
    #       Dav On
    #       DavDepthInfinity On
    #     </Directory>

    #   '';
    # };




    # "dav.lesgrandsvoisins.com" = {
    #   # serverAliases = ["dav.lesgrandsvoisins.com"];
    #   listen = [{port = 8443; ssl=true;}];
    #   sslServerCert = "/var/lib/acme/dav.lesgrandsvoisins.com/fullchain.pem";
    #   sslServerChain = "/var/lib/acme/dav.lesgrandsvoisins.com/fullchain.pem";
    #   sslServerKey = "/var/lib/acme/dav.lesgrandsvoisins.com/key.pem";
    #   documentRoot = "/var/www/dav";
    #   # extraConfig = ''
    #   # ProxyPass / http://10.245.101.35:8080/
    #   # ProxyPassReverse / http://10.245.101.35:8080/
    #   # RequestHeader set X-Forwarded-Proto "https"
    #   # RequestHeader set X-Forwarded-Port "443"
    #   # ProxyPreserveHost On
    #   # ProxyVia On
    #   # ProxyAddHeaders On

    #   # CacheDisable /

    #   # '';
    #   extraConfig = lib.strings.concatStrings [ ''
    #     Alias /static /var/www/wagtail/static
    #     Alias /media /var/www/wagtail/media
    #   ''
    #   # wagtailExtraConfig
    #   ''
    #     DavLockDB /tmp/DavLock

    #       OIDCProviderMetadataURL https://authentik.resdigita.com/application/o/dav/.well-known/openid-configuration
    #       OIDCClientID V7p2o3hX6Im6crzdExLI1lb81zMJEjDO3mO3rNBk
    #       OIDCClientSecret 
    #       OIDCRedirectURI https://dav.lesgrandsvoisins.com/auth/redirect_uri_from_oauth2
    #       OIDCCryptoPassphrase JoWT5Mz1DIzsgI3MT2GH82aA6Xamp2ni

    #       RedirectMatch ^/?$ /redirect

    #       <Location "/auth">
    #         AuthType openid-connect
    #         Require valid-user
    #       </Location>

    #       <LocationMatch "^/auth/(?<username>[^/]+)">
    #         AuthType openid-connect
    #         Require claim sub:%{env:MATCH_USERNAME}@%{env:MATCH_USERNAMEDOMAIN}
              
    #         <LimitExcept OPTIONS GET HEAD POST PUT DELETE TRACE PROPOFIND CONNECT>
    #            Require claim sub:%{env:MATCH_USERNAME}@%{env:MATCH_USERNAMEDOMAIN}
    #         </LimitExcept>
    #       </LocationMatch>

    #     <Location "/redirect">
    #       AuthType openid-connect
    #       Require valid-user
    #       RewriteEngine On
    #       # Check for the presence of the OIDC_CLAIM_email header
    #       RewriteCond %{env:OIDC_CLAIM_sub} ^([^@]+)@(.+)$
    #       # Redirect to the specific path based on the header value
    #       RewriteRule ^(.*)$ /auth/%2/%1 [R,L]
    #     </Location>
    #     RedirectMatch ^/$ /redirect
        



    #       Alias /ldap /var/www/dav/data
    #       Alias /auth /var/www/dav/data
    #       Alias /pass /var/www/dav/data
    #       Alias /login /var/www/dav/data

    #       <LocationMatch "^/(ldap|pass|login)/(?<username>[^/]+)">
    #         AuthType Basic
    #         AuthBasicProvider ldap
    #         AuthName "DAV par LDAP"
    #         AuthLDAPBindDN cn=newuser,ou=users,dc=resdigita,dc=org
    #         AuthLDAPBindPassword ${SECRETS_NEWUSER_PASSWORD}
    #         AuthLDAPURL "ldap:///ou=users,dc=resdigita,dc=org?cn?sub"
    #         #Require valid-user
    #         Require ldap-dn cn=%{env:MATCH_USERNAME}@%{env:MATCH_USERNAMEDOMAIN},ou=users,dc=resdigita,dc=org
            
    #         <LimitExcept OPTIONS GET HEAD POST PUT DELETE TRACE PROPFIND CONNECT>
    #           Require ldap-dn cn=%{env:MATCH_USERNAME}@%{env:MATCH_USERNAMEDOMAIN},ou=users,dc=resdigita,dc=org
    #         </LimitExcept>
    #       </LocationMatch>

    #       <Directory "/var/www">
    #         Options Indexes FollowSymLinks
    #         AllowOverride None
    #         Require all granted
    #       </Directory>

    #       # <Directory "/var/www/wagtail">
    #       # Options Indexes FollowSymLinks
    #       # AllowOverride None
    #       # Require all granted
    #       # </Directory>

    #     <Directory "/var/www/dav/data">
    #       Dav On
    #       DavDepthInfinity On
    #     </Directory>
    #     ''];
    # };

    # "lesgrandsvoisins.com" = {
    #   documentRoot = "/var/www/wagtail/";
    #   enableACME = true;
    #   forceSSL = true;
    #   extraConfig = ''
    #     RedirectMatch /(.*)$ https://www.lesgrandsvoisins.com/$1
    #   '';
    # };
    # "www.lesgrandsvoisins.fr" = {
    #    serverAliases = ["desgv.com" "www.lesgrandsvoisins.fr"  "francemali.org"
    #     "www.francemali.org" "shitmuststop.com" "www.shitmuststop.com" "www.desgv.com" "lesgrandsvoisins.fr"  "hopgv.com" "www.hopgv.com"  "www.lesgv.com" "lesgv.com"];
    #   documentRoot = "/var/www/wagtail/";
    #   listen = [{port = 8443; ssl=true;}];
    #   sslServerCert = "/var/lib/acme/www.lesgrandsvoisins.fr/fullchain.pem";
    #   sslServerChain = "/var/lib/acme/www.lesgrandsvoisins.fr/fullchain.pem";
    #   sslServerKey = "/var/lib/acme/www.lesgrandsvoisins.fr/key.pem";
    #        extraConfig = lib.strings.concatStrings [ wagtailExtraConfig ''
    #     <If "%{HTTP_HOST} == 'desgv.com'">
    #         RedirectMatch /(.*)$ https://www.desgv.com/$1
    #     </If>
    #     <If "%{HTTP_HOST} == 'francemali.org'">
    #         RedirectMatch /(.*)$ https://www.francemali.org/$1
    #     </If>
    #     <If "%{HTTP_HOST} == 'lesgv.com'">
    #         RedirectMatch /(.*)$ https://www.lesgv.com/$1
    #     </If>
    #     <If "%{HTTP_HOST} == 'lesgrandsvoisins.fr' || %{HTTP_HOST} == 'www.lesgrandsvoisins.fr' || %{HTTP_HOST} =~ /(www.)?lesgv.com/ || %{HTTP_HOST} =~ /(www.)?hopgv.com/">
    #         RedirectMatch /(.*)$ https://www.lesgrandsvoisins.com/$1
    #     </If>
    #       ProxyPreserveHost On
    #       CacheDisable /
    #   ''];
    # };
    # "www.lesgrandsvoisins.com" = {
    #   documentRoot = "/var/www/wagtail/";
    #   serverAliases = ["lesgrandsvoisins.com" ];
    #   listen = [{port = 8443; ssl=true;}];
    #   # sslServerCert = "/var/lib/acme/dav.lesgrandsvoisins.com/fullchain.pem";
    #   # sslServerChain = "/var/lib/acme/dav.lesgrandsvoisins.com/fullchain.pem";
    #   # sslServerKey = "/var/lib/acme/dav.lesgrandsvoisins.com/key.pem";
    #   # forceSSL = true;
    #   # enableACME = true;
    #   # addSSL = true;
    #   sslServerKey = "/etc/ssl/lesgrandsvoisins.com.key";
    #   sslServerCert = "/etc/ssl/lesgrandsvoisins.com.crt";
    #   sslServerChain = "/etc/ssl/lesgrandsvoisins.com.ca-bundle";
    #   #locations = wagtailHttpdLocations;
    #   # {
    #   #   "/.well-known".proxyPass = "!";
    #   #   "/static".proxyPass = "!";
    #   #   "/media".proxyPass = "!";
    #   #   "/favicon.ico".proxyPass = "!";
    #   #   "/" = {
    #   #     proxyPass = "http://127.0.0.1:8000/";
    #   #     extraConfig = ''
    #   #        Require all granted
    #   #        RequestHeader set X-Forwarded-Proto "https"
    #   #        RequestHeader set X-Forwarded-Port "443"
    #   #        ProxyPreserveHost On
    #   #        ProxyAddHeaders On
    #   #     '';
    #   #     priority = 1500;
    #   #   };

    #   # };
    #   extraConfig = lib.strings.concatStrings [  ''
    #     <If "%{HTTP_HOST} != 'www.lesgrandsvoisins.com'">
    #         RedirectMatch /(.*)$ https://www.lesgrandsvoisins.com/$1
    #     </If>
    #     ProxyPass /auth/ https://localhost:8443/ upgrade=websocket
    #     ProxyPassReverse /auth/ https://localhost:8443/ upgrade=websocket

    #       SSLProxyEngine on
    #       SSLProxyVerify none 
    #       SSLProxyCheckPeerCN off
    #       SSLProxyCheckPeerName off
    #       SSLProxyCheckPeerExpire off
    #       ProxyPass /blog/static/ !
    #       ProxyPass /blog/media/ !
    #       ProxyPass /blog/ http://localhost:2368/
          

          
    #       ''
    #       wagtailExtraConfig
    #       ];
    #   # locations."/auth" = {
    #   #   # proxyPass = "https://localhost:8443/ upgrade=websocket";
    #   #   extraConfig = ''

    #   #     ProxyPass https://localhost:8443/ upgrade=websocket

    #   #     SSLProxyEngine on
    #   #     SSLProxyVerify none 
    #   #     SSLProxyCheckPeerCN off
    #   #     SSLProxyCheckPeerName off
    #   #     SSLProxyCheckPeerExpire off
          
    #   #     RequestHeader set X-Forwarded-Proto "https"
    #   #     RequestHeader set X-Forwarded-Port "443"
    #   #     ProxyPreserveHost On
    #   #     ProxyVia On
    #   #     ProxyAddHeaders On
    #   #   '';
    #   # };
    # #   locations."/blog/static".proxyPass = null;
    # #   locations."/blog/media".proxyPass = null;
    # #   locations."/blog" = {
    # #     alias =  "/var/www/ghostio/";
    # #     extraConfig = ''
    # #     Require all granted

    # #     # ProxyPass /.well-known !
    # #     # ProxyPass /static !
    # #     # ProxyPass /media !
    # #     # ProxyPass /favicon.ico !
    # #     ProxyPass http://localhost:2368/
    # #     # ProxyPassReverse http://localhost:2368/
    # #     RequestHeader set X-Forwarded-Proto "https"
    # #     RequestHeader set X-Forwarded-Port "443"
    # #     ProxyPreserveHost On
    # #     ProxyVia On
    # #     ProxyAddHeaders On

    # #     # CacheDisable 
    # #   '';
    # #   };
    # };
    # # "blog.resdigita.com" = {
    # #   serverAliases = [
    # #     "ghost.resdigita.com"
    # #     "blog.lesgrandsvoisins.com"
    # #   ];
    # "blog.lesgrandsvoisins.com" = {
    #   serverAliases = ["blog.resdigita.com"];
    #   listen = [{port = 8443; ssl=true;}];
    #   sslServerCert = "/var/lib/acme/blog.lesgrandsvoisins.com/fullchain.pem";
    #   sslServerChain = "/var/lib/acme/blog.lesgrandsvoisins.com/fullchain.pem";
    #   sslServerKey = "/var/lib/acme/blog.lesgrandsvoisins.com/key.pem";
    #   documentRoot =  "/var/www/ghostio/";
    #   extraConfig = ''
    #   <Location />
    #   Require all granted
    #   </Location>
    #   # ProxyPass /.well-known !
    #   # ProxyPass /static !
    #   # ProxyPass /media !
    #   # ProxyPass /favicon.ico !
    #   ProxyPass / http://localhost:2368/
    #   # ProxyPassReverse / http://localhost:2368/
    #   RequestHeader set X-Forwarded-Proto "https"
    #   RequestHeader set X-Forwarded-Port "443"
    #   ProxyPreserveHost On
    #   ProxyVia On
    #   ProxyAddHeaders On

    #   CacheDisable /

    #   <If "%{HTTP_HOST} != 'blog.lesgrandsvoisins.com'">
    #     RedirectMatch /(.*)$ https://blog.lesgrandsvoisins.com/$1
    #   </If>
    #   '';
    # };
    # #  "odoo.resdigita.com" = {
    # #    enableACME = true;
    # #    forceSSL = true;
    # #    documentRoot =  "/var/www/";
    # #    extraConfig = ''
    # #    <Location />
    # #    Require all granted
    # #    </Location>
    # #    
    # #    ProxyPass /.well-known !
    # #    ProxyPass /static !
    # #    ProxyPass /media !
    # #    ProxyPass /favicon.ico !
    # #    ProxyPass / http://10.245.101.35:8069/
    # #    ProxyPassReverse / http://10.245.101.35:8069/
    # #    ProxyPreserveHost On
    # #    ProxyVia On
    # #    ProxyAddHeaders On
    # #
    # #    CacheDisable /
    # #    '';
    # #  };
    # #  "www.resdigita.org" = {
    # #    enableACME = true;
    # #    forceSSL = true;
    # ##    documentRoot =  "/var/www/wagtail/";
    # #    globalRedirect = "www.resdigita.com/resdigita";
    # ##    extraConfig = ''
    # ##    <Location />
    # ##    Require all granted
    # ##    </Location>
    # ##
    # ##    ProxyPass /.well-known !
    # ##    ProxyPass /static !
    # ##    ProxyPass /media !
    # ##    ProxyPass /favicon.ico !
    # ##    ProxyPass / unix:/var/lib/wagtail/wagtail-lesgv.sock|http://127.0.0.1/
    # ##    ProxyPassReverse / unix:/var/lib/wagtail/wagtail-lesgv.sock|http://127.0.0.1/
    # ##    ProxyPreserveHost On
    # ##    CacheDisable /
    # ##    '';
    # #
    # #  };
    # #  "www.resdigita.org" = {
    # #    enableACME = true;
    # #    forceSSL = true;
    # ##    documentRoot =  "/var/www/wagtail/";
    # #    globalRedirect = "www.resdigita.com/resdigita";
    # ##    extraConfig = ''
    # ##    <Location />
    # ##    Require all granted
    # ##    </Location>
    # ##
    # ##    ProxyPass /.well-known !
    # ##    ProxyPass /static !
    # ##    ProxyPass /media !
    # ##    ProxyPass /favicon.ico !
    # ##    ProxyPass / unix:/var/lib/wagtail/wagtail-lesgv.sock|http://127.0.0.1/
    # ##    ProxyPassReverse / unix:/var/lib/wagtail/wagtail-lesgv.sock|http://127.0.0.1/
    # ##    ProxyPreserveHost On
    # ##    CacheDisable /
    # ##    '';
    # ##
    # #  };

    # "odoo1.resdigita.com" = {
    #   serverAliases = [
    #     "actentioncom.resdigita.com"
    #     "gvoisorg.resdigita.com"
    #     "manngvoisorg.resdigita.com"
    #     "manndigital.resdigita.com"
    #     "mannfr.resdigita.com"
    #   ];
    #   documentRoot = "/var/www/sites/";
    #   listen = [{port = 8443; ssl=true;}];
    #   sslServerCert = "/var/lib/acme/odoo1.resdigita.com/fullchain.pem";
    #   sslServerChain = "/var/lib/acme/odoo1.resdigita.com/fullchain.pem";
    #   sslServerKey = "/var/lib/acme/odoo1.resdigita.com/key.pem";
    #   extraConfig = ''
    #     Alias "/html/" "/var/www/sites/goodv.org/"
    #     ProxyPreserveHost On
    #     RequestHeader set X-Forwarded-Proto "https"
    #     RequestHeader set X-Forwarded-Port "443"
    #     ProxyPass /html/ !
    #     ProxyPass /.well-known !
    #     ProxyPass / http://10.245.101.158:8069/
    #     # ProxyPassReverse / http://10.245.101.158:8069/
    #     ProxyPreserveHost on
    #     CacheDisable /
    #   '';
    # };

    # "odoo3.resdigita.com" = {
    #   serverAliases = [
    #     "lgvcoop.resdigita.com"
    #   ];
    #   documentRoot = "/var/www/sites/";
    #    listen = [{port = 8443; ssl=true;}];
    #   sslServerCert = "/var/lib/acme/odoo3.resdigita.com/fullchain.pem";
    #   sslServerChain = "/var/lib/acme/odoo3.resdigita.com/fullchain.pem";
    #   sslServerKey = "/var/lib/acme/odoo3.resdigita.com/key.pem";

    #   extraConfig = ''
    #     Alias "/html/" "/var/www/sites/goodv.org/"
    #     ProxyPreserveHost On
    #     RequestHeader set X-Forwarded-Proto "https"
    #     RequestHeader set X-Forwarded-Port "443"
    #     ProxyPass /html/ !
    #     ProxyPass /.well-known !
    #     ProxyPass / http://10.245.101.128:8069/
    #     # ProxyPassReverse / http://10.245.101.128:8069/
    #     ProxyPreserveHost on
    #     CacheDisable /
    #   '';
    # };

    # "ghostio.resdigita.com" = {
    #   serverAliases = [
    #     "coopgvcom.resdigita.com"
    #     "coopgvorg.resdigita.com"
    #     "lesgrandsvoisinsfr.resdigita.com"
    #     "bloglesgrandsvoisinscom.resdigita.com"
    #     "ghostgvoisorg.resdigita.com"
    #     ];
    #   documentRoot =  "/var/www/ghostio/";
    #    listen = [{port = 8443; ssl=true;}];
    #   sslServerCert = "/var/lib/acme/ghostio.resdigita.com/fullchain.pem";
    #   sslServerChain = "/var/lib/acme/ghostio.resdigita.com/fullchain.pem";
    #   sslServerKey = "/var/lib/acme/ghostio.resdigita.com/key.pem";

    #   extraConfig = ''
    #   <Location />
    #   Require all granted
    #   </Location>

    #   ProxyPass /.well-known !
    #   ProxyPass /static !
    #   ProxyPass /media !
    #   ProxyPass /favicon.ico !
    #   ProxyPass / http://[fd42:48f1:fe79:8c4b:216:3eff:fec9:de31]:2368/
    # #    ProxyPassReverse / http://[fd42:48f1:fe79:8c4b:216:3eff:fec9:de31]:2368/
    #   ProxyPreserveHost On
    #   ProxyVia On
    #   ProxyAddHeaders On
    #   RequestHeader set X-Forwarded-Proto "https"
    #   RequestHeader set X-Forwarded-Port "443"
    #   CacheDisable /
    #   '';
    # };
    # "tel.resdigita.com" = {
    #    listen = [{port = 8443; ssl=true;}];
    #   sslServerCert = "/var/lib/acme/tel.resdigita.com/fullchain.pem";
    #   sslServerChain = "/var/lib/acme/tel.resdigita.com/fullchain.pem";
    #   sslServerKey = "/var/lib/acme/tel.resdigita.com/key.pem";

    #   documentRoot = "/var/www/sites/meet";
    #   extraConfig = ''
    #      ProxyRequests On
    #      ProxyPreserveHost On
    #      ProxyPass /.well-known !
    #      ProxyPass / http://10.245.101.19/ retry=0
    #      <Proxy http://10.245.101.19/>
    #      ## adjust the following to your configuration
    #      RequestHeader set "x-webobjects-server-port" "443"
    #      RequestHeader set "x-webobjects-server-name" "tel.lgv.coop"
    #      RequestHeader set "x-webobjects-server-url" "https://tel.resdigita.com"
    #     ## When using proxy-side autentication, you need to uncomment and
    #     ## adjust the following line:
    #       RequestHeader unset "x-webobjects-remote-user"
    #     #  RequestHeader set "x-webobjects-remote-user" "%{REMOTE_USER}e" env=REMOTE_USER

    #       RequestHeader set "x-webobjects-server-protocol" "HTTP/1.0"

    #       AddDefaultCharset UTF-8

    #       Order allow,deny
    #       Allow from all
    #     </Proxy>
    #   '';
    # };


    # "odoo4.resdigita.com" = {
    #    listen = [{port = 8443; ssl=true;}];
    #   sslServerCert = "/var/lib/acme/odoo4.resdigita.com/fullchain.pem";
    #   sslServerChain = "/var/lib/acme/odoo4.resdigita.com/fullchain.pem";
    #   sslServerKey = "/var/lib/acme/odoo4.resdigita.com/key.pem";

    #   documentRoot = "/var/www/wagtail";
    #   serverAliases = [
    #     "voisandcom.resdigita.com"
    #     "voisandorg.resdigita.com"
    #     "lesgvcom.resdigita.com"
    #     "villagevoisincom.resdigita.com"
    #     "baldridgegvoisorg.resdigita.com"
    #     "ooolesgrandsvoisinscom.resdigita.com"
    #     "lesgrandsvoisinscom.resdigita.com"
    #   ];
    #   extraConfig = ''
    #     Alias "/html/" "/var/www/sites/goodv.org/"
    #     ProxyPreserveHost On
    #     RequestHeader set X-Forwarded-Proto "https"
    #     RequestHeader set X-Forwarded-Port "443"
    #     ProxyPass /html/ !
    #     ProxyPass /.well-known !
    #     ProxyPass / http://10.245.101.173:8069/
    #     # ProxyPassReverse / http://10.245.101.173:8069/
    #     ProxyPreserveHost on
    #     CacheDisable /
    #   '';
    # };

    # "odoo2.resdigita.com" = {
    #    listen = [{port = 8443; ssl=true;}];
    #   sslServerCert = "/var/lib/acme/odoo2.resdigita.com/fullchain.pem";
    #   sslServerChain = "/var/lib/acme/odoo2.resdigita.com/fullchain.pem";
    #   sslServerKey = "/var/lib/acme/odoo2.resdigita.com/key.pem";

    #   documentRoot = "/var/www";
    #   serverAliases = [
    #     "ooolgvcoop.resdigita.com"
    #   ];
    # extraConfig = ''
    #     Alias "/html/" "/var/www/sites/goodv.org/"
    #     ProxyPreserveHost On
    #     RequestHeader set X-Forwarded-Proto "https"
    #     RequestHeader set X-Forwarded-Port "443"
    #     ProxyPass /html/ !
    #     ProxyPass /.well-known !
    #     ProxyPass / http://10.245.101.82:8069/
    #     # ProxyPassReverse / http://10.245.101.82:8069/
    #     ProxyPreserveHost on
    #     CacheDisable /
    #   '';
    # };
  };
}