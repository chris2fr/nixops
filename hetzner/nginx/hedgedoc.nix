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
      "hedgedoc.lesgrandsvoisins.com" = {
        serverAliases = ["hedgedoc.lesgv.org" "hedgedoc.resdigita.com" "hedgedoc.village.ngo" "hedgedoc.gv.coop" "mark.lesgrandsvoisins.com" ];
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://localhost:3333/";
        extraConfig = ''
          if ($host != "mark.lesgrandsvoisins.com") {
            return 302 $scheme://mark.lesgrandsvoisins.com$request_uri;
          }
        '';
      };
      #  "hedgedoc.gv.coop" = {
      #   enableACME = true;
      #   forceSSL = true;
      #   locations."/".proxyPass = "http://localhost:3333/";
      # };
  };
}