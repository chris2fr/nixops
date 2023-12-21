{ config, pkgs, lib, ... }:
let 
  extraProxyHeaders = ''
    proxy_redirect off;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    # proxy_set_header Host $host:$server_port;
    '';
in
{ 
  services.nginx.virtualHosts = {
      "dav.desgrandsvoisins.org" = {
        serverAliases = ["dav.lesgrandsvoisins.com" "dav.desgrandsvoisins.com"];
        enableACME = true;
        forceSSL = true;
        globalRedirect = "dav.resdigita.com";
      };
      "dav.resdigita.com" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "https://dav.resdigita.com:8443/";
          extraConfig = extraProxyHeaders;
        };
        extraConfig = ''
        location = / {
            return 302 /redirect;
        }
        '';
      };
      "secret.desgrandsvoisins.org" = {
        enableACME = true;
        forceSSL = true;
        serverAliases = ["secret.lesgrandsvoisins.com" "secret.desgrandsvoisins.com" "secret.resdigita.com"];
        globalRedirect = "keeweb.resdigita.com";
      };
      "keeweb.resdigita.com" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "https://keeweb.resdigita.com:8443/";
          extraConfig = extraProxyHeaders;
        };
        extraConfig = ''
        location = / {
            return 302 /redirect;
        }
        '';
      };
  };
}