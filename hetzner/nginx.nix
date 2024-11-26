{ config, pkgs, lib, ... }:
let 
nginxLocationWagtailExtraConfig = ''
    proxy_redirect off;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    # proxy_http_version 1.1;
    proxy_set_header Host $host;
    # proxy_set_header Upgrade $http_upgrade;
    # proxy_set_header Connection $connection_upgrade_keepalive;
'';
in
{ 
  imports = [
    ./nginx/authentik.nix
    ./nginx/crabfit.nix
    ./nginx/ghostio.nix
    ./nginx/guichet.nix
    ./nginx/hedgedoc.nix
    ./nginx/odoo.nix
    ./nginx/static.nix
    ./nginx/wagtail.nix
    ./nginx/webdav.nix
  ];
  # networking = {
  #   extraHosts = "192.168.103.2 ghh.resdigita.com";
  # };
  users.users.nginx.group = "wwwrun";
  services = {
    nginx = {
      group = "wwwrun";
      enable = true;  
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;
      defaultListenAddresses = [ "127.0.0.1" "116.202.236.241" "[2a01:4f8:241:4faa::]" "[::1]"];
      # defaultListenAddresses = [ "0.0.0.0" "116.202.236.241" "[::]" "[::1]"];
      #defaultListen = [{ addr = "0.0.0.0"; port=8888; } { addr = "[::]"; port=8443; } { addr="[2a01:4f8:241:4faa::100]" ; port=443;} ];
      appendHttpConfig = ''
        proxy_headers_hash_max_size 4096;
        server_names_hash_max_size 4096;
        proxy_headers_hash_bucket_size 256;
        proxy_buffer_size   128k;
        proxy_buffers   4 256k;
        proxy_busy_buffers_size   256k;
        # Upgrade WebSocket if requested, otherwise use keepalive
        map $http_upgrade $connection_upgrade_keepalive {
            default upgrade;
        }
      '';
      # appendConfig = ''
      #       log_format seafileformat '$http_x_forwarded_for $remote_addr [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent" $upstream_response_time';
      # '';
      # commonHttpConfig = ''
      # '';
      upstreams = {
        "authentik" = {
          extraConfig = ''
            server 10.245.101.35:9000;
            # Improve performance by keeping some connections alive.
            keepalive 10;   
          '';
        };
        # "wagtail".extraConfig = ''
        #   # server unix:/var/lib/wagtail/wagtail-lesgv.sock;
        #   server localhost:8000;
        # '';
        "wagtailstatic".servers = {
          "10.245.101.15:8888" = {};
        };
        "wagtailmedia".servers = {"10.245.101.15:8889" = {};};
      };
      virtualHosts = {
        # "8.lesgrandsvoisins.com" = {
        #   root =  "/var/www/html/";
        #   forceSSL = true;
        #   enableACME = true;
        #   locations."/" = {
        #   proxyPass = "https://[2a01:4f8:241:4faa::8]";
        #   recommendedProxySettings = true;
        #   proxyWebsockets = true;
        #     extraConfig = ''
        #     proxy_set_header Host $host;
        #     proxy_set_header X-Real-IP $remote_addr;
        #     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        #     proxy_set_header X-Forwarded-Host $host;
        #     proxy_set_header X-Forwarded-Proto $scheme;
        #     add_header Content-Security-Policy "frame-src *; frame-ancestors *; object-src *;";
        #     add_header Access-Control-Allow-Credentials true;
        #     proxy_ssl_verify  off;
        #     '';
        #   };
        # };
        # "sftpgo.lesgrandsvoisins.com" = {
        #   root =  "/var/www/html/";
        #   listen = [{
        #     addr = "[2a01:4f8:241:4faa::8]";
        #     port = 80;
        #   }];
        # };
        "0.lesgrandsvoisins.com" = {
          listen = [{ addr = "[2a01:4f8:241:4faa::0]"; port = 80; }];
          root =  "/var/www/html/";
        };
        "1.lesgrandsvoisins.com" = {
          listen = [{ addr = "[2a01:4f8:241:4faa::1]"; port = 80; }];
          root =  "/var/www/html/";
        };
        # "2.lesgrandsvoisins.com" = {
        #   listen = [{ addr = "[2a01:4f8:241:4faa::2]"; port = 80; }];
        #   root =  "/var/www/html/";
        # };
        # "3.lesgrandsvoisins.com" = {
        #   listen = [{ addr = "[2a01:4f8:241:4faa::3]"; port = 80; }];
        #   root =  "/var/www/html/";
        # };
        # "4.lesgrandsvoisins.com" = {
        #   listen = [{ addr = "[2a01:4f8:241:4faa::4]"; port = 80; }];
        #   root =  "/var/www/html/";
        # };
        # "5.lesgrandsvoisins.com" = {
        #   listen = [{ addr = "[2a01:4f8:241:4faa::5]"; port = 80; }];
        #   root =  "/var/www/html/";
        # };
        # "6.lesgrandsvoisins.com" = {
        #   listen = [{ addr = "[2a01:4f8:241:4faa::6]"; port = 80; }];
        #   root =  "/var/www/html/";
        # };
        # "7.lesgrandsvoisins.com" = {
        #   listen = [{ addr = "[2a01:4f8:241:4faa::7]"; port = 80; }];
        #   root =  "/var/www/html/";
        # };
        "9.lesgrandsvoisins.com" = {
          listen = [{ addr = "[2a01:4f8:241:4faa::9]"; port = 80; }];
          root =  "/var/www/html/";
        };
        "10.lesgrandsvoisins.com" = {
          # serverAliases = ["linkding"];
          root =  "/var/www/html/";
          listen = [{
            addr = "[2a01:4f8:241:4faa::10]";
            port = 80;
          }
          {
            addr = "[2a01:4f8:241:4faa::10]";
            port = 443;
            ssl = true;
          }];
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            recommendedProxySettings = true;
            proxyPass = "http://localhost:8901";
            extraConfig = ''
            # if ($host != "linkding.lesgrandsvoisins.com") {
            #   return 302 $scheme://linkding.lesgrandsvoisins.com$request_uri;
            # }
            '';
          };
        };
        "linkding.lesgrandsvoisins.com" = {
          root =  "/var/www/linkding/";
          forceSSL = true;
          enableACME = true;
          locations."/static/" = {
            proxyPass = null;
          };
          locations."^/login/$" = {
            extraConfig = ''
              return 302 $scheme://linkding.lesgrandsvoisins.com/oidc/authenticate/;
            '';
          };
          locations."/" = {
            # recommendedProxySettings = true;
            # proxyPass = "http://localhost:8901";
            extraConfig = ''
            proxy_pass http://localhost:8901;
            proxy_set_header Host "linkding.lesgrandsvoisins.com";
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Host "linkding.lesgrandsvoisins.com";
            proxy_set_header X-Forwarded-Proto "https";
            proxy_set_header    X-Scheme $scheme;
            proxy_redirect default;
            proxy_http_version 1.1;
            proxy_set_header   Upgrade $http_upgrade;
            proxy_set_header   Connection "upgrade";
            # add_header Content-Security-Policy "frame-src *; frame-ancestors *; object-src *;";
            # add_header Access-Control-Allow-Credentials true;
            # if ($host != "linkding.lesgrandsvoisins.com") {
            #   return 302 $scheme://linkding.lesgrandsvoisins.com$request_uri;
            # }
            '';
          };
        };
        "www.villagegv.com" = {
          forceSSL = true;
          enableACME = true;
          serverAliases = [
            "villagegv.com"
            "www.villagegv.org"
            "villagegv.org"
          ];
          root =  "/var/www/village/";
          extraConfig = ''
            return 302 $scheme://www.village.ngo$request_uri;
          '';
        };
        "keycloak.village.ngo" = {
          enableACME = true;
          forceSSL = true;
          root = "/var/www/keycloakvillagengo";
          # globalRedirect = "keycloak.village.ngo:12443";
          locations."/" = {
            proxyPass = "https://keycloak.village.ngo:12443";
            extraConfig = ''
            proxy_set_header   X-Real-IP $remote_addr;
            proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header   Host $host;
            # proxy_set_header X-Forwarded-Host $host;
            proxy_set_header X-Forwarded-Proto $scheme;
            add_header Content-Security-Policy "frame-src *; frame-ancestors *; object-src *;";
            add_header Access-Control-Allow-Credentials true;
            '';
          };
        };
        "key.lesgrandsvoisins.com" = {
          enableACME = true;
          forceSSL = true;
          serverAliases = ["adminkey.lesgrandsvoisins.com"];
          root = "/var/www/key.lesgrandsvoisins.com";
          # globalRedirect = "key.lesgrandsvoisins.com:14443";
          locations."/" = {
            proxyPass = "https://192.168.105.11:14443";
            extraConfig = ''
            rewrite ^/$ https://key.lesgrandsvoisins.com/realms/master/account/applications redirect;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Host $host;
            proxy_set_header X-Forwarded-Proto $scheme;
            add_header Content-Security-Policy "frame-src *; frame-ancestors *; object-src *;";
            add_header Access-Control-Allow-Credentials true;
            proxy_ssl_certificate     /var/lib/acme/key.lesgrandsvoisins.com/fullchain.pem;
            proxy_ssl_certificate_key /var/lib/acme/key.lesgrandsvoisins.com/key.pem;
            '';
          };
        };
        "link.lesgrandsvoisins.com" = {
          serverAliases = ["link.gv.coop"];
          forceSSL = true;
          enableACME = true;
          locations."/.well-known" = { proxyPass = null; };
          locations."/" = {
            extraConfig = ''
            if ($host != "link.lesgrandsvoisins.com") {
              return 302 $scheme://link.lesgrandsvoisins.com$request_uri;
            }
            rewrite ^/$ https://link.lesgrandsvoisins.com/api/v1/auth/signin/keycloak? redirect;
            # rewrite ^/$ https://link.gv.coop/api/v1/auth/signin/keycloak? redirect;
            # rewrite ^/login$ https://link.gv.coop/api/v1/auth/signin/keycloak? redirect;
            proxy_set_header   X-Real-IP $remote_addr;
            proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header   Host $host;
            proxy_pass         http://localhost:3003/;
            proxy_read_timeout 600s;
            # proxy_http_version 1.1;
            # proxy_set_header   Upgrade $http_upgrade;
            # proxy_set_header   Connection "upgrade";
            # proxy_set_header X-Forwarded-Proto $scheme;
            # proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            # proxy_redirect off;
            '';
          };
        };
        # "ldap.gv.coop" = {
        "ldap.lesgrandsvoisins.com" = {
          forceSSL = true;
          enableACME = true;
          locations."/.well-known" = { proxyPass = null; };
          # locations."/pwm/private/changepassword".return = "302 https://auth.gv.coop/reset-password/step1";
          # locations."/pwm/public/forgottenpassword".return = "302 https://auth.gv.coop/reset-password/step1";
          # locations."/pwm/public/logout".return = "302 /pwm/";
          locations."/" = {
            extraConfig = ''
            rewrite ^/$ https://key.lesgrandsvoisins.com/ redirect;
            # rewrite ^/$ https://key.gv.coop/ redirect;
            # rewrite ^/$ https://ldap.gv.coop/pwm/ redirect;
            # rewrite ^/pwm/public/logout?processAction=showLogout&stickyRedirectTest=key https://ldap.gv.coop/pwm/ redirect;
            proxy_set_header   X-Real-IP $remote_addr;
            proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header   Host $host;
            proxy_pass         http://localhost:18080/;
            proxy_read_timeout 600s;
            # proxy_http_version 1.1;
            # proxy_set_header   Upgrade $http_upgrade;
            # proxy_set_header   Connection "upgrade";
            # proxy_set_header X-Forwarded-Proto $scheme;
            # proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            # proxy_redirect off;
            '';
          };
          # locations."/" = {
          #   return = "302 https://ldap.gv.coop/pwm$request_uri";
          # };
          root = "/var/www/lesgrandsvoisins.com/ldap";
          # root = "/var/www/gv.coop/ldap";
        }; 
        "syncthing.resdigita.com" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            extraConfig = ''
            proxy_set_header   X-Real-IP $remote_addr;
            proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header   Host $host;
            proxy_pass         http://localhost:8384/;
            proxy_read_timeout 600s;
            proxy_send_timeout 600s;
            # proxy_http_version 1.1;
            # proxy_set_header   Upgrade $http_upgrade;
            # proxy_set_header   Connection "upgrade";
            # proxy_set_header X-Forwarded-Proto $scheme;
            # proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            # proxy_redirect off;
            '';
          };
        };
        "pocketbase.resdigita.com" = {
          serverAliases = ["pocket.resdigita.com"];
          forceSSL = true; 
          enableACME = true; 
          locations."/" = {
            proxyPass = "http://localhost:8090";
            # proxyWebsockets = true      locations."/.well-known" = { proxyPass = null; };
            # extraConfig = ''
            # proxy_set_header   X-Real-IP $remote_addr;
            # proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
            # proxy_set_header   Host $host;

            # proxy_http_version 1.1;
            # proxy_set_header   Upgrade $http_upgrade;
            # proxy_set_header   Connection "upgrade";
            # # proxy_set_header X-Forwarded-Proto $scheme;
            # # proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            # # proxy_redirect off;
            # '';
          };      
        };
        "wordpress.resdigita.com" = {
          forceSSL = true; 
          enableACME = true; 
          serverAliases = ["ghh.resdigita.com"];
          globalRedirect = "ghh.resdigita.com:11443";
          # locations."/" = {
          #   proxyPass = "https://192.168.103.2";
          #   extraConfig = ''
          #     proxy_set_header X-Forwarded-Proto $scheme;
          #     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          #     proxy_set_header   X-Real-IP $remote_addr;
          #     proxy_set_header   Host $host;
          #   '';
          # };
        };
        # "seafile.resdigita.com" = {
        #   enableACME = true;
        #   forceSSL = true;
        #   locations."/".proxyPass = "http://localhost:8082";
        # };
        # "filestash.resdigita.com" = {
        #   enableACME = true;
        #   forceSSL = true;
        #   locations."/".proxyPass = "http://localhost:8334";
        # }; 
        "mail.resdigita.com" = {
          serverAliases = [
            "mail.hopgv.org"
            "mail.hopgv.com"
            "mail.gvois.org"
            "mail.gvois.com"
            "mail.resdigita.org"
            "mail.lesgrandsvoisins.fr"
          ];
          enableACME = true; forceSSL = true; 
          locations."/".return = "302 https://mail.lesgrandsvoisins.com";
        };
        "vaultwarden.resdigita.com" = {
          serverAliases = [
            "vaultwarden.gv.coop" 
            "bitwarden.gv.coop"
            "vaultwarden.lesgv.org"
            "bit.lesgrandsvoisins.com"
            "vault.lesgrandsvoisins.com"
            "vaultwarden.lesgrandsvoisins.com"
            # "pass.lesgrandsvoisins.com"
            ];
          enableACME = true; 
          forceSSL = true; 
          locations."/" = {
            proxyPass = "http://localhost:8222";
            proxyWebsockets = true;
          };
        };
        "uptime-kuma.resdigita.com" = {
          serverAliases = ["uptime-kuma.lesgv.org" "uk.lesgv.org" "up.lesgrandsvoisins.com"];
          enableACME = true; 
          forceSSL = true; 
          locations."/" = {
            # proxyPass = "https://xandikos.resdigita.com:5280";
            # proxyPass = "http://localhost:3001";
            # locations."/".proxyPass = "http://localhost:8334";
            extraConfig = ''
            proxy_set_header   X-Real-IP $remote_addr;
            proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header   Host $host;
            proxy_pass         http://localhost:3001/;
            proxy_http_version 1.1;
            proxy_set_header   Upgrade $http_upgrade;
            proxy_set_header   Connection "upgrade";
            # proxy_set_header X-Forwarded-Proto $scheme;
            # proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            # proxy_redirect off;
            '';
          };
        };
        "xandikos.resdigita.com" = {
          serverAliases = ["xandikos.lesgv.org"];
          enableACME = true; 
          forceSSL = true; 
          locations."/" = {
            # proxyPass = "https://xandikos.resdigita.com:5280";
            proxyPass = "http://localhost:5280";
            # locations."/".proxyPass = "http://localhost:8334";
            extraConfig = ''
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_redirect off;
            '';
          };
        };
        "ethercalc.resdigita.com" = {
          serverAliases = ["ethercalc.lesgv.org" "table.lesgrandsvoisins.com"];
          enableACME = true; 
          forceSSL = true; 
          locations."/" = {
            proxyPass = "http://localhost:8123";
            # locations."/".proxyPass = "http://localhost:8334";
            extraConfig = ''
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_redirect off;
            '';
          };
        };
        "radicale.resdigita.com" = {
          serverAliases = ["radicale.lesgv.org"
          "radicale.lesgv.org"
          "radicale.lesgrandsvoisins.com"];
          enableACME = true; 
          forceSSL = true; 
          locations."/" = {
            proxyPass = "https://radicale.resdigita.com:8443";
            # locations."/".proxyPass = "http://localhost:8334";
            extraConfig = ''
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_redirect off;
            '';
          };
        };
        "keeweb.lesgrandsvoisins.com" = {
          enableACME = true; forceSSL = true; 
          globalRedirect = "keepass.resdigita.com";
        };
        # "resdigita.com" = {
        #   serverAliases = ["www.resdigita.com"];
        #   enableACME = true;
        #   forceSSL = true;
        #   # globalRedirect = "homepage-dashboard.resdigita.com";
        #   locations."/".return = "302 https://homepage-dashboard.resdigita.com";
        # };
        "filebrowser.resdigita.com" = {
          serverAliases = [
            "filebrowser.gv.coop" 
            "filebrowser.lesgv.org"
            "filebrowser.lesgrandsvoisins.com"];
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "https://filebrowser.resdigita.com:8443";
            # locations."/".proxyPass = "http://localhost:8334";
            extraConfig = ''
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            '';
            
          };
        }; 
        "chris.resdigita.com" = {
      serverAliases = ["chris.lesgv.org"];
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "https://chris.resdigita.com:8443";
            # locations."/".proxyPass = "http://localhost:8334";
            extraConfig = ''
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            '';
          };
        };
        "axel.resdigita.com" = {
      serverAliases = ["axel.lesgv.org"];
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "https://axel.resdigita.com:8443";
            # locations."/".proxyPass = "http://localhost:8334";
            extraConfig = ''
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            '';
          };
        };      
        "maruftuyel.resdigita.com" = {
      serverAliases = ["maruftuyel.lesgv.org"];
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "https://maruftuyel.resdigita.com:8443";
            # locations."/".proxyPass = "http://localhost:8334";
            extraConfig = ''
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            '';
          };
        };   
        # "list.desgrandsvoisins.org" = {
        #   serverAliases = ["list.desgrandsvoisins.com" 
        #   "listmonk.gv.coop" 
        #   "listmonk.lesgv.org"];
        #   # serverAliases = ["list.desgrandsvoisins.com" "listmonk.lesgrandsvoisins.com"];
        #   enableACME = true;
        #   forceSSL = true;
        #   globalRedirect = "list.lesgrandsvoisins.com";
        # };
        "homepage-dashboard.resdigita.com" = {
          serverAliases = [
            "homepage-dashboard.gv.coop" 
            "homepage-dashboard.lesgv.org" "hd.lesgv.org"
            "dash.lesgrandsvoisins.com"];
          enableACME = true;
          forceSSL = true;
          locations."/".proxyPass = "http://localhost:8882/";
        };        
        "silverbullet.village.ngo" = {
          serverAliases = ["silverbullet.resdigita.com"];
          enableACME = true;
          forceSSL = true;
          #locations."/".proxyPass = "http://10.245.101.35:3000/";
          locations."/".proxyPass = "http://192.168.102.2:3000/";
          extraConfig = ''
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_redirect off;
            '';
        };
        "ete.village.ngo" = {
          enableACME = true;
          forceSSL = true;
          serverAliases = ["ete.lesgrandsvoisins.com"];
          locations."/".proxyPass = "http://unix:/var/lib/etebase-server/etebase-server.sock";
        };
        "sftpgo.lesgrandsvoisins.com" = {
          serverAliases = ["drive.lesgrandsvoisins.com"];
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            extraConfig = ''
            if ($host != "sftpgo.lesgrandsvoisins.com") {
              return 302 $scheme://sftpgo.lesgrandsvoisins.com$request_uri;
            }
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Host $host:$server_port;
            # proxy_set_header X-Forwarded-Host $server_name;
            proxy_http_version 1.1;
            proxy_set_header  Upgrade $http_upgrade;
            proxy_set_header  Connection "upgrade";
            # proxy_bind $remote_addr transparent;
            # proxy_set_header Connection $connection_upgrade;
            proxy_pass https://sftpgo.lesgrandsvoisins.com:10443; 
            client_max_body_size 2500M;
            # proxy_redirect https://sftpgo.lesgrandsvoisins.com:10443 https://sftpgo.lesgrandsvoisins.com;
            # proxy_ssl_verify  off;
            proxy_ssl_trusted_certificate /var/lib/acme/sftp.lesgrandsvoisins.com/fullchain.pem;
          '';
          };
        };
        "minio.lesgrandsvoisins.com" = {
          enableACME = true;
          forceSSL = true;
          locations."/".proxyPass = "http://127.0.0.1:9000";
        };
        # "etedav.village.ngo" = {
        #   enableACME = true;
        #   forceSSL = true;
        #   locations."/".proxyPass = "http://localhost:37358/";
        #   extraConfig = ''
        #     proxy_set_header X-Forwarded-Proto $scheme;
        #     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        #   '';
        # };
        "vikunja.village.ngo" = {
          serverAliases = [
            "vikunja.resdigita.com"
            "vikunja.gv.coop" 
            "vikunja.lesgv.org"
            "task.lesgrandsvoisins.com"
            "vikunja.lesgrandsvoisins.com"
            ];
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://localhost:3456/";
            extraConfig = ''
                if ($host != "task.lesgrandsvoisins.com") {
                  return 302 $scheme://task.lesgrandsvoisins.com$request_uri;
                }
                proxy_http_version 1.1;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_redirect off;
                client_max_body_size 200M;
                # proxy_set_header Host $host;
            '';
          };
        };
        "discourse.village.ngo" = {
          serverAliases = ["disc.lesgrandsvoisins.com" 
          "discourse.lesgrandsvoisins.com"
          "forum.lesgrandsvoisins.com"];
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            extraConfig = ''
              proxy_http_version 1.1;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_redirect off;
              proxy_set_header   Host $host;
              proxy_pass         https://192.168.104.11;
              proxy_ssl_trusted_certificate /var/lib/acme/discourse.village.ngo/full.pem;
              proxy_ssl_verify     off;
              proxy_set_header   Upgrade $http_upgrade;
              proxy_set_header   Connection "upgrade";
          '';
          };
        };
      };
    };
  };
}