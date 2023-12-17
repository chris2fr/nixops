{ config, pkgs, lib, ... }:
let 
in
{ 
  # users.users.wwwrun.isSystemUser = true;
  users.users.nginx.group = "wwwrun";

  # users.users.nginx.isSystemUser = true;
  services.nginx = {
    # user = "wwwrun";
    group = "wwwrun";
    enable = true;
    appendHttpConfig = ''
      server_names_hash_max_size 4096;
    '';
    # defaultListen = [
    #     {addr = "[2a01:4f8:241:4faa::100]"; port=443; ssl=true;}
    #     {addr = "[::]"; port=8443; ssl=true;}
    #     {addr = "0.0.0.0"; port=8888; ssl=false;}
    #   ];
    # config = ''
    #    # proxy_headers_hash_max_size 4096;
    # '';
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
    upstreams."wagtail".extraConfig = ''
        server unix:/var/lib/wagtail/wagtail-lesgv.sock;
    '';

    virtualHosts."interetpublilc.org" = {
      enableACME = true;
      forceSSL = true;
      serverName = "www.interetpublic.org";
      serverAliases = ["interetpublic.org"];
      root = "/var/www/wagtail";
      locations."/" = {
        proxyPass = "http://localhost:8000";
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
      ];
      sslCertificate = "/var/lib/acme/hdoc.lesgrandsvoisins.com/fullchain.pem";
      sslCertificateKey = "/var/lib/acme/hdoc.lesgrandsvoisins.com/key.pem";
      locations."/".proxyPass = "http://localhost:3000/";
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
      ];
      sslCertificate = "/var/lib/acme/gvoisin.resdigita.com/fullchain.pem";
      sslCertificateKey = "/var/lib/acme/gvoisin.resdigita.com/key.pem";
      forceSSL = true;
      root =  "/var/www/wagtail/";
      locations."/" = {
        #proxyPass = "http://10.245.101.15:8080";
        proxyPass = "https://wagtail";
        extraConfig = ''
          proxy_set_header Host $host:$server_port;
        '';
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
      ];
      sslCertificate = "/var/lib/acme/odoo4.resdigita.com/fullchain.pem";
      sslCertificateKey = "/var/lib/acme/odoo4.resdigita.com/key.pem";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://10.245.101.173:8069";
        extraConfig = ''
          proxy_set_header Host $host:$server_port;
        '';
      };
      locations."/html/" = {
        root = "/var/www/wagtail/";
        proxyPass = null;
      };
    };
        

    virtualHosts."odoo3.resdigita.com" = {
      serverAliases = [
        "lgvcoop.resdigita.com"
      ];
      #enableACME = true; 
      sslCertificate = "/var/lib/acme/odoo3.resdigita.com/fullchain.pem";
      sslCertificateKey = "/var/lib/acme/odoo3.resdigita.com/key.pem";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://10.245.101.128:8069";
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
      # enableACME = true;      
      sslCertificate = "/var/lib/acme/odoo2.resdigita.com/fullchain.pem";
      sslCertificateKey = "/var/lib/acme/odoo2.resdigita.com/key.pem";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://10.245.101.82:8069";
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
      ];
      #enableACME = true;
      sslCertificate = "/var/lib/acme/odoo1.resdigita.com/fullchain.pem";
      sslCertificateKey = "/var/lib/acme/odoo1.resdigita.com/key.pem";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://10.245.101.158:8069";
        extraConfig = ''
          proxy_set_header Host $host:$server_port;
        '';
      };
    };

    virtualHosts."doc.resdigita.com" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/resdigitacom";
    };

    virtualHosts."guichet.lesgrandsvoisins.com" = {
      serverAliases = ["app.lesgrandsvoisins.com"];
      serverName = "guichet.lesgrandsvoisins.com";
      sslCertificate = "/var/lib/acme/guichet.lesgrandsvoisins.com/fullchain.pem";
      sslCertificateKey = "/var/lib/acme/guichet.lesgrandsvoisins.com/key.pem";
      sslTrustedCertificate = "/var/lib/acme/guichet.lesgrandsvoisins.com/fullchain.pem";
      forceSSL = true;
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
      sslCertificate = "/var/lib/acme/www.lesgrandsvoisins.fr/fullchain.pem";
      sslCertificateKey = "/var/lib/acme/www.lesgrandsvoisins.fr/key.pem";
      sslTrustedCertificate = "/var/lib/acme/www.lesgrandsvoisins.fr/fullchain.pem";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8000/";
      };
      locations."/favicon.ico" = { proxyPass = null; };
      locations."/static" = { proxyPass = null; };
      locations."/media" = { proxyPass = null; };
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

    virtualHosts."www.lesgrandsvoisins.com" = {
      serverName = "www.lesgrandsvoisins.com";
      serverAliases = ["lesgrandsvoisins.com" ];
      # sslCertificate = "/var/lib/acme/www.lesgrandsvoisins.com/fullchain.pem";
      # sslCertificateKey = "/var/lib/acme/www.lesgrandsvoisins.com/key.pem";
      # sslTrustedCertificate = "/var/lib/acme/www.lesgrandsvoisins.com/fullchain.pem";
      sslCertificateKey = "/etc/ssl/lesgrandsvoisins.com.key";
      sslCertificate = "/etc/ssl/lesgrandsvoisins.com.crt";
      sslTrustedCertificate = "/etc/ssl/lesgrandsvoisins.com.ca-bundle";
      forceSSL = true;
      
      locations."/" = {
        proxyPass = "http://127.0.0.1:8000/";
      };
      locations."/favicon.ico" = { proxyPass = null; };
      locations."/static" = { proxyPass = null; };
      locations."/media" = { proxyPass = null; };
      # locations."/.well-known" = { proxyPass = null; };
    };

    virtualHosts."blog.lesgrandsvoisins.com" = {
      root = "/var/www/ghostio/";
      serverName = "blog.lesgrandsvoisins.com";
      serverAliases = ["blog.resdigita.com"];
      sslCertificate = "/var/lib/acme/blog.lesgrandsvoisins.com/fullchain.pem";
      sslCertificateKey = "/var/lib/acme/blog.lesgrandsvoisins.com/key.pem";
      sslTrustedCertificate = "/var/lib/acme/blog.lesgrandsvoisins.com/fullchain.pem";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:2368/";
      };
    };

    virtualHosts."dav.lesgrandsvoisins.com" = {
      serverName = "dav.lesgrandsvoisins.com";
      sslCertificate = "/var/lib/acme/dav.lesgrandsvoisins.com/fullchain.pem";
      sslCertificateKey = "/var/lib/acme/dav.lesgrandsvoisins.com/key.pem";
      sslTrustedCertificate = "/var/lib/acme/dav.lesgrandsvoisins.com/fullchain.pem";
      forceSSL = true;
      locations."/" = {
        proxyPass = "https://dav.lesgrandsvoisins.com";
      };
    };

    virtualHosts."mail.lesgrandsvoisins.com" = {
      serverName = "mail.lesgrandsvoisins.com";
      sslCertificate = "/var/lib/acme/mail.lesgrandsvoisins.com/fullchain.pem";
      sslCertificateKey = "/var/lib/acme/mail.lesgrandsvoisins.com/key.pem";
      sslTrustedCertificate = "/var/lib/acme/mail.lesgrandsvoisins.com/fullchain.pem";
      forceSSL = true;
      locations."/" = {
        proxyPass = "https://mail.lesgrandsvoisins.com";
      };
    };

    virtualHosts."secret.lesgrandsvoisins.com" = {
      serverName = "secret.lesgrandsvoisins.com";
      sslCertificate = "/var/lib/acme/secret.lesgrandsvoisins.com/fullchain.pem";
      sslCertificateKey = "/var/lib/acme/secret.lesgrandsvoisins.com/key.pem";
      sslTrustedCertificate = "/var/lib/acme/secret.lesgrandsvoisins.com/fullchain.pem";
      forceSSL = true;
      locations."/" = {
        proxyPass = "https://secret.lesgrandsvoisins.com";
      };
    };

    virtualHosts."hetzner005.lesgrandsvoisins.com" = {
      # addSSL = true;
      serverName = "hetzner005.lesgrandsvoisins.com";
      sslCertificate = "/var/lib/acme/hetzner005.lesgrandsvoisins.com/fullchain.pem";
      sslCertificateKey = "/var/lib/acme/hetzner005.lesgrandsvoisins.com/key.pem";
      sslTrustedCertificate = "/var/lib/acme/hetzner005.lesgrandsvoisins.com/fullchain.pem";
      # listenAddresses = [ "0.0.0.0" "116.202.236.241" "[::]" "[::1]"];
      forceSSL = true;
      # listen = [{addr="0.0.0.0";port = 8443; ssl=true;} {addr="[::]";port = 8443; ssl=true;}{addr="116.202.236.241";port = 8443; ssl=true;} {addr="[::1]";port = 8443; ssl=true;}];
      locations."/" = {
        proxyPass = "https://hetzner005.lesgrandsvoisins.com";
      #   extraConfig = ''
      #     # proxy_redirect off;
      #     proxy_set_header Host $host:$server_port;
      #     # proxy_set_header Host $http_host;
      #     proxy_set_header X-Real-IP $remote_addr;
      #     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      #     proxy_pass_request_headers      on;
      #     # proxy_redirect default;
      #     # proxy_redirect ~^(https?://[^:]+):\d+(?<relpath>/.+)$ https://www.lesgrandsvoisins.com$relpath;

      #   '';
      };
    };
    recommendedProxySettings = true;

    virtualHosts."auth.lesgrandsvoisins.com" = {
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
      #enableACME = true; 
      sslCertificate = "/var/lib/acme/wagtail.resdigita.com/fullchain.pem";
      sslCertificateKey = "/var/lib/acme/wagtail.resdigita.com/key.pem";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://10.245.101.15:8080";
        extraConfig = ''
          proxy_set_header Host $host:$server_port;
        '';
      };
      locations."/favicon.ico" = { proxyPass = null; };
      locations."/static" = { proxyPass = null; };
      locations."/media" = { proxyPass = null; };
    };


  };

  

}