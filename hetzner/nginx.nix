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
  # users.users.wwwrun.isSystemUser = true;
  users.users.nginx.group = "wwwrun";

  # users.users.nginx.isSystemUser = true;
  services.nginx = {
    # user = "wwwrun";
    group = "wwwrun";
    enable = true;
    # defaultListen = [
    #     {addr = "[2a01:4f8:241:4faa::100]"; port=443; ssl=true;}
    #     {addr = "[::]"; port=8443; ssl=true;}
    #     {addr = "0.0.0.0"; port=8888; ssl=false;}
    #   ];
    # config = ''
    #    # proxy_headers_hash_max_size 4096;
    # '';
    # defaultSSLListenPort = 8443;
    # defaultHTTPListenPort = 8888;
    # defaultListenAddresses = [ "0.0.0.0" "[::]"];
    defaultListenAddresses = [ "0.0.0.0" "116.202.236.241" "[::]" "[::1]"];
    #defaultListen = [{ addr = "0.0.0.0"; port=8888; } { addr = "[::]"; port=8443; } { addr="[2a01:4f8:241:4faa::100]" ; port=443;} ];
    appendHttpConfig = ''
      proxy_headers_hash_max_size 4096;
      server_names_hash_max_size 4096;
      proxy_headers_hash_bucket_size 256;
    '';
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
    upstreams."wagtail".extraConfig = ''
        server unix:/var/lib/wagtail/wagtail-lesgv.sock;
    '';
    upstreams."wagtailstatic".servers = {
      "10.245.101.15:8888" = {};
    };
    upstreams."wagtailmedia".servers = {"10.245.101.15:8889" = {};};

    virtualHosts."interetpublic.org" = {
      enableACME = true;
      forceSSL = true;
      serverAliases = ["www.interetpublic.org"];
      root = "/var/www/wagtail";
      locations."/" = {
        proxyPass = "http://localhost:8000/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      locations."/static" = {
        proxyPass = null;
      };
    };

    virtualHosts."hdoc.lesgrandsvoisins.com" = {
      serverAliases = [
        "hedgedoc.lesgrandsvoisins.com"
        "hdoc.lesgv.com"
        "hedgedoc.lesgv.com"
        "hdoc.desgrandsvoisins.org"
      ];
      enableACME = true;
      locations."/".proxyPass = "http://localhost:3333/";
      forceSSL = true;
    };

    virtualHosts."hdoc.desgrandsvoisins.com" = {
      enableACME = true;
      locations."/".proxyPass = "http://localhost:3333/";
      forceSSL = true;
    };

    # virtualHosts."www.lesgrandsvoisins.com" = {
    #   #enableACME = true; 
    #   sslCertificate = "/var/lib/acme/www.lesgrandsvoisins.com/fullchain.pem";
    #   sslCertificateKey = "/var/lib/acme/www.lesgrandsvoisins.com/key.pem";
    #   forceSSL = true;
    #   locations."/" = {
    #     proxyPass = "http://10.245.101.15:8080";
    #     # extraConfig = ''
    #     #   proxy_set_header Host $host:$server_port;
    #     # '';
    #   };
    # };


    virtualHosts."gvoisin.resdigita.com" = {
    serverAliases = [
      "keycloak.resdigita.com"
      "discourse.resdigita.com"
      "meet.resdigita.com"
      "jswiki.resdigita.com"
      "gvoisin.desgrandsvoisins.org"
       "gvoisin.desgrandsvoisins.com"
       "gvoisin.lesgrandsvoisins.com"
       "gvoisin.desgv.com"
       "gvoisin.lesgv.com"
      ];
      # sslCertificate = "/var/lib/acme/gvoisin.resdigita.com/fullchain.pem";
      # sslCertificateKey = "/var/lib/acme/gvoisin.resdigita.com/key.pem";
      enableACME = true;
      forceSSL = true;
      root =  "/var/www/wagtail/";
      locations."/" = {
        #proxyPass = "http://10.245.101.15:8080";
        proxyPass = "https://wagtail/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      locations."/favicon.ico" = { proxyPass = null; };
      locations."/static" = { proxyPass = null; };
      locations."/media" = { proxyPass = null; };
      # locations."/.well-known" = { proxyPass = null; };
    };

    virtualHosts."odoo4.resdigita.com" = {
      #enableACME = true; 
      serverAliases = [
        "voisandcom.resdigita.com"
        "voisandorg.resdigita.com"
        "lesgvcom.resdigita.com"
        "villagevoisincom.resdigita.com"
        "baldridgegvoisorg.resdigita.com"
        "ooolesgrandsvoisinscom.resdigita.com"
        "lesgrandsvoisinscom.resdigita.com"
        "odoo4.desgv.com"
         "odoo4.lesgv.com"
          "odoo4.desgrandsvoisins.org"
          "odoo4.desgrandsvoisins.com"
      ];
      enableACME=true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://10.245.101.173:8069/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      locations."/html/" = {
        root = "/var/www/wagtail/";
        proxyPass = null;
      };
    };

    virtualHosts."crabfit.resdigita.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:3080/";
      };
    };
        

    virtualHosts."odoo3.resdigita.com" = {
      serverAliases = [
        "lgvcoop.resdigita.com"
        "odoo3.desgv.com"
         "odoo3.lesgv.com"
          "odoo3.desgrandsvoisins.org"
          "odoo3.desgrandsvoisins.com"
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

    virtualHosts."odoo2.resdigita.com" = {
      serverAliases = [
        "odoo2.desgv.com"
         "odoo2.lesgv.com"
          "odoo2.desgrandsvoisins.org"
          "odoo2.desgrandsvoisins.com"
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

    virtualHosts."odoo1.resdigita.com" = {
      serverAliases = [
        "actentioncom.resdigita.com"
        "gvoisorg.resdigita.com"
        "manngvoisorg.resdigita.com"
        "manndigital.resdigita.com"
        "mannfr.resdigita.com"
        "odoo1.desgv.com"
         "odoo1.lesgv.com"
          "odoo1.desgrandsvoisins.org"
          "odoo1.desgrandsvoisins.com"
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

    virtualHosts."doc.resdigita.com" = {
      serverAliases = ["resdigita.com" "resdigita.org" "www.resdigita.org" "doc.desgrandsvoisins.org"  "doc.lesgrandsvoisins.com"];
       globalRedirect = "doc.desgrandsvoisins.com";
      enableACME = true;
      forceSSL = true;
      root = "/var/www/resdigitacom";
    };

    virtualHosts."doc.desgrandsvoisins.com" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/resdigitacom";
    };

    virtualHosts."guichet.desgrandsvoisins.org" = {
      serverAliases = ["app.lesgrandsvoisins.com" "guichet.lesgrandsvoisins.com"];
      globalRedirect = "guichet.desgrandsvoisins.com";
      enableACME = true; 
      forceSSL = true;    
    };
    virtualHosts."guichet.desgrandsvoisins.com" = {
      enableACME = true; 
      forceSSL = true;     
      # sslCertificate = "/var/lib/acme/guichet.lesgrandsvoisins.com/fullchain.pem";
      # sslCertificateKey = "/var/lib/acme/guichet.lesgrandsvoisins.com/key.pem";
      # sslTrustedCertificate = "/var/lib/acme/guichet.lesgrandsvoisins.com/fullchain.pem";
      root = "/var/www/guichet";
      locations."/" = {
        proxyPass = "http://[::1]:9991/";
        # proxyPass = "https://guichet.lesgrandsvoisins.com";
      };
      locations."/favicon.ico" = { proxyPass = null; };
      locations."/static" = { proxyPass = null; };
      locations."/media" = { proxyPass = null; };
      # locations."/.well-known" = { proxyPass = null; };
    };

    virtualHosts."www.lesgrandsvoisins.fr" = {
     serverAliases = ["desgv.com" "francemali.org"
      "www.francemali.org" "shitmuststop.com" "www.shitmuststop.com" "www.desgv.com" "lesgrandsvoisins.fr"  "hopgv.com" "www.hopgv.com"  "www.lesgv.com" "lesgv.com"];
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
      if ($host = 'francemali.com') {
          return 301 $scheme://www.$host$request_uri;
      }
      if ($host = 'lesgv.com') {
          return 301 $scheme://www.$host$request_uri;
      }
      if ($host = 'francemali.com') {
          return 301 $scheme://www.$host$request_uri;
      }
      if ($host = 'lesgrandsvoisins.fr') {
          return 301 $scheme://www.$host$request_uri;
      }
      '';
    };
    virtualHosts."www.desgrandsvoisins.org" = {
      serverAliases = ["desgrandsvoisins.org"  "desgrandsvoisins.com"];
      globalRedirect = "www.desgrandsvoisins.com/";
       enableACME = true;
       forceSSL = true;
    };
    virtualHosts."www.lesgrandsvoisins.com" = {   
      serverAliases = ["lesgrandsvoisins.com"];
      sslCertificateKey = "/etc/ssl/lesgrandsvoisins.com.key";
      sslCertificate = "/etc/ssl/lesgrandsvoisins.com.crt";
      sslTrustedCertificate = "/etc/ssl/lesgrandsvoisins.com.ca-bundle";
      globalRedirect = "www.desgrandsvoisins.com/";
      forceSSL = true;
    };
    virtualHosts."www.desgrandsvoisins.com" = {      
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
      # locations."/.well-known" = { proxyPass = null; };
    };
    virtualHosts."blog.desgrandsvoisins.org" = {
      root = "/var/www/ghostio/";
      enableACME = true;
      forceSSL = true;
      serverAliases = ["blog.resdigita.com" "blog.lesgrandsvoisins.com"];
      globalRedirect = "blog.desgrandsvoisins.com";
    };

    virtualHosts."blog.desgrandsvoisins.com" = {
      root = "/var/www/ghostio/";
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:2368/";
      };
    };

    virtualHosts."apicrabfit.resdigita.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:3000/";
      };
    };

    virtualHosts."dav.desgrandsvoisins.org" = {
      enableACME = true;
      forceSSL = true;
      globalRedirect = "dav.desgrandsvoisins.com";
    };

    virtualHosts."dav.lesgrandsvoisins.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "https://dav.lesgrandsvoisins.com:8443/";
      };
    };


    virtualHosts."list.desgrandsvoisins.org" = {
      serverAliases = ["list.desgrandsvoisins.com"];
      enableACME = true;
      forceSSL = true;
      globalRedirect = "list.lesgrandsvoisins.com";
    };

    virtualHosts."dav.desgrandsvoisins.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "https://dav.desgrandsvoisins.com:8443/";
      };
    };


    # virtualHosts."mail.lesgrandsvoisins.com" = {
    #   serverName = "mail.lesgrandsvoisins.com";
    #   sslCertificate = "/var/lib/acme/mail.lesgrandsvoisins.com/fullchain.pem";
    #   sslCertificateKey = "/var/lib/acme/mail.lesgrandsvoisins.com/key.pem";
    #   sslTrustedCertificate = "/var/lib/acme/mail.lesgrandsvoisins.com/fullchain.pem";
    #   forceSSL = true;
    #   locations."/" = {
    #     proxyPass = "https://mail.lesgrandsvoisins.com";
    #   };
    # };

    virtualHosts."secret.desgrandsvoisins.org" = {
      enableACME = true;
      forceSSL = true;
      globalRedirect = "secret.desgrandsvoisins.com";
    };

    virtualHosts."secret.lesgrandsvoisins.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "https://secret.lesgrandsvoisins.com:8443/";
      };
    };

    virtualHosts."secret.desgrandsvoisins.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "https://secret.desgrandsvoisins.com:8443/";
      };
    };

    virtualHosts."hetzner005.lesgrandsvoisins.com" = {
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
    recommendedProxySettings = true;

    virtualHosts."auth.lesgrandsvoisins.com" = {
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


     virtualHosts."www.maelanc.com" = {
      enableACME=true;
      forceSSL=true;
      locations."/" = {
        proxyPass = "http://10.245.101.15:8080/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      locations."/favicon.ico" = { proxyPass = http://10.245.101.15:8898/favicon.ico; };
      locations."/static/" = { proxyPass = "http://wagtailstatic/"; };
      locations."/media/" = { proxyPass = "http://wagtailmedia/"; };
     };

     
    virtualHosts."wagtail.resdigita.com" = {
      root =  "/var/www/wagtail/";
      serverAliases = [
        "manncoach.resdigita.com"
        "maelanc.com"
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


  };

  

}