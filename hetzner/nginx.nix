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
    # defaultListen = [
    #     {addr = "[2a01:4f8:241:4faa::100]"; port=443; ssl=true;}
    #     {addr = "[::]"; port=8443; ssl=true;}
    #     {addr = "0.0.0.0"; port=8888; ssl=false;}
    #   ];
    # extraConfig = ''
    # proxy_headers_hash_max_size 4096;
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
      sslCertificate = "/var/lib/acme/hdoc.lesgrandsvoisins.com/fullchain.pem";
      sslCertificateKey = "/var/lib/acme/hdoc.lesgrandsvoisins.com/key.pem";
    };

    virtualHosts."www.lesgrandsvoisins.com" = {
      #enableACME = true; 
      sslCertificate = "/var/lib/acme/www.lesgrandsvoisins.com/fullchain.pem";
      sslCertificateKey = "/var/lib/acme/www.lesgrandsvoisins.com/key.pem";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://10.245.101.15:8080";
        # extraConfig = ''
        #   proxy_set_header Host $host:$server_port;
        # '';
      };
    };

    virtualHosts."wagtail.resdigita.com" = {
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
    };

    virtualHosts."odoo4.resdigita.com" = {
      #enableACME = true; 
      sslCertificate = "/var/lib/acme/odoo4.resdigita.com/fullchain.pem";
      sslCertificateKey = "/var/lib/acme/odoo4.resdigita.com/key.pem";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://10.245.101.173:8069";
        extraConfig = ''
          proxy_set_header Host $host:$server_port;
        '';
      };
    };
        

    virtualHosts."odoo3.resdigita.com" = {
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
      locations."/favicon.ico" = {
        proxyPass = null;
      };
      locations."/static" = {
        proxyPass = null;
      };
      locations."/media" = {
        proxyPass = null;
      };
      locations."/.well-known" = {
        proxyPass = null;
      };
    };

    # virtualHosts."www.lesgrandsvoisins.com" = {
    #   serverName = "www.lesgrandsvoisins.com";
    #   sslCertificate = "/var/lib/acme/www.lesgrandsvoisins.com/fullchain.pem";
    #   sslCertificateKey = "/var/lib/acme/www.lesgrandsvoisins.com/key.pem";
    #   sslTrustedCertificate = "/var/lib/acme/www.lesgrandsvoisins.com/fullchain.pem";
    #   forceSSL = true;
    #   locations."/" = {
    #     proxyPass = "https://www.lesgrandsvoisins.com";
    #   };
    # };

    virtualHosts."blog.lesgrandsvoisins.com" = {
      serverName = "blog.lesgrandsvoisins.com";
      sslCertificate = "/var/lib/acme/blog.lesgrandsvoisins.com/fullchain.pem";
      sslCertificateKey = "/var/lib/acme/blog.lesgrandsvoisins.com/key.pem";
      sslTrustedCertificate = "/var/lib/acme/blog.lesgrandsvoisins.com/fullchain.pem";
      forceSSL = true;
      locations."/" = {
        proxyPass = "https://blog.lesgrandsvoisins.com";
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
  };

}