{ config, pkgs, lib, ... }:
let 
nginxLocationWagtailExtraConfig = ''
    # proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_redirect off;
    # proxy_http_version 1.1;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    # proxy_set_header Host $host;
    # proxy_set_header Upgrade $http_upgrade;
    # proxy_set_header Connection $connection_upgrade_keepalive;
'';
in
{ 
  services.nginx.virtualHosts = {
    "les.gv.coop" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/lesgv";
     };
    "www.hopgv.com" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/interetpublic";
      serverAliases = ["hopgv.com"];
      extraConfig = ''
        if ($host != "www.hopgv.com") {
          return 301 $scheme://www.hopgv.com$request_uri;
        }
      '';
    };
    "www.interet-public.org" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/interetpublic";
      serverAliases = ["interet-public.org" "interetpublic.org" "www.interetpublic.org"];
      extraConfig = ''
        if ($host != "www.interet-public.org") {
          return 301 $scheme://www.interet-public.org$request_uri;
        }
      '';
    };
    "interetpublic.org" = {
      enableACME = true;
      forceSSL = true;
      # globalRedirect = "www.interetpublic.com";
      locations."/".return = "301 https://www.interetpublic.org";
    };
    "meet.resdigita.com" = {
      serverAliases = ["meet.lesgv.org"];
      enableACME = true;
      forceSSL = true;
      root =  "/var/www/wagtail/";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8000/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      locations."/favicon.ico" = { proxyPass = null; };
      locations."/static" = { proxyPass = null; };
      locations."/media" = { proxyPass = null; };
      locations."/.well-known" = { proxyPass = null; };
    };
    "meet.desgrandsvoisins.org" = {
      serverAliases = [
        "meet.desgv.com" 
        "meet.desgrandsvoisins.com"
      ];
      enableACME = true;
      forceSSL = true;
      globalRedirect = "meet.resdigita.com";
    };
    "gvoisin.resdigita.com" = {
      serverAliases = [
        "meet.lesgrandsvoisins.com"
        "discourse.resdigita.com"
        # "jswiki.resdigita.com"
        # "gvoisin.desgrandsvoisins.org"
        #  "gvoisin.desgrandsvoisins.com"
        #  "gvoisin.lesgrandsvoisins.com"
        #  "gvoisin.desgv.com"
        #  "gvoisin.lesgv.com"
         "syprete.com"
      ];
      enableACME = true;
      forceSSL = true;
      root =  "/var/www/wagtail/";
      locations."/" = {
        #proxyPass = "http://10.245.101.15:8080";
        proxyPass = "http://127.0.0.1:8000/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      locations."/favicon.ico" = { proxyPass = null; };
      locations."/static" = { proxyPass = null; };
      locations."/media" = { proxyPass = null; };
      locations."/.well-known" = { proxyPass = null; };
    };

    "wagtail.resdigita.com" = {
      serverAliases = [
        "www.lesartsvoisins.com"
        "lesartsvoisins.com"
        "publicinter.org"
        "www.publicinter.org"
        # "publicinter.net"
        # "www.publicinter.net"
        # "www.coopgv.com"
        # "coopgv.com"
        "www.coopgv.org"
        "coopgv.org"
        "www.gvcoop.com"
        "gvcoop.com"  
        "gv.coop"
        "www.gv.coop"  
        # "wagtail.gv.coop"
        "wagtail.lesgv.org"
      ];
      enableACME = true;
       forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8000/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      root = "/var/www/wagtail";
      locations."/favicon.ico" = { proxyPass = null; };
      locations."/static" = { proxyPass = null; };
      locations."/media" = { proxyPass = null; };
      locations."/.well-known" = { proxyPass = null; };
      extraConfig = ''
        if ($host = 'gv.coop') {
            return 301 $scheme://www.$host$request_uri;
        }
      '';
    };
    
    "apostrophecms.resdigita.com" = {
      root =  "/var/www/wagtail/";
      serverAliases = [
        "manncoach.resdigita.com"
        "resdigitacom.resdigita.com"
        "distractivescom.resdigita.com"
        "whowhatetccom.resdigita.com"
        "coopgvcom.resdigita.com"
        "popuposcom.resdigita.com"
        "grandsvoisinscom.resdigita.com"
        "forumgrandsvoisinscom.resdigita.com"
        "discourselesgvcom.resdigita.com"
        "iriviorg.resdigita.com"
        "hyperattentioncom.resdigita.com"
        "forumgdvoisinscom.resdigita.com"
        "agoodvillagecom.resdigita.com"
        "configmagiccom.resdigita.com"
        "caplancitycom.resdigita.com"
        "quiquoietccom.resdigita.com"
        "lesartsvoisinscom.resdigita.com"
        "maelanccom.resdigita.com"
        "manncity.resdigita.com"
        "focusplexcom.resdigita.com"
        "vlgorg.resdigita.com"
        "oldlesgrandsvoisinscom.resdigita.com"
        "cooptellgv.resdigita.com"
        "howwownowcom.resdigita.com"
        "aaalesgrandsvoisinscom.resdigita.com"
        "oldmanndigital.resdigita.com"
        "resolvactivecom.resdigita.com"
        "gvcity.resdigita.com"
        "toutdouxlissecom.resdigita.com"
        "iciwowcom.resdigita.com"
        "apostrophecms.lesgv.org"
      ];
      enableACME = true; 
      # sslCertificate = "/var/lib/acme/wagtail.resdigita.com/fullchain.pem";
      # sslCertificateKey = "/var/lib/acme/wagtail.resdigita.com/key.pem";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://10.245.101.15:8080/";
        extraConfig = nginxLocationWagtailExtraConfig;
        # extraConfig = ''
        #   proxy_set_header Host $host:$server_port;
        # '';
      };
      locations."/favicon.ico" = { proxyPass = http://10.245.101.15:8898/favicon.ico; };
      locations."/static/" = { proxyPass = "http://wagtailstatic/"; };
      locations."/media/" = { proxyPass = "http://wagtailmedia/"; };
    };

    "www.lesgrandsvoisins.fr" = {
     serverAliases = ["desgv.com" "francemali.org"
      "www.francemali.org" "shitmuststop.com" "www.shitmuststop.com" "www.desgv.com" "lesgrandsvoisins.fr" 
      "www.lesgv.com" "lesgv.com" "www.lesgv.org" "lesgv.org" "www.gv.coop" "gv.coop" "www.coopgv.com" "coopgv.com" "www.coopgv.org" "coopgv.org" 
      "ghost.resdigita.com"  "mail.resdigita.com" "listmonk.resdigita.com" "lesgv.org" ];
      enableACME = true;
      # sslCertificate = "/var/lib/acme/www.lesgrandsvoisins.fr/fullchain.pem";
      # sslCertificateKey = "/var/lib/acme/www.lesgrandsvoisins.fr/key.pem";
      # sslTrustedCertificate = "/var/lib/acme/www.lesgrandsvoisins.fr/fullchain.pem";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8000/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      locations."/favicon.ico" = { proxyPass = null; };
      locations."/static" = { proxyPass = null; };
      locations."/media" = { proxyPass = null; };
      root = "/var/www/wagtail";
      extraConfig = ''
      if ($host = 'desgv.com') {
          return 301 $scheme://www.$host$request_uri;
      }
      if ($host = 'maelanc.com') {
          return 301 $scheme://www.$host$request_uri;
      }
      if ($host = 'francemali.com') {
          return 301 $scheme://www.$host$request_uri;
      }
      # if ($host  ~  /lesgv.org|lesgv.com|www.lesgv.com|www.lesgv.org|gv.coop|www.gv.coop|coopgv.com|coopgv.org|www.coopgv.com|www.coopgv.org/ ) {
      #     # return 301 $scheme://les.$host$request_uri;
      #     return 301 
      if ($host = 'lesgv.org') {
          return 301 $scheme://les.gv.coop$request_uri;
      }
      if ($host = 'www.lesgv.org') {
          return 301 $scheme://les.gv.coop$request_uri;
      }
      if ($host = 'lesgv.com') {
          return 301 $scheme://les.gv.coop$request_uri;
      }
      if ($host = 'www.lesgv.com') {
          return 301 $scheme://les.gv.coop$request_uri;
      }
      if ($host = 'gv.coop') {
          return 301 $scheme://les.gv.coop$request_uri;
      }
      if ($host = 'www.gv.coop') {
          return 301 $scheme://les.gv.coop$request_uri;
      }
      if ($host = 'francemali.org') {
          return 301 $scheme://www.$host$request_uri;
      }
      if ($host = 'lesgrandsvoisins.fr') {
          return 301 $scheme://www.$host$request_uri;
      }
      '';
    };
    "www.desgrandsvoisins.org" = {
      serverAliases = ["desgrandsvoisins.org"  "desgrandsvoisins.com" "www.desgrandsvoisins.com"];
      globalRedirect = "www.lesgrandsvoisins.com";
       enableACME = true;
       forceSSL = true;
    };

    "lesgrandsvoisins.com" = {   
      sslCertificateKey = "/etc/ssl/lesgrandsvoisins.com.key";
      sslCertificate = "/etc/ssl/lesgrandsvoisins.com.crt";
      sslTrustedCertificate = "/etc/ssl/lesgrandsvoisins.com.ca-bundle";
      forceSSL = true;
      globalRedirect = "www.lesgrandsvoisins.com";
    };   
    "www.lesgrandsvoisins.com" = {      
      # serverAliases = ["lesgrandsvoisins.com"];
      sslCertificateKey = "/etc/ssl/lesgrandsvoisins.com.key";
      sslCertificate = "/etc/ssl/lesgrandsvoisins.com.crt";
      sslTrustedCertificate = "/etc/ssl/lesgrandsvoisins.com.ca-bundle";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8000/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      root = "/var/www/wagtail";
      locations."/favicon.ico" = { proxyPass = null; };
      locations."/static" = { proxyPass = null; };
      locations."/media" = { proxyPass = null; };
      locations."/.well-known" = { proxyPass = null; };
    };
    "www.maelanc.com" = {
      serverAliases = ["maelanc.com"];
      enableACME = true;
       forceSSL = true;
       extraConfig = ''
      if ($host = 'maelanc.com') {
          return 301 $scheme://www.$host$request_uri;
      }
      '';
      locations."/" = {
        proxyPass = "http://127.0.0.1:8000/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      root = "/var/www/wagtail";
      locations."/favicon.ico" = { proxyPass = null; };
      locations."/static" = { proxyPass = null; };
      locations."/media" = { proxyPass = null; };
      locations."/.well-known" = { proxyPass = null; };
    };
     "mann.fr" = {   
       enableACME=true;
       forceSSL=true;
       globalRedirect = "www.mann.fr";
     };   
     "www.mann.fr" = {
      enableACME=true;
       forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8000/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      root = "/var/www/wagtail";
      locations."/favicon.ico" = { proxyPass = null; };
      locations."/static" = { proxyPass = null; };
      locations."/media" = { proxyPass = null; };
      locations."/.well-known" = { proxyPass = null; };
    };
  };
}
