{ config, pkgs, lib, ... }:
let 
nginxLocationWagtailExtraConfig = ''
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_redirect off;
    proxy_http_version 1.1;
    proxy_set_header X-Forwarded-Proto $scheme;
    # proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
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
      root = "/var/www/interetpublic";
     };
    # "www.hopgv.com" = {
    #   enableACME = true;
    #   forceSSL = true;
    #   root = "/var/www/interetpublic";
    #   serverAliases = ["hopgv.com"];
    #   extraConfig = ''
    #     if ($host != "www.hopgv.com") {
    #       return 301 $scheme://www.hopgv.com$request_uri;
    #     }
    #   '';
    # };
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
    "hopgv.org" = {
      serverAliases = [
        "facile.lesgrandsvoisins.com"
        "hopgv.com"
        "www.gvois.com"
        "www.hopgv.org"
        "gvpublic.com"
        "gvpublic.org"
        "gvois.com"
        "gvois.org"
        "www.gvois.org"
        "www.gvpublic.org"
        "www.gvpublic.com"
        "fastoche.org"
        "www.hopgv.com"
        "gv.fastoche.org"
        "gv.village.ong"
        "gv.villagengo.com"
        "gv.villagengo.org"
      ];
      enableACME = true;
      forceSSL = true;
      globalRedirect = "www.gv.coop";
    };
    "gv.village.ngo" = {
      enableACME = true;
      forceSSL = true;
      root =  "/var/www/www-fastoche/";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8893/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      locations."/favicon.ico" = { proxyPass = null; };
      locations."/static" = { proxyPass = null; };
      locations."/medias" = { proxyPass = null; };
      locations."/.well-known" = { proxyPass = null; };
    };
    "www.lesgrandsvoisins.com" = {
      serverAliases = [
        "test.lesgrandsvoisins.com" 
        "alt.lesgrandsvoisins.com"
        "en.lesgrandsvoisins.com"
        "fr.lesgrandsvoisins.com"
        "gvcoop.lesgrandsvoisins.com"
        "old.lesgrandsvoisins.com"
        "excellenxport.hopgv.com"
      ];
        enableACME = true;
        forceSSL = true;
        root =  "/var/www/lesgrandsvoisins/";
        locations."/" = {
          proxyPass = "http://127.0.0.1:8894/";
          extraConfig = nginxLocationWagtailExtraConfig + ''
            rewrite ^/cms-admin/login/?$ https://www.lesgrandsvoisins.com/accounts/oidc/key-lesgrandsvoisins-com/login/?process=cms-admin/login/ redirect;  
          '';
        };
      locations."/favicon.ico" = { proxyPass = null; };
      locations."/static" = { proxyPass = null; };
      locations."/medias" = { proxyPass = null; };
      locations."/.well-known" = { proxyPass = null; };
    };
    "resdigita.village.ngo" = {
      serverAliases = ["resdigita.fastoche.org"];
      enableACME = true;
      forceSSL = true;
      root =  "/var/www/resdigita-fastoche/";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8892/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      locations."/favicon.ico" = { proxyPass = null; };
      locations."/static" = { proxyPass = null; };
      locations."/medias" = { proxyPass = null; };
      locations."/.well-known" = { proxyPass = null; };
    };
    "www.francemali.org" = {
      enableACME = true;
      serverAliases = ["francemali.org"];
      forceSSL = true;
      root =  "/var/www/francemali/";
      extraConfig = ''
        if ($host = 'francemali.org') {
          return 301 $scheme://www.$host$request_uri;
        }
        '';
      locations."/" = {
        proxyPass = "http://127.0.0.1:8888/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      locations."/favicon.ico" = { proxyPass = null; };
      locations."/static" = { proxyPass = null; };
      locations."/medias" = { proxyPass = null; };
      locations."/.well-known" = { proxyPass = null; };
    };
    "www.gv.coop" = {
      enableACME = true;
      serverAliases = [
        "www.lesgv.com"
        ];
      forceSSL = true;
      root =  "/var/www/village/";
      # extraConfig = ''
      #   if ($host != 'www.village.ong') {
      #     return 301 https://www.village.ong/fr/;
      #   }
      # '';
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:8896/";
          extraConfig = nginxLocationWagtailExtraConfig;
        };
        # "/en/".return =  "301 http://www.village.ngo$request_uri";
        "/favicon.ico" = { proxyPass = null; };
        "/static" = { proxyPass = null; };
        "/medias" = { proxyPass = null; };
        "/.well-known" = { proxyPass = null; };
      };
    };
    "www.village.ong" = {
      enableACME = true;
      serverAliases = [
        "village.ong"
        ];
      forceSSL = true;
      root =  "/var/www/village/";
      extraConfig = ''
        if ($host != 'www.village.ong') {
          return 301 https://www.village.ong/fr/;
        }
      '';
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:8896/";
          extraConfig = nginxLocationWagtailExtraConfig;
        };
        "/en/".return =  "301 http://www.village.ngo$request_uri";
        "/favicon.ico" = { proxyPass = null; };
        "/static" = { proxyPass = null; };
        "/medias" = { proxyPass = null; };
        "/.well-known" = { proxyPass = null; };
      };
        # if ($host != 'www.village.ong') {
        #   return 301 $scheme://www.village.ong$request_uri;
        # }
        # location ~ /en/(.*)$ {
        #   rewrite ^ https://www.village.ngo/en/$1?$args permanent;
        # }
        # '';
      # locations."/en/" = {
      #   proxyPass = "http://127.0.0.1:8896/";
      #   extraConfig = nginxLocationWagtailExtraConfig;
      # };
      # locations."/" = {
      #   proxyPass = "http://127.0.0.1:8896/";
      #   extraConfig = nginxLocationWagtailExtraConfig;
      # };
      # locations."/favicon.ico" = { proxyPass = null; };
      # locations."/static" = { proxyPass = null; };
      # locations."/medias" = { proxyPass = null; };
      # locations."/.well-known" = { proxyPass = null; };
    };
    "cantine.resdigita.com" = {
      enableACME = true;
      forceSSL = true;
      root =  "/var/www/cantine/";
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:8900/";
          extraConfig = nginxLocationWagtailExtraConfig;
        };
        # "/fr/".return =  "301 http://www.village.ong$request_uri";
        "/favicon.ico" = { proxyPass = null; };
        "/static" = { proxyPass = null; };
        "/medias" = { proxyPass = null; };
        "/.well-known" = { proxyPass = null; };
      };
    };

    "www.village.ngo" = {
      enableACME = true;
      serverAliases = [
        "www.villagengo.org"
        "www.villagengo.com"
        "village.ngo"
        "villagengo.org"
        "villagengo.com"
        "villageparis.org"
        "www.villageparis.org"
        "ngovillage.org"
        "www.ngovillage.org"
        "ngvillage.org"
        "www.ngvillage.org" 
        "www.ongovillage.com"
        "ongovillage.com"
        "www.ongovillage.org"
        "ongovillage.org"
        "www.ongvillage.org"
        "ongvillage.org"
        "www.ongvillage.com"
        "ongvillage.com"
      ];
      forceSSL = true;
      root =  "/var/www/village/";
      extraConfig = ''
        # location ~ /fr/(.*)$ {
        #   rewrite ^ https://www.village.ong/fr/$1?$args permanent;
        # }
        if ($host != 'www.village.ngo') {
          return 301 $scheme://www.village.ngo$request_uri;
        }
        '';
        #         location ~ /fr/(.*)$ {
        #   rewrite ^ https://www.village.ong/fr/$1?$args permanent;
        # }
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:8896/";
          extraConfig = nginxLocationWagtailExtraConfig;
        };
        "/fr/".return =  "301 http://www.village.ong$request_uri";
        "/favicon.ico" = { proxyPass = null; };
        "/static" = { proxyPass = null; };
        "/medias" = { proxyPass = null; };
        "/.well-known" = { proxyPass = null; };
      };
    };
    # "www.village.ong" = {
    #   enableACME = true;
    #   serverAliases = [
    #     "www.fastoche.org"
    #     "fastoche.org"
    #     "village.ong"
    #     ];
    #   forceSSL = true;
    #   root =  "/var/www/village/";
    #   extraConfig = ''
    #     if ($host != 'www.village.ong') {
    #       return 301 $scheme://www.village.ong$request_uri;
    #     }
    #     '';
    #   locations."/" = {
    #     proxyPass = "http://127.0.0.1:8896/";
    #     extraConfig = nginxLocationWagtailExtraConfig;
    #   };
    #   locations."/favicon.ico" = { proxyPass = null; };
    #   locations."/static" = { proxyPass = null; };
    #   locations."/medias" = { proxyPass = null; };
    #   locations."/.well-known" = { proxyPass = null; };
    # };
    "web.cfran.org" = {
      enableACME = true;
      serverAliases = ["cfran.org" "www.cfran.org" "web.fastoche.org"];
      forceSSL = true;
      root =  "/var/www/web-fastoche/";
      extraConfig = ''
        if ($host != 'web.cfran.org') {
          return 301 $scheme://web.cfran.org$request_uri;
        }
        '';
      locations."/" = {
        proxyPass = "http://127.0.0.1:8889/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      locations."/favicon.ico" = { proxyPass = null; };
      locations."/static" = { proxyPass = null; };
      locations."/medias" = { proxyPass = null; };
      locations."/.well-known" = { proxyPass = null; };
    };
    "wagtail.village.ngo" = {
      enableACME = true;
      forceSSL = true;
      serverAliases = [ "wagtail.villagengo.org" "wagtail.villagengo.com"];
      root =  "/var/www/wagtail-village/";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8897/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      # extraConfig = ''
      #   if ($host != 'wagtail.village.ngo') {
      #     return 301 $scheme://wagtail.cfran.org$request_uri;
      #   }
      # '';
      locations."/favicon.ico" = { proxyPass = null; };
      locations."/static" = { proxyPass = null; };
      locations."/medias" = { proxyPass = null; };
      locations."/.well-known" = { proxyPass = null; };
    };
    "www.resdigita.org" = {
      enableACME = true;
      forceSSL = true;
      serverAliases = [ "resdigita.org" "en.resdigita.com" "fr.resdigita.com" "en.resdigita.org" "fr.resdigita.org" "www.resdigita.com" "resdigita.com"];
      root =  "/var/www/resdigitaorg/";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8899/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      extraConfig = ''
        if ($host != 'www.resdigita.org') {
          return 301 $scheme://www.resdigita.org$request_uri;
        }
      '';
      locations."/favicon.ico" = { proxyPass = null; };
      locations."/static" = { proxyPass = null; };
      locations."/medias" = { proxyPass = null; };
      locations."/.well-known" = { proxyPass = null; };
    };
    "wagtail.village.ong" = {
      serverAliases = [ "wagtail.fastoche.org" "wagtail.cfran.org"];
      enableACME = true;
      forceSSL = true;
      root =  "/var/www/wagtail-village/";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8897/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      extraConfig = ''
        if ($host != 'wagtail.village.ong') {
          return 301 $scheme://wagtail.cfran.org$request_uri;
        }
      '';
      locations."/favicon.ico" = { proxyPass = null; };
      locations."/static" = { proxyPass = null; };
      locations."/medias" = { proxyPass = null; };
      locations."/.well-known" = { proxyPass = null; };
    };
    "django.village.ngo" = {
      enableACME = true;
      serverAliases = [ "django.fastoche.org" "django.cfran.org" "django.village.ong" "django.villagengo.com" "django.villagengo.org"];
      # extraConfig = ''
      #   if ($host != 'django.cfran.org') {
      #     return 301 $scheme://django.cfran.org$request_uri;
      #   }
      # '';
      forceSSL = true;
      root =  "/var/www/django-village/";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8891/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      locations."/favicon.ico" = { proxyPass = null; };
      locations."/static" = { proxyPass = null; };
      locations."/media" = { proxyPass = null; };
      locations."/.well-known" = { proxyPass = null; };
    };
    "fabrique.village.ngo" = {
      enableACME = true;
      forceSSL = true;
      serverAliases = [ "designsystem.fastoche.org" "designsystem.village.ngo" "designsystem.cfran.org" "designsystem.village.ong" "designsystem.villagengo.com" "designsystem.villagengo.org"];
      # extraConfig = ''
      #   if ($host != 'designsystem.cfran.org') {
      #     return 301 $scheme://designsystem.cfran.org$request_uri;
      #   }
      # '';
      root =  "/var/www/designsystem-village/";
      # locations."/" = {
      #   proxyPass = "http://127.0.0.1:8891/";
      #   extraConfig = nginxLocationWagtailExtraConfig;
      # };
      # locations."/favicon.ico" = { proxyPass = null; };
      # locations."/static" = { proxyPass = null; };
      # locations."/example" = { proxyPass = null; };
      # locations."/medias" = { proxyPass = null; };
      # locations."/.well-known" = { proxyPass = null; };
    };
    "meet.resdigita.com" = {
      serverAliases = ["meet.lesgv.org" "meet.village.ngo" "meet.village.ong" "meet.villagengo.com" "meet.villagengo.org"];
      enableACME = true;
      forceSSL = true;
      root =  "/var/www/wagtail/";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8008/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      locations."/favicon.ico" = { proxyPass = null; };
      locations."/static" = { proxyPass = null; };
      locations."/media" = { proxyPass = null; };
      locations."/.well-known" = { proxyPass = null; };
    };
    "8895.lesgrandsvoisins.com" = {
      enableACME = true;
      forceSSL = true;
      root =  "/var/www/villagengo/";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8895/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      locations."/favicon.ico" = { proxyPass = null; };
      locations."/static" = { proxyPass = null; };
      locations."/media" = { proxyPass = null; };
      locations."/.well-known" = { proxyPass = null; };
    };
    "meet.desgv.com"  = {
      enableACME = true;
      forceSSL = true;
      globalRedirect = "meet.resdigita.com";
    };
    "gvoisin.resdigita.com" = {
      serverAliases = [
        "meet.lesgrandsvoisins.com"
        "discourse.resdigita.com"
        "meet.village.ngo"
        "meet.village.ong"
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
        proxyPass = "http://127.0.0.1:8008/";
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
        # "www.gv.coop"  
        # "wagtail.gv.coop"
        "wagtail.lesgv.org"
      ];
      enableACME = true;
       forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8008/";
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
        # "discoursewww.lesgv.com" 
        "discourse.lesgv.com" 
        "discourse.resdigita.com" 
        "lesgvcom.resdigita.com"
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

    "lesgv.lesgrandsvoisins.com" = {
      serverAliases = ["2022.lesgrandsvoisins.com"];
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8008/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      locations."/favicon.ico" = { proxyPass = null; };
      locations."/static" = { proxyPass = null; };
      locations."/media" = { proxyPass = null; };
      root = "/var/www/wagtail";
    };

    "www.lesgrandsvoisins.fr" = {
     serverAliases = ["desgv.com" 
      "francemali.lesgrandsvoisins.com" "shitmuststop.com" "www.shitmuststop.com" "www.desgv.com" "lesgrandsvoisins.fr" 
      # "www.lesgv.com" 
      "lesgv.com" "www.lesgv.org" "lesgv.org" "www.gv.coop" "gv.coop" "www.coopgv.com" "coopgv.com" "www.coopgv.org" "coopgv.org" 
      "ghost.resdigita.com" "listmonk.resdigita.com" "lesgv.org" ];
      enableACME = true;
      # sslCertificate = "/var/lib/acme/www.lesgrandsvoisins.fr/fullchain.pem";
      # sslCertificateKey = "/var/lib/acme/www.lesgrandsvoisins.fr/key.pem";
      # sslTrustedCertificate = "/var/lib/acme/www.lesgrandsvoisins.fr/fullchain.pem";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8008/";
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
      # if ($host = 'www.lesgv.com') {
      #     return 301 $scheme://les.gv.coop$request_uri;
      # }
      if ($host = 'gv.coop') {
          return 301 $scheme://les.gv.coop$request_uri;
      }
      # if ($host = 'www.gv.coop') {
      #     return 301 $scheme://les.gv.coop$request_uri;
      # }
      if ($host = 'lesgrandsvoisins.fr') {
          return 301 $scheme://www.lesgrandsvoisins.com;
          # return 301 $scheme://www.lesgrandsvoisins.com$request_uri;
      }
      if ($host = 'www.lesgrandsvoisins.fr') {
          return 301 $scheme://www.lesgrandsvoisins.com;
          # return 301 $scheme://www.lesgrandsvoisins.com$request_uri;
      }
      '';
    };
    # "www.desgrandsvoisins.org" = {
    #   serverAliases = ["desgrandsvoisins.org"  "desgrandsvoisins.com" "www.desgrandsvoisins.com"];
    #   globalRedirect = "www.lesgrandsvoisins.com";
    #    enableACME = true;
    #    forceSSL = true;
    # };
    "l-g-v.com" = {
      serverAliases = [
        "www.l-g-v.com"
        "l-g-v.org"
        "www.l-g-v.org"
      ];      
      # sslCertificateKey = "/etc/ssl/lesgrandsvoisins.com.key";
      # sslCertificate = "/etc/ssl/lesgrandsvoisins.com.crt";
      # sslTrustedCertificate = "/etc/ssl/lesgrandsvoisins.com.ca-bundle";
      enableACME = true;
      forceSSL = true;
      globalRedirect = "www.lesgrandsvoisins.com";
    };  
    "lesgrandsvoisins.com" = {   
      # sslCertificateKey = "/etc/ssl/lesgrandsvoisins.com.key";
      # sslCertificate = "/etc/ssl/lesgrandsvoisins.com.crt";
      # sslTrustedCertificate = "/etc/ssl/lesgrandsvoisins.com.ca-bundle";
      enableACME = true;
      forceSSL = true;
      globalRedirect = "www.lesgrandsvoisins.com";
    };   
    "old.lesgrandsvoisins.com" = {      
      # serverAliases = ["lesgrandsvoisins.com"];
      # sslCertificateKey = "/etc/ssl/lesgrandsvoisins.com.key";
      # sslCertificate = "/etc/ssl/lesgrandsvoisins.com.crt";
      # sslTrustedCertificate = "/etc/ssl/lesgrandsvoisins.com.ca-bundle";
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8008/";
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
        proxyPass = "http://127.0.0.1:8008/";
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
        proxyPass = "http://127.0.0.1:8008/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      root = "/var/www/wagtail";
      locations."/favicon.ico" = { proxyPass = null; };
      locations."/static" = { proxyPass = null; };
      locations."/media" = { proxyPass = null; };
      locations."/.well-known" = { proxyPass = null; };
    };
    "paris14.village.ngo" = {
      enableACME = true;
      forceSSL = true;
      root =  "/var/www/village/";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8896/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      # extraConfig = ''
      #   if ($host != 'wagtail.village.ngo') {
      #     return 301 $scheme://wagtail.cfran.org$request_uri;
      #   }
      # '';
      locations."/favicon.ico" = { proxyPass = null; };
      locations."/static" = { proxyPass = null; };
      locations."/medias" = { proxyPass = null; };
      locations."/.well-known" = { proxyPass = null; };
    };
    "8008.lesgrandsvoisins.com" = {
      enableACME=true;
       forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8008/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      root = "/var/www/wagtail";
      locations."/favicon.ico" = { proxyPass = null; };
      locations."/static" = { proxyPass = null; };
      locations."/media" = { proxyPass = null; };
      locations."/.well-known" = { proxyPass = null; };
    };
    "8893.lesgrandsvoisins.com" = {
      root = "/var/www/www-fastoche/";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8893/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      enableACME=true;
      forceSSL = true;
      locations."/favicon.ico" = { proxyPass = null; };
      locations."/static" = { proxyPass = null; };
      locations."/media" = { proxyPass = null; };
      locations."/.well-known" = { proxyPass = null; };
    };
    "8892.lesgrandsvoisins.com" = {
      root = "/var/www/resdigita-fastoche/";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8892/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      enableACME=true;
      forceSSL = true;
      locations."/favicon.ico" = { proxyPass = null; };
      locations."/static" = { proxyPass = null; };
      locations."/media" = { proxyPass = null; };
      locations."/.well-known" = { proxyPass = null; };
    };
    "8890.lesgrandsvoisins.com" = {
      root = "/var/www/wagtail-fastoche/";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8890/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      enableACME=true;
      forceSSL = true;
      locations."/favicon.ico" = { proxyPass = null; };
      locations."/static" = { proxyPass = null; };
      locations."/media" = { proxyPass = null; };
      locations."/.well-known" = { proxyPass = null; };
    };
    "8894.lesgrandsvoisins.com" = {
      root = "/var/www/lesgrandsvoisins/";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8894/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      enableACME=true;
      forceSSL = true;
      locations."/favicon.ico" = { proxyPass = null; };
      locations."/static" = { proxyPass = null; };
      locations."/media" = { proxyPass = null; };
      locations."/.well-known" = { proxyPass = null; };
    };
    "8888.lesgrandsvoisins.com" = {
      root = "/var/www/francemali/";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8888/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      enableACME=true;
      forceSSL = true;
      locations."/favicon.ico" = { proxyPass = null; };
      locations."/static" = { proxyPass = null; };
      locations."/media" = { proxyPass = null; };
      locations."/.well-known" = { proxyPass = null; };
    };
    "8896.lesgrandsvoisins.com" = {
      root = "/var/www/village/";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8896/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      enableACME=true;
      forceSSL = true;
      locations."/favicon.ico" = { proxyPass = null; };
      locations."/static" = { proxyPass = null; };
      locations."/media" = { proxyPass = null; };
      locations."/.well-known" = { proxyPass = null; };
    };
    "8900.lesgrandsvoisins.com" = {
      root = "/var/www/cantine/";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8900/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      enableACME=true;
      forceSSL = true;
      locations."/favicon.ico" = { proxyPass = null; };
      locations."/static" = { proxyPass = null; };
      locations."/media" = { proxyPass = null; };
      locations."/.well-known" = { proxyPass = null; };
    };
    "8889.lesgrandsvoisins.com" = {
      root = "/var/www/cfran/";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8889/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      enableACME=true;
      forceSSL = true;
      locations."/favicon.ico" = { proxyPass = null; };
      locations."/static" = { proxyPass = null; };
      locations."/media" = { proxyPass = null; };
      locations."/.well-known" = { proxyPass = null; };
    };
    "8897.lesgrandsvoisins.com" = {
      root = "/var/www/resdigita-fastoche/";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8897/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      enableACME=true;
      forceSSL = true;
      locations."/favicon.ico" = { proxyPass = null; };
      locations."/static" = { proxyPass = null; };
      locations."/media" = { proxyPass = null; };
      locations."/.well-known" = { proxyPass = null; };
    };
    "8899.lesgrandsvoisins.com" = {
      root = "/var/www/resdigitaorg/";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8899/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      enableACME=true;
      forceSSL = true;
      locations."/favicon.ico" = { proxyPass = null; };
      locations."/static" = { proxyPass = null; };
      locations."/media" = { proxyPass = null; };
      locations."/.well-known" = { proxyPass = null; };
    };
    "8891.lesgrandsvoisins.com" = {
      root = "/var/www/django-village/";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8891/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      enableACME=true;
      forceSSL = true;
      locations."/favicon.ico" = { proxyPass = null; };
      locations."/static" = { proxyPass = null; };
      locations."/media" = { proxyPass = null; };
      locations."/.well-known" = { proxyPass = null; };
    };
  };
}
