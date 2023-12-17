{ config, pkgs, lib, ... }:
let 
in
{ 
  services.nginx = {
    enable = true;
    # defaultListen = [
    #     {addr = "[2a01:4f8:241:4faa::100]"; port=443; ssl=true;}
    #     {addr = "[::]"; port=8443; ssl=true;}
    #     {addr = "0.0.0.0"; port=8888; ssl=false;}
    #   ];
    defaultSSLListenPort = 8443;
    defaultHTTPListenPort = 8888;
    # defaultListenAddresses = [ "0.0.0.0" "[::]"];
    defaultListenAddresses = [ "0.0.0.0" "116.202.236.241" "[::]" "[::1]"];
    #defaultListen = [{ addr = "0.0.0.0"; port=8888; } { addr = "[::]"; port=8443; } { addr="[2a01:4f8:241:4faa::100]" ; port=443;} ];
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
    virtualHosts."hetzner005.lesgrandsvoisins.com:8443" = {
      addSSL = true;
      sslCertificate = "/var/lib/acme/hetzner005.lesgrandsvoisins.com/fullchain.pem";
      sslCertificateKey = "/var/lib/acme/hetzner005.lesgrandsvoisins.com/key.pem";
      locations."/".proxyPass = "https://dav.lesgrandsvoisins.com";
    };
    recommendedProxySettings = true;

    virtualHosts."auth.lesgrandsvoisins.com" = {
      # listen = [
      #   {addr = "[2a01:4f8:241:4faa::100]"; port=443; ssl=true;}
      #   {addr = "[::]"; port=8443; ssl=true;}
      #   {addr = "0.0.0.0"; port=8888; ssl=false;}
      # ];
      # listen = [
      #   {addr = "[2a01:4f8:241:4faa::100]"; port=443; ssl=true;}
      #   {addr = "[::]"; port=8443; ssl=true;}
      #   {addr = "0.0.0.0"; port=8888; ssl=false;}
      #   {addr = "127.0.0.1"; port=8888; ssl=false;}
      # ];
      # listen = [{ addr = "0.0.0.0"; port=8888; } { addr = "[::]"; port=8888; } { addr = "[::]"; port=8443; ssl=true; }  { addr = "0.0.0.0"; port=8443; ssl=true; } ];
      default = true;
      #listen = [{ addr = "0.0.0.0"; port=8888; } { addr = "[::]"; port=8443; ssl=true; } { addr="[2a01:4f8:241:4faa::100]" ; port=443; ssl=true;} ];
      # sslTrustedCertificate = "/var/lib/acme/auth.lesgrandsvoisins.com/fullchain.pem";
      sslCertificateKey = "/var/lib/acme/auth.lesgrandsvoisins.com/key.pem";
      # sslCertificateChainFile = /var/lib/acme/auth.lesgrandsvoisins.com/chain.pem;
      sslCertificate = "/var/lib/acme/auth.lesgrandsvoisins.com/fullchain.pem";
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
        # proxy_buffering off;
        # tcp_nodelay on;    
     };
  };

}