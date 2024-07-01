{ config, pkgs, lib, ... }:
let 
in
{ 
  services.nginx.virtualHosts = {
      # "hdoc.desgrandsvoisins.org" = {
      #   enableACME = true;
      #   forceSSL = true;
      #   serverAliases = [
      #     "hdoc.desgrandsvoisins.com"
      #     "hdoc.desgv.com"
      #     "hdoc.lesgrandsvoisins.com"
      #     "hdoc.lesgv.com"
      #     "hdoc.resdigita.com"
      #     "hedgedoc.desgrandsvoisins.com"
      #     "hedgedoc.desgv.com"
      #     "hedgedoc.lesgrandsvoisins.com"
      #     "hedgedoc.lesgv.com"
      #     "hedgedoc.lesgv.org"
      #   ];
      #   globalRedirect = "hedgedoc.resdigita.com";
      # };
      "hedgedoc.village.ngo" = {
        serverAliases = ["hedgedoc.lesgv.org" "hedgedoc.resdigita.com"];
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://localhost:3333/";
        extraConfig = ''
          if ($host != "vikunja.village.ngo") {
            return 302 $scheme://vikunja.village.ngo$request_uri;
          }
        '';
      };
       "hedgedoc.gv.coop" = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://localhost:3333/";
      };
  };
}