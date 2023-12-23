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
  services.nginx = {
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
    appendConfig = ''
          log_format seafileformat '$http_x_forwarded_for $remote_addr [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent" $upstream_response_time';
    '';
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
      "list.desgrandsvoisins.org" = {
        serverAliases = ["list.desgrandsvoisins.com"];
        enableACME = true;
        forceSSL = true;
        globalRedirect = "list.lesgrandsvoisins.com";
      };
    };
    virtualHosts."seafile.resdigita.com" = {
      enableACME = true;
      forceSSL = true;
      
      locations."/" = {
         proxyPass = "http://localhost:18000/";
         recommendedProxySettings = false;
         extraConfig = ''
          proxy_read_timeout 310s;
          proxy_set_header Host $host;
          proxy_set_header Forwarded "for=$remote_addr;proto=$scheme";
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header Connection "";
          proxy_http_version 1.1;        proxy_http_version 1.1;
          client_max_body_size 0;
          access_log      /var/log/nginx/seahub.access.log seafileformat;
          error_log       /var/log/nginx/seahub.error.log;
         '';
      };
      locations."/seafhttp" = {
        proxyPass = "http://127.0.0.1:8082";
        recommendedProxySettings = false;
        extraConfig = ''
        
        rewrite ^/seafhttp(.*)$ $1 break;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        client_max_body_size 0;
        proxy_connect_timeout  36000s;
        proxy_read_timeout  36000s;
        proxy_request_buffering off;
        access_log      /var/log/nginx/seafhttp.access.log seafileformat;
        error_log       /var/log/nginx/seafhttp.error.log;
        '';
      };
      locations."/notification/ping" = {
          proxyPass = "http://127.0.0.1:8083/ping";
          recommendedProxySettings = false;
          extraConfig = ''
          access_log      /var/log/nginx/notification.access.log seafileformat;
          error_log       /var/log/nginx/notification.error.log;
          '';
      };
      locations."/notification" = {
          proxyPass = "http://127.0.0.1:8083";
          recommendedProxySettings = false;
          extraConfig = ''
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
          access_log      /var/log/nginx/notification.access.log seafileformat;
          error_log       /var/log/nginx/notification.error.log;
          '';
      };
      locations."/seafdav" = {
          proxyPass = "http://127.0.0.1:8080";
          recommendedProxySettings = false;
          extraConfig = ''
          
          proxy_set_header   Host $host;
          proxy_set_header   X-Real-IP $remote_addr;
          proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header   X-Forwarded-Host $server_name;
          proxy_set_header   X-Forwarded-Proto $scheme;
          proxy_read_timeout  1200s;
          client_max_body_size 0;

          access_log      /var/log/nginx/seafdav.access.log seafileformat;
          error_log       /var/log/nginx/seafdav.error.log;
          '';
      };
      locations."/media" = {
        proxyPass = "http://localhost:10080";
      };
    };
  };
}