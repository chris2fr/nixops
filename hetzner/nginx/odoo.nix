{ config, pkgs, lib, ... }:
let 
in
{ 
  services.nginx.virtualHosts = {
      "odoo1.resdigita.com" = {
        serverAliases = [
          "actentioncom.resdigita.com"
          "gvoisorg.resdigita.com"
          "manngvoisorg.resdigita.com"
          "manndigital.resdigita.com"
          "mannfr.resdigita.com"
         # "odoo1.desgv.com"
          # "odoo1.lesgv.com"
          #  "odoo1.desgrandsvoisins.org"
          #  "odoo1.desgrandsvoisins.com"
            #"odoo1.gv.coop"
            "odoo1.lesgv.org"
        ];
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://10.245.101.158:8069/";
          extraConfig = ''
            proxy_set_header Host $host:$server_port;
          '';
        };
      };
      "odoo2.resdigita.com" = {
        serverAliases = [
         # "odoo2.desgv.com"
         #  "odoo2.lesgv.com"
         #   "odoo2.desgrandsvoisins.org"
         #   "odoo2.desgrandsvoisins.com"
            #"odoo2.gv.coop"
            "odoo2.lesgv.org"
        ];
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://10.245.101.82:8069/";
          extraConfig = ''
            proxy_set_header Host $host:$server_port;
          '';
        };
      };
      "odoo3.resdigita.com" = {
        serverAliases = [
          "lgvcoop.resdigita.com"
         # "odoo3.desgv.com"
          # "odoo3.lesgv.com"
          #  "odoo3.desgrandsvoisins.org"
          #  "odoo3.desgrandsvoisins.com"
            #"odoo3.gv.coop"
            "odoo3.lesgv.org"
        ];
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://10.245.101.128:8069/";
          extraConfig = ''
            proxy_set_header Host $host:$server_port;
          '';
        };
        locations."/html/" = {
          root = "/var/www/sites/goodv.org/";
          proxyPass = null;
        };
      };
      "odoo4.resdigita.com" = {
        #enableACME = true; 
        serverAliases = [
         # "voisandcom.resdigita.com"
         # "voisandorg.resdigita.com"
          "lesgvcom.resdigita.com"
          # "villagevoisincom.resdigita.com"
          "baldridgegvoisorg.resdigita.com"
          "ooolesgrandsvoisinscom.resdigita.com"
          "lesgrandsvoisinscom.resdigita.com"
         # "odoo4.desgv.com"
         # "odoo4.lesgv.com"
         # "odoo4.desgrandsvoisins.org"
          #"odoo4.desgrandsvoisins.com"
          #"odoo4.gv.coop"
          "odoo4.lesgv.org"
        ];
        enableACME=true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://10.245.101.173:8069/";
          # extraConfig = nginxLocationWagtailExtraConfig;
        };
        locations."/html/" = {
          root = "/var/www/wagtail/";
          proxyPass = null;
        };
      };

  };
}