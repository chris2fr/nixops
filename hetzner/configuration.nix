# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, lib, ... }:
let
  mannchriRsaPublic = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/mailserver/vars/cert-public.nix));
  keycloakVikunja  = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.keycloak.vikunja));
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz";
in
{
  nix.settings.experimental-features = "nix-command flakes";
  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 113272;
    "fs.inotify.max_user_instances" = 256;
    "fs.inotify.max_queued_events" = 32768;
  };
  imports =
    [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./httpd.nix
    ./mailserver.nix
    ./guichet.nix
    ./postgresql.nix
    # ./users.nix
    ./wagtail.nix
    ./common.nix # Des configurations communes pratiques
    ./servers.nix # I am migrating other services here
    ./containers.nix
    ./nginx.nix
    (import "${home-manager}/nixos")
    ];
  #  environment.systemPackages = with pkgs; [
  #   gcc 
  #   pkg-config
  #   openssl
  #  ];
  # Use the systemd-boot EFI boot loader.
  environment.systemPackages = with pkgs; [
    yarn
    filebrowser
    cacert
  ];
  users.users = {
    filebrowser = {
      isNormalUser = true;
      extraGroups = ["wwwrun"];
    };
    haproxy = {
      extraGroups = ["wwwrun" "acme"];
    };
  };
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  # Networking
  networking = {
    hostName = "hetzner005"; # Define your hostname.
    # hostName = "mail.lesgrandsvoisins.com"; # Define your hostname
    # networkmanager.enable = true;  # Easiest to use and most distros use this by default.
    # useDHCP = true;
    enableIPv6 = true;
    interfaces.eno1.ipv6.addresses = [
      {
        address = "2a01:4f8:241:4faa::";
        prefixLength = 96;
      }
    ];
    defaultGateway6 = {
      address = "fe80::1";
      interface = "eno1";
    };
    # firewall.enable = false;
    firewall.trustedInterfaces = [ "docker0" "lxdbr1" "lxdbr0" ];
    firewall.allowedTCPPorts = [ 22 25 80 443 143 587 993 995 636 8443 9080 9443 10080 10443 ];
    # interfaces."eno1".ipv6 = {

    # }
  };
  # Set your time zone.
  time.timeZone = "Europe/Paris";
  # Select internationalisation properties.
  i18n.defaultLocale = "fr_FR.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = {
    mannchri = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [ mannchriRsaPublic ];
      extraGroups = [ "wheel" ];
    };
    crabfit = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [ mannchriRsaPublic ];
      extraGroups = [ "docker" ];
    };
    fossil = {
        isNormalUser = true;
        openssh.authorizedKeys.keys = [ mannchriRsaPublic ];
    };
  };
  # home-manager.users.crabfit = {
  #   home.packages = with pkgs; [ 
  #     yarn
  #   ];
  #   home.stateVersion = "23.11";
  #   programs.home-manager.enable = true;
  # };
  home-manager.users = {
    fossil = {pkgs, ...}: {
      home.packages = with pkgs; [ 
        fossil
      ];
      home.stateVersion = "23.11";
      programs.home-manager.enable = true;
    };
    guichet = {pkgs, ...}: {
      home.packages = with pkgs; [ 
        go
        gnumake
        python311
      ];
      home.stateVersion = "23.11";
      programs.home-manager.enable = true;
    };
    filebrowser = {pkgs, ...}: {
      home.packages = with pkgs; [ 
        filebrowser
      ];
      home.stateVersion = "23.11";
      programs.home-manager.enable = true;
    };
    mannchri = {pkgs, ...}: {
      home.packages = [ pkgs.atool pkgs.httpie ];
      home.stateVersion = "23.11";
      programs.home-manager.enable = true;
      programs.vim = {
        enable = true;
        plugins = with pkgs.vimPlugins; [ vim-airline ];
        settings = { ignorecase = true; tabstop = 2; };
        extraConfig = ''
          set mouse=a
          set nocompatible
          colo torte
          syntax on
          set tabstop     =2
          set softtabstop =2
          set shiftwidth  =2
          set expandtab
          set autoindent
          set smartindent
        '';
      };
    };
  };
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;
  systemd.services = {
    "filebrowser@" = {
      enable = true;
      wantedBy = ["default.target"];
      scriptArgs = "filebrowser %i";
      # preStart = "mkdir -p /opt/filebrowser/dbs/%u/%i; touch /opt/filebrowser/dbs/%u/%i/temoin.txt";
      script = "/opt/filebrowser/dbs/filebrowser.sh $filebrowser_user $filebrowser_database";
      description = "File Browser, un interface web à un système de fichiers pour %u on %i";
      environment = {
        filebrowser_user = "filebrowser";
        filebrowser_database = "%i";
        FB_BASEURL="";
      };
      serviceConfig = {
        WorkingDirectory = "/var/www/dav/data/%i";
        User = "filebrowser";
        Group = "wwwrun";
        UMask = "0002";
      };
    };
    crabfitfront = {
      enable = true;
      wantedBy = ["default.target"];
      script = "${pkgs.yarn}/bin/yarn run start -p 3080";
      description = "Crab.fit front-end NextJS";
      serviceConfig = {
        WorkingDirectory = "/home/crabfit/crab.fit/frontend/";
        User = "crabfit";
        Group = "users";
      };
    };
    crabfitback = {
      enable = true;
      wantedBy = ["default.target"];
      script = "/home/crabfit/crab.fit/api/launch-crabfit-api.sh";
      description = "Crab.fit back in Rust avec Postgres";
      serviceConfig = {
        WorkingDirectory = "/home/crabfit/crab.fit/api/target/release/";
        User = "crabfit";
        Group = "users";
      };
    };
    # haproxy-config = {
    #   enable = true;
    #   description = "HA Proxy Service";
    #   documentation = "https://www.resdigita.com";
    #   wantedBy = [ "multi-user.target" ];
    #   requires = [ "network-online.target" ];
    #   after = [ "network-online.target" "nginx.service"  "httpd.service" ];
    #   path = [
    #     pkgs.coreutils
    #     pkgs.cacert
    #   ];
    # };
  };
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
  environment.sessionVariables = rec {
    EDITOR="vim";
    WAGTAIL_ENV = "production";
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "contact@lesgrandsvoisins.com";
    defaults.webroot = "/var/www";
  };
  services= {
    vikunja = {
      enable = true;
      frontendScheme = "https";
      frontendHostname = "vikunja.resdigita.com";
      settings = {
        # openid = {
        openid.enabled = true;
        openid.redirecturl = "https://vikunja.resdigita.com/auth/openid/";
        openid.providers = [{
            name = "ResDigita";
            authurl = "https://keycloak.resdigita.com:10443/realms/master";
            logouturl = "https://keycloak.resdigita.com:10443/realms/master/protocol/openid-connect/logout";
            clientid = "vikunja";
            clientsecret = keycloakVikunja;
          }];
        # };
      };
    };

    homepage-dashboard = {
      enable = true;
      listenPort = 8882;
      openFirewall = true;
    };
    openssh = {
      enable = true;
      settings.PermitRootLogin = "prohibit-password";
    };
    keycloak = {
      enable = true;
      settings = {
        https-port = 10443;
        http-port = 10080;
        # proxy = "passthrough";
        proxy = "reencrypt";
        hostname = "keycloak.resdigita.com";
      };
      sslCertificate = "/var/lib/acme/keycloak.resdigita.com/fullchain.pem";
      sslCertificateKey = "/var/lib/acme/keycloak.resdigita.com/key.pem";
      database.passwordFile = "/etc/nixos/.secret.keycloakdata";
      # themes = {lesgv = (pkgs.callPackage "/etc/nixos/keycloaktheme/derivation.nix" {});};
    };
    haproxy = {
      enable = true;
      config = ''
        global
          daemon
          maxconn 1000

        defaults
          log     global
          mode    http
          option  httplog
          option  dontlognull
          option  forwardfor
          timeout connect 10s
          timeout client  60s
          timeout server  60s
          errorfile 400 /var/log/haproxy/errors/400.http
          errorfile 403 /var/log/haproxy/errors/403.http
          errorfile 408 /var/log/haproxy/errors/408.http
          errorfile 500 /var/log/haproxy/errors/500.http
          errorfile 502 /var/log/haproxy/errors/502.http
          errorfile 503 /var/log/haproxy/errors/503.http
          errorfile 504 /var/log/haproxy/errors/504.http

        listen http-in
          bind :9080
          default_backend homepage-dashboard.resdigita.com:9443

        listen https-in
          mode http
          bind :9443 ssl crt-list /var/lib/acme/crt-list.txt
          option forwardfor
          # redirect scheme https 
          http-request set-header X-Forwarded-Proto https if { ssl_fc }
          http-request set-header X-Forwarded-Proto http if !{ ssl_fc }
          http-request redirect scheme https unless { ssl_fc }
          acl ACL_resdigita.com hdr(host) -i resdigita.com:9443
          http-request redirect location https://quartz.resdigita.com:9443 if ACL_resdigita.com
          use_backend %[req.hdr(Host),lower]
          default_backend homepage-dashboard.resdigita.com:9443
          # default_backend mail.lesgrandsvoisins.com
          
          # # acl nothttps scheme_str http
          # # redirect location https://homepage-dashboard.resdigita.com unless secure
          # # redirect location https://%[env(HOSTNAME)]:9443 if scheme str "http"
          # # acl sslv req.ssl_ver gt 2
          # # redirect scheme https if !sslv 
          # # redirect scheme https if !{ req.ssl_hello_type gt 0 }
          # # use_backend homepage-dashboard if server_ssl
          # option             forwardfor
          # acl ACL_nginx hdr(host) -i www.lesgrandsvoisins.com lesgrandsvoisins.com quartz.resdigita.com hedgedoc.resdigita.com crabfit.resdigita.com
          # acl ACL_httpd hdr(host) -i dav.resdigita.com keepass.resdigita.com keeweb.resdigita.com

          # use_backend nginx if ACL_nginx
          # use_backend httpd if ACL_httpd

          # # use_backend wagtail if ACL_www.lesgrandsvoisins.com
          # # acl ACL_quartz.resdigita.com hdr(host) -i quartz.resdigita.com
          # # use_backend quartz.resdigita.com if ACL_quartz.resdigita.com
          # # acl ACL_hedgedoc.resdigita.com hdr(host) -i hedgedoc.resdigita.com
          # # use_backend hedgedoc.resdigita.com if ACL_hedgedoc.resdigita.com
          # # acl ACL_crabfit.resdigita.com hdr(host) -i crabfit.resdigita.com
          # # use_backend crabfit.resdigita.com if ACL_crabfit.resdigita.com

          # default_backend https-homepage-dashboard

        # frontend wagtail
        #   bind www.lesgrandsvoisins.com:9443 ssl crt /var/lib/acme/www.lesgrandsvoisins.com/full.pem
        #   bind lesgrandsvoisins.com:9443 ssl crt /var/lib/acme/www.lesgrandsvoisins.com/full.pem
        #   http-request redirect scheme https unless { ssl_fc }
        #   default_backend wagtail

        backend hedgedoc.resdigita.com:9443
          server server1 127.0.0.1:3333 maxconn 64

        backend crabfit.resdigita.com:9443
          server server1 127.0.0.1:3080 maxconn 64

        backend authentik.resdigita.com:9443
          option forwardfor
          server server1 10.245.101.35:9000 maxconn 64

        # Still in debug mode. Put in cache mode please.
        backend homepage-dashboard.resdigita.com:9443
          server server1 127.0.0.1:8882 maxconn 64

        backend https-homepage-dashboard:9443
          server server1 homepage-dashboard.resdigita.com:443 maxconn 64

        backend nginx
          server server1 127.0.0.1:443 maxconn 64

        backend httpd
          server server1 127.0.0.1:8443 maxconn 64

        backend mail.lesgrandsvoisins.com:9443
          option forwardfor
          server server1 /run/phpfpm/roundcube.sock
         
        backend blog.lesgrandsvoisins.com:9443
          option forwardfor
          server server1 127.0.0.1:2368

        backend keepass.resdigita.com:9443
          server server1 keepass.resdigita.com:8443

        backend odoo1.resdigita.com:9443
          server server1 10.245.101.158:8069
        
        backend odoo2.resdigita.com:9443
          server server1 10.245.101.82:8069

        backend odoo3.resdigita.com:9443
          server server1 10.245.101.128:8069

        backend odoo4.resdigita.com:9443
          server server1 10.245.101.173:8069
        
        backend quartz.resdigita.com:9443
          server server1 quartz.resdigita.com:443

        backend guichet.resdigita.com:9443
          server server1 [::1]:9991

        backend dav.resdigita.com:9443
          server server1 127.0.0.1:8443

        backend wagtail.resdigita.com:9443
          server server1 wagtail.resdigita.com:8443

        backend keeweb.resdigita.com:9443
          server server1 keeweb.resdigita.com:8443

        backend filebrowser.resdigita.com:9443
          server server1 filebrowser.resdigita.com:8443

        backend chris.resdigita.com:9443
          server server1 chris.resdigita.com:8443

        backend axel.resdigita.com:9443
          server server1 axel.resdigita.com:8443

        backend maruftuyel.resdigita.com:9443
          server server1 maruftuyel.resdigita.com:8443

        backend mail.resdigita.com:9443
          server server1 /run/phpfpm/roundcube.sock

        resolvers dnsresolve
          parse-resolv-conf
          # nameserver googledns1ipv6 [2001:4860:4860::8888]:53
          # nameserver googledns2ipv6 [2001:4860:4860::8844]:53
          # nameserver googledns1ipv4 8.8.8.8:53
          # nameserver googledns2ipv4 8.8.4.4:53

      '';
    };
  };
  # services.authelia.instances = {
  #   main = {
  #     enable = true;
  #     secrets.storageEncryptionKeyFile = "/etc/authelia/storage.key ";
  #     secrets.jwtSecretFile = "/etc/authelia/jwt.key";
  #     settings = {
  #       theme = "light";
  #       default_2fa_method = "totp";
  #       log.level = "debug";
  #       server.disable_healthcheck = true;
  #     };
  #   };
    # preprod = {
    #   enable = false;
    #   secrets.storageEncryptionKeyFile = "/mnt/pre-prod/authelia/storageEncryptionKeyFile";
    #   secrets.jwtSecretFile = "/mnt/pre-prod/jwtSecretFile";
    #   settings = {
    #     theme = "dark";
    #     default_2fa_method = "webauthn";
    #     server.host = "0.0.0.0";
    #   };
    # };
    # test.enable = true;
    # test.secrets.manual = true;
    # test.settings.theme = "grey";
    # test.settings.server.disable_healthcheck = true;
    # test.settingsFiles = [ "/mnt/test/authelia" "/mnt/test-authelia.conf" ];
  # };

  # nixpkgs.config.allowUnfree = true;
  # services.cockroachdb = {
  #    enable = true;
  #    http.port = 9090;
  #    locality = "country=fr";
  #    insecure = true;
  # };


  # services.zitadel = {
  #   enable = true;
  #   masterKeyFile = "/etc/nixos/.secrets.zitadel";
  #   settings = {
  #     TLS.KeyPath = "/var/lib/acme/hetzner005.lesgrandsvoisins.com/key.pem";
  #     TLS.CertPath = "/var/lib/acme/hetzner005.lesgrandsvoisins.com/fullchain.pem";
  #     ExternalDomain = "hetzner005.lesgrandsvosins.com";
  #     ExternalSecure = true;
  #     ExternalPort = 8443;
  #   };
  # };
  # users.users.zitadel.extraGroups = ["wwwrun"];
  
  # services.traefik = {
  #   enable = true;
  #   staticConfigOptions = {
  #     api = true;

  #     entryPoints = {
  #       # web = {
  #       #   address = ":10080/tcp";
  #       #   http.redirections.entrypoint = {
  #       #      to = "websecure";
  #       #      scheme = "https";
  #       #   };
  #       # };
  #       websecure = {
  #         address = ":10443";
  #         # http.tls = true;
  #         # http.tls.domains=[{main="hetzner005.lesgrandsvoisins.com";}];
  #       };
       
  #       # websecure = {
  #       #   address = 10443;
  #       #   http.tls = {
  #       #      certResolver = "leresolver";
  #       #      domains = [{main = "hetzner005.lesgrandsvoisins.com"}];
  #       #   };
  #       # };
  #       # http.redirections.entrypoint = {
  #       #     to = "websecure";
  #       #     scheme = "https";
  #       #   };

  #     };
  #     # providers = {
  #     #   http = {
  #     #     tls = {
  #     #       cert = default;
  #     #       key = default;
  #     #     };
  #     #   };
  #     # };

  #     # forwardedHeaders.insecure = true;
  #     # providers = {
  #     #   http = {
  #     #     endpoint = "https://dav.lesgrandsvoisins.com";
  #     #     tls = {
  #     #       cert = "/var/lib/acme/hetzner005.lesgrandsvoisins.com/fullchain.pem";
  #     #       key = "/var/lib/acme/hetzner005.lesgrandsvoisins.com/key.pem";
  #     #     }
  #     #   }
  #     # }
  #   };
  #   dynamicConfigOptions = {
  #   #   # routes = [{
  #   #   #   match = "(PathPrefix(`/dashboard`)";
  #   #   #   kind = "Rule";
  #   #   #   services = [{name="api@internal";kind="TraefikService";}];
  #   #   # }];
  #   #   # http.middlewares.prefix-strip.stripprefixregex.regex = "/[^/]+";
  #     http = {
  #   #     # services = {
  #   #     #   rtl.loadBalancer.servers = [ { url = "http://169.254.1.29:3000/"; } ];
  #   #     #   spark.loadBalancer.servers = [ { url = "http://169.254.1.17:9737/"; } ];
  #   #     # };
  #       services = {
  #         www.loadBalancer.servers = [ { url = "https://www.lesgrandsvoisins.com/"; } ];
  #       };
  #       routers = {
  #         myrouter = {
  #           rule = "Host(`hetzner005.lesgrandsvoisins.com`)";
  #           # entryPoints = [ "websecure" ];
  #           service = "www";
  #           tls = true;
  #         };
  #       };
  #     };  
  #     tls = {
  #       # certificates = [{
  #       #   certFile = "/var/lib/acme/hetzner005.lesgrandsvoisins.com/fullchain.pem";
  #       #   keyFile = "/var/lib/acme/hetzner005.lesgrandsvoisins.com/key.pem";
  #       #   # stores = "hetzner005.lesgrandsvoisins.com";
  #       # }];
  #       stores.default.defaultCertificate = {
  #         certFile = "/var/lib/acme/hetzner005.lesgrandsvoisins.com/fullchain.pem";
  #         keyFile = "/var/lib/acme/hetzner005.lesgrandsvoisins.com/key.pem";
  #       };
  #     };
  #   };
  # };
}

