{ config, pkgs, lib, ... }:
let 
in
{ 
  services.nginx.virtualHosts = {
      "auth.lesgrandsvoisins.com" = {
        serverAliases = ["auth.desgrandsvoisins.org" "auth.desgrandsvoisins.com"];
        enableACME = true;
        # listenAddresses = [ "0.0.0.0" "116.202.236.241" "[::]" "[::1]"];
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
        # sslCertificateKey = "/var/lib/acme/auth.lesgrandsvoisins.com/key.pem";
        # # sslCertificateChainFile = /var/lib/acme/auth.lesgrandsvoisins.com/chain.pem;
        # sslCertificate = "/var/lib/acme/auth.lesgrandsvoisins.com/fullchain.pem";
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