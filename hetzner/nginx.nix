{ config, pkgs, lib, ... }:
let 
in
{ 
  services.nginx = {
    enable = true;
    defaultSSLListenPort = 8443;
    defaultHTTPListenPort = 8888;
    defaultListen = [{ addr = "0.0.0.0"; } { addr = "[::0]"; }];
    config = ''
    upstream authentik {
      server localhost:9443;
      # Improve performance by keeping some connections alive.
      keepalive 10;
      # Upgrade WebSocket if requested, otherwise use keepalive
      map $http_upgrade $connection_upgrade_keepalive {
          default upgrade;
          \'\'        \'\';
      }
    }
    '';
    virtualHosts."auth.lesgrandsvoisins.com" = {
      sslTrustedCertificate = /var/lib/acme/auth.lesgrandsvoisins.com/fullchain.pem;
      sslCertificateKey = /var/lib/acme/auth.lesgrandsvoisins.com/key.pem;
      # sslCertificateChainFile = /var/lib/acme/auth.lesgrandsvoisins.com/chain.pem;
      sslCertificate = /var/lib/acme/auth.lesgrandsvoisins.com/cert.pem;
      forceSSL = true;
      locations."/".extraConfig = ''
        proxy_pass https://authentik;
        proxy_http_version 1.1;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade_keepalive;
      '';
    };
  };

}