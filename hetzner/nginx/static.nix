{ config, pkgs, lib, ... }:
let 
in
{ 
  services.nginx.virtualHosts = {
      "doc.resdigita.com" = {
        serverAliases = ["resdigita.com" "resdigita.org" "www.resdigita.org" "doc.desgrandsvoisins.org"  "doc.lesgrandsvoisins.com"];
         globalRedirect = "doc.desgrandsvoisins.com";
        enableACME = true;
        forceSSL = true;
        root = "/var/www/resdigitacom";
      };
      "doc.desgrandsvoisins.com" = {
        enableACME = true;
        forceSSL = true;
        root = "/var/www/resdigitacom";
      };
      "hetzner005.lesgrandsvoisins.com" = {
        # addSSL = true;
        sslCertificate = "/var/lib/acme/hetzner005.lesgrandsvoisins.com/fullchain.pem";
        sslCertificateKey = "/var/lib/acme/hetzner005.lesgrandsvoisins.com/key.pem";
        sslTrustedCertificate = "/var/lib/acme/hetzner005.lesgrandsvoisins.com/fullchain.pem";
        root = "/var/www/resdigitacom";
        # listenAddresses = [ "0.0.0.0" "116.202.236.241" "[::]" "[::1]"];
        forceSSL = true;
        # listen = [{addr="0.0.0.0";port = 8443; ssl=true;} {addr="[::]";port = 8443; ssl=true;}{addr="116.202.236.241";port = 8443; ssl=true;} {addr="[::1]";port = 8443; ssl=true;}];
        # locations."/" = {
        #   proxyPass = "https://hetzner005.lesgrandsvoisins.com";
        # #   extraConfig = ''
        # #     # proxy_redirect off;
        # #     proxy_set_header Host $host:$server_port;
        # #     # proxy_set_header Host $http_host;
        # #     proxy_set_header X-Real-IP $remote_addr;
        # #     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        # #     proxy_pass_request_headers      on;
        # #     # proxy_redirect default;
        # #     # proxy_redirect ~^(https?://[^:]+):\d+(?<relpath>/.+)$ https://www.lesgrandsvoisins.com$relpath;
        # #   '';
        # };
      };
  };
}