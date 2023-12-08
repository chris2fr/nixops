{ config, pkgs, lib, ... }:
let 
in
{ 
  services.nginx = {
    enable = true;
    defaultSSLListenPort = 8443;
    defaultHTTPListenPort = 8888;
    defaultListen = [{ addr = "0.0.0.0"; } { addr = "[::0]"; }];
    virtualHosts."auth.lesgrandsvoisins.com" = {
      sslTrustedCertificate = /var/lib/acme/auth.lesgrandsvoisins.com/fullchain.pem;
      sslCertificateKey = /var/lib/acme/auth.lesgrandsvoisins.com/key.pem;
      # sslCertificateChainFile = /var/lib/acme/auth.lesgrandsvoisins.com/chain.pem;
    };
  };

}