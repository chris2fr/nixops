{ config, pkgs, lib, ... }:
let 
in
{ 
  services.nginx = {
    enable = true;
    defaultSSLListenPort = 8443;
    defaultHTTPListenPort = 8888;
    defaultListen = [{ addr = "0.0.0.0"; } { addr = "[::0]"; }];
    upstreams."authentik".extraConfig = ''
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
    virtualHosts."auth.lesgrandsvoisins.com" = {
      listen = [
        {addr = "[2a01:4f8:241:4faa::100]"; port="443"; ssl=true;}
        {addr = "[::]"; port="8443"; ssl=true;}
        {addr = "0.0.0.0"; port="8888"; ssl=false;}
      ];
      sslTrustedCertificate = /var/lib/acme/auth.lesgrandsvoisins.com/fullchain.pem;
      sslCertificateKey = /var/lib/acme/auth.lesgrandsvoisins.com/key.pem;
      # sslCertificateChainFile = /var/lib/acme/auth.lesgrandsvoisins.com/chain.pem;
      sslCertificate = /var/lib/acme/auth.lesgrandsvoisins.com/fullchain.pem;
      forceSSL = true;
      locations."/".extraConfig = ''
        proxy_pass http://authentik;
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