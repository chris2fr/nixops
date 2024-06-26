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
      defaultListenAddresses = [ "0.0.0.0" "116.202.236.241" "[::]" "[::1]"];
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
      recommendedProxySettings = true;
      upstreams = {
        "authentik" = {
          extraConfig = ''
            server 10.245.101.35:9000;
            # Improve performance by keeping some connections alive.
            keepalive 10;   
          '';
        };
        "wagtail".extraConfig = ''
          # server unix:/var/lib/wagtail/wagtail-lesgv.sock;
          server localhost:8000;
        '';
        "wagtailstatic".servers = {
          "10.245.101.15:8888" = {};
        };
        "wagtailmedia".servers = {"10.245.101.15:8889" = {};};
      };
      virtualHosts = {
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
            # proxyWebsockets = true;
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
            ];
          enableACME = true; 
          forceSSL = true; 
          locations."/" = {
            proxyPass = "http://localhost:8222";
            proxyWebsockets = true;
          };
        };
        "uptime-kuma.resdigita.com" = {
          serverAliases = ["uptime-kuma.lesgv.org" "uk.lesgv.org"];
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
          serverAliases = ["ethercalc.lesgv.org"];
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
          "radicale.lesgv.org"];
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
            "filebrowser.lesgv.org"];
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
        "list.desgrandsvoisins.org" = {
          serverAliases = ["list.desgrandsvoisins.com" 
          "listmonk.gv.coop" 
          "listmonk.lesgv.org"];
          # serverAliases = ["list.desgrandsvoisins.com" "listmonk.lesgrandsvoisins.com"];
          enableACME = true;
          forceSSL = true;
          globalRedirect = "list.lesgrandsvoisins.com";
        };
        "homepage-dashboard.resdigita.com" = {
          serverAliases = [
            "homepage-dashboard.gv.coop" 
            "homepage-dashboard.lesgv.org" "hd.lesgv.org"];
          enableACME = true;
          forceSSL = true;
          locations."/".proxyPass = "http://localhost:8882/";
        };        
        "silverbullet.resdigita.com" = {
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
        "vikunja.resdigita.com" = {
          serverAliases = [
            "vikunja.gv.coop" 
            "vikunja.lesgv.org"];
          enableACME = true;
          forceSSL = true;
        };
        "keycloak.village.ngo" = {
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
              proxy_pass         http://192.168.105.11:443/;
              # proxy_set_header   Upgrade $http_upgrade;
              # proxy_set_header   Connection "upgrade";
          '';
          };
        };
      };
    };
  };
}