{ config, pkgs, lib, ... }:
let 
nginxLocationWagtailExtraConfig = ''
    # proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_redirect off;
    # proxy_http_version 1.1;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    # proxy_set_header Host $host;
    # proxy_set_header Upgrade $http_upgrade;
    # proxy_set_header Connection $connection_upgrade_keepalive;
'';
in
{ 
  imports = [
    "./nginx/authentik.nix"
    "./nginx/crabfit.nix"
    "./nginx/ghostio.nix"
    "./nginx/guichet.nix"
    "./nginx/hedgedoc.nix"
    "./nginx/odoo.nix"
    "./nginx/static.nix"
    "./nginx/wagtail.nix"
    "./nginx/webdav.nix"
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
    '';
    recommendedProxySettings = true;
    upstreams = {
      "authentik" = {
        extraConfig = ''
          server 10.245.101.35:9000;
          # Improve performance by keeping some connections alive.
          keepalive 10;   
        '';
        commonHttpConfig = ''
          # Upgrade WebSocket if requested, otherwise use keepalive
          map $http_upgrade $connection_upgrade_keepalive {
              default upgrade;
          }
        '';
      };
      "wagtail".extraConfig = ''
        # server unix:/var/lib/wagtail/wagtail-lesgv.sock;
        server https://localhost:8000;
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
 };
}