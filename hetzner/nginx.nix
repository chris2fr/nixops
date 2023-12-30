{ config, pkgs, lib, ... }:
let 
nginxLocationWagtailExtraConfig = ''
    proxy_redirect off;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    # proxy_http_version 1.1;
    # proxy_set_header Host $host;
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
  users.users.nginx.group = "wwwrun";
  services = {
    nginx = {
      group = "wwwrun";
      enable = true;
      defaultListenAddresses = [ "0.0.0.0" "116.202.236.241" "[::]" "[::1]"];
      #defaultListen = [{ addr = "0.0.0.0"; port=8888; } { addr = "[::]"; port=8443; } { addr="[2a01:4f8:241:4faa::100]" ; port=443;} ];
      appendHttpConfig = ''
        proxy_headers_hash_max_size 4096;
        server_names_hash_max_size 4096;
        proxy_headers_hash_bucket_size 256;
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
          enableACME = true; forceSSL = true; 
          globalRedirect = "mail.lesgrandsvoisins.com"; 
        };
        "keeweb.lesgrandsvoisins.com" = {
          serverAliases = ["keeweb.resdigita.com"];
          enableACME = true; forceSSL = true; 
          globalRedirect = "keepass.resdigita.com";
        };
        "resdigita.com" = {
          serverAliases = ["www.resdigita.com"];
          enableACME = true;
          forceSSL = true;
          globalRedirect = "doc.resdigita.com";
        };
        "filebrowser.resdigita.com" = {
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
        "list.desgrandsvoisins.org" = {
          serverAliases = ["list.desgrandsvoisins.com"];
          enableACME = true;
          forceSSL = true;
          globalRedirect = "list.lesgrandsvoisins.com";
        };
        "homepage-dashboard.resdigita.com" = {
          enableACME = true;
          forceSSL = true;
          proxyPass = "http://localhost:8882/";
        };
      };
    };
  };
}