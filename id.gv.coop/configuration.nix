# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
# inputs.docspell.url = "github:eikek/docspell?dir=nix/";
{ config, lib, pkgs, ... }:
let
  extraConfigNginxKeycloak = ''
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Host $host;
    proxy_set_header X-Forwarded-Proto $scheme;
    add_header Content-Security-Policy "frame-src *; frame-ancestors *; object-src *;";
    add_header Access-Control-Allow-Credentials true;
  '';
  # repo = fetchurl {
  #   url = "https://github.com/eikek/docspell";
  #   sha256 = "sha256-X2mM+Z5s8Xm1E6zrZ0wcRaivLEvqbk5Dn+GSXkZHdLM=";
  # };
  # docspellPkgs = pkgs.callPackage (import "${repo}/nix/pkg.nix") {};
  # docspell = (builtins.getFlake "github:eikek/docspell");
  # docspell = (builtins.getFlake "github:eikek/docspell").packages.${builtins.currentSystem}.default
  # docspell = (builtins.getFlake "github:eikek/docspell");
  # docspellrepo = builtins.fetchurl {
  #   url = "https://github.com/eikek/docspell";
  #   sha256 = "sha256:098bxn20s7n5h9daadz2rf8imwbsmxvh7f3mglnwjvcfzj58jm61";
  # };
  # docspellpkgs = docspellrepo.callPackage (import "${docspellrepo}/nix/pkg.nix") {} ;
  postgresDocspellPassword = (lib.removeSuffix "\n" (builtins.readFile  "/etc/nixos/.secrets.postgres.docspell" ));
  docspellServer = (lib.removeSuffix "\n" (builtins.readFile "/etc/nixos/.secrets.docspell.server"  ));

in
{
  nix.settings.experimental-features = "nix-command flakes";
  system.stateVersion = "24.05";
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # ./mailserver.nix
      # ./keycloak.nix
      # docspell.nixosModules.default
      # (builtins.getFlake "github:eikek/docspell")
      # (builtins.fetchGit {
      # url = "https://github.com/eikek/docspell";
      # ref = "refs/tags/v0.42.0";
      # # sha256 = "sha256:15v6b5z8gjspps5hyq16bffbwmq0rwfwmdhyz23frfcni3qkgzpc";
      # })
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  security.acme = {
    defaults.email = "chris@mann.fr";
    acceptTerms = true;
    # certs."id.gv.coop".listenHTTP = ":8888";
  };

  networking = {
    hostName = "id"; # Define your hostname.
    # Pick only one of the below networking options.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    networkmanager.enable = true;  # Easiest to use and most distros use this by default.
    hosts = {
      "127.0.0.1" = [ "localhost" "lemonldap.internal" "manager.lemonldap.internal" "handler.lemonldap.internal"  "test.lemonldap.internal"  "test2.lemonldap.internal"  "api.lemonldap.internal" "wa.lemonldap.internal" "sa.lemonldap.internal"];
      "127.0.0.2" = [ "id"];
      "::1" = [ "id""localhost"];
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;


  

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.ac
  # hardware.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mannchri = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "nginx" "acme" ]; # Enable ‘sudo’ for the user.
    initialPassword = "reverse";
    packages = with pkgs; [
  #     firefox
  #     tree
        # vim
        # wget
        # dig
    ];
  };

  systemd.tmpfiles.rules = [
    "d /var/run/.secret 0755 root nginx"
    "f /var/run/.secret/.keycloak 0644 root root"
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
    environment.systemPackages = with pkgs; [
    ((vim_configurable.override {  }).customize{
      name = "vim";
      vimrcConfig.customRC = ''
        " your custom vimrc
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
        " ...
      '';
      }
    )
    wget
    git
    dig
    curl
    lynx
    tmux
    pwgen
    python311Full
    python311Packages.pip
    python311Packages.python-ldap
    openldap
    unzip
    # jre17_minimal
    docker
    docker-compose
    nodejs_22
    gnumake
    go
    corepack_22
    python311Packages.sphinx
    # authelia
    # docspell
    # docspell.nixosModules.default
      #  docspellpkgs.docspell-joex
      #  docspellpkgs.docspell-restserver
    # docspellpkgs.nixosModules.default
    # docspellpkgs
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  virtualisation.docker = {
    enable = true;

  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services = {
    # docspell-joex = {
    #   enable = true;
    #   base-url = "http://localhost:7878";
    #   bind = {
    #     address = "0.0.0.0";
    #     port = 7878;
    #   };
    #   scheduler = {
    #     pool-size = 1;
    #   };
    #   jdbc = {
    #     url = "jdbc:postgresql://localhost:5432/docspell";
    #     user = "docspell";
    #     password = postgresDocspellPassword;
    #   };
    # };
    # docspell-restserver = {
    #   enable = true;
    #   base-url = "http://localhost:7880";
    #   bind = {
    #     address = "0.0.0.0";
    #     port = 7880;
    #   };
    #   auth = {
    #     server-secret = docspellServer;
    #   };
    #   backend = {
    #     signup = {
    #       mode = "invite";
    #       new-invite-password = "dsinvite2";
    #       invite-time = "30 days";
    #     };
    #     jdbc = {
    #       url = "jdbc:postgresql://localhost:5432/docspell";
    #       user = "docspell";
    #       password = postgresDocspellPassword;
    #     };
    #   };
    # };
    keycloak = {
      enable = true;
      database = {
        type = "postgresql";
        createLocally = true;
        username = "keycloak";
        passwordFile = "/var/run/.secret/.keycloak";
        # useSSL = false;
      };
      settings = {
        https-port = 12443;
        http-port = 12080;
        # proxy = "passthrough";
        proxy = "reencrypt";
        # proxy = "edge";
        hostname = "key.gv.coop";
        # hostname = "key.lesgrandsvoisins.com";
        http-enabled = true;
      };
      # sslCertificate = "/var/lib/acme/key.lesgrandsvoisins.com/fullchain.pem";
      # sslCertificateKey = "/var/lib/acme/key.lesgrandsvoisins.com/key.pem";
      sslCertificate = "/var/lib/acme/key.gv.coop/fullchain.pem";
      sslCertificateKey = "/var/lib/acme/key.gv.coop/key.pem";
      # themes = {lesgv = (pkgs.callPackage "/etc/nixos/keycloaktheme/derivation.nix" {});};
    };
    # postgresql.enable = true;
    postgresql = {
      enable = true;
      enableTCPIP = true;
    #   package = pkgs.postgresql_14;
      ensureDatabases = [
        "keycloak"
        "docspell"
      ];
      ensureUsers = [
        {
          name = "keycloak";
          ensureDBOwnership = true;
        }
        {
          name = "docspell";
          ensureDBOwnership = true;
        }
      ]; 
    };
    # postgresDocspellPassword
    # tomcat = {
    #   enable = true;

    # };
    openssh = {
      enable = true;
    };
    nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;
      # virtualHosts = {
      #   "authelia.gv.coop" = {
      #     enableACME = true; 
      #     forceSSL = true; 
      #     locations."/.well-known" = { proxyPass = null; };
      #     locations."/" = {
      #       proxyPass = "http://localhost:9091";
      #       extraConfig = ''
      #         proxy_set_header X-Forwarded-Proto $scheme;
      #         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      #         proxy_redirect off;
      #       '';
      #     };
      #   };
      # };
      virtualHosts = {
        "ldapmanager.gv.coop" = {
        # "ldapmanager.lesgrandsvoisins.com" = {
          enableACME = true; 
          forceSSL = true; 
          locations."/.well-known" = { proxyPass = null; };
          locations."/" = {
            proxyPass = "http://localhost:3000";
            extraConfig = ''
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_redirect off;
            '';
          };
        };
      };
      virtualHosts = {
        "ldapui.gv.coop" = {
        # "ldapui.lesgrandsvoisins.com" = {
          enableACME = true; 
          forceSSL = true; 
          locations."/.well-known" = { proxyPass = null; };
          locations."/" = {
            proxyPass = "http://localhost:5000";
            extraConfig = ''
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_redirect off;
              # auth_basic "Administrator’s Area";
              # auth_basic_user_file /var/lib/.htpasswd;
            '';
          };
        };
      };
      virtualHosts = {
        "key.gv.coop" = {
        # "key.lesgrandsvoisins.com" = {
          enableACME = true;
          forceSSL = true;
          root = "/var/www/key";
          locations = {
            "/realms/master/account" = {
              # proxyPass = "https://key.lesgrandsvoisins.com:12443";
              proxyPass = "https://key.gv.coop:12443";
              extraConfig = extraConfigNginxKeycloak + ''
                rewrite ^$ https://key.lesgrandsvoisins.com redirect;
                # error_page 403 =302 https://key.lesgrandsvoisins.com/realms/master/protocol/openid-connect/auth?client_id=account-console&redirect_uri=https%3A%2F%2Fkey.lesgrandsvoisins.com%2Frealms%2Fmaster%2Faccount%2F;
                error_page 403 =302 https://key.gv.coop/realms/master/protocol/openid-connect/auth?client_id=account-console&redirect_uri=https%3A%2F%2Fkey.gv.coop%2Frealms%2Fmaster%2Faccount%2F;
              '';
            };
            "/admin/master/console" = {
              # proxyPass = "https://key.lesgrandsvoisins.com:12443";
              proxyPass = "https://key.gv.coop:12443";
              extraConfig = extraConfigNginxKeycloak + ''
                # error_page 403 =302 https://key.lesgrandsvoisins.com/realms/master/protocol/openid-connect/auth?client_id=account-console&redirect_uri=https%3A%2F%2Fkey.lesgrandsvoisins.com%2Frealms%2Fmaster%2Faccount%2F;
                error_page 403 =302 https://key.gv.coop/realms/master/protocol/openid-connect/auth?client_id=account-console&redirect_uri=https%3A%2F%2Fkey.gv.coop%2Frealms%2Fmaster%2Faccount%2F;
              '';
            };
            "/admin/serverinfo" = {
              # proxyPass = "https://key.lesgrandsvoisins.com:12443";
              proxyPass = "https://key.gv.coop:12443";
              extraConfig = extraConfigNginxKeycloak + ''
                # error_page 403 =302 https://key.lesgrandsvoisins.com/realms/master/protocol/openid-connect/auth?client_id=account-console&redirect_uri=https%3A%2F%2Fkey.lesgrandsvoisins.com%2Frealms%2Fmaster%2Faccount%2F;
                error_page 403 =302 https://key.gv.coop/realms/master/protocol/openid-connect/auth?client_id=account-console&redirect_uri=https%3A%2F%2Fkey.gv.coop%2Frealms%2Fmaster%2Faccount%2F;
              '';
            };
            "/" = {
              # proxyPass = "https://key.lesgrandsvoisins.com:12443";
              proxyPass = "https://key.gv.coop:12443";
              extraConfig = extraConfigNginxKeycloak + ''
                # rewrite ^/$ https://key.lesgrandsvoisins.com/realms/master/protocol/openid-connect/auth?client_id=account-console&redirect_uri=https%3A%2F%2Fkey.lesgrandsvoisins.com%2Frealms%2Fmaster%2Faccount%2F redirect;
                rewrite ^/$ https://key.gv.coop/realms/master/protocol/openid-connect/auth?client_id=account-console&redirect_uri=https%3A%2F%2Fkey.gv.coop%2Frealms%2Fmaster%2Faccount%2F redirect;
              '';
            };
          };
        };
        "lemonldap.gv.coop" = {
          enableACME = true; 
          forceSSL = true; 
          locations."/.well-known" = { proxyPass = null; };
          locations."/" = {
            proxyPass = "http://lemonldap.internal:8080";
            extraConfig = ''
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_redirect off;
            '';
          };
        };
        "manager.lemonldap.gv.coop" = {
          enableACME = true; 
          forceSSL = true; 
          locations."/.well-known" = { proxyPass = null; };
          locations."/" = {
            proxyPass = "http://manager.lemonldap.internal:8080";
            extraConfig = ''
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_redirect off;
            '';
          };
        };
        "handler.lemonldap.gv.coop" = {
          enableACME = true; 
          forceSSL = true; 
          locations."/.well-known" = { proxyPass = null; };
          locations."/" = {
            proxyPass = "http://handler.lemonldap.internal:8080";
            extraConfig = ''
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_redirect off;
            '';
          };
        };
        "api.lemonldap.gv.coop" = {
          enableACME = true; 
          forceSSL = true; 
          locations."/.well-known" = { proxyPass = null; };
          locations."/" = {
            proxyPass = "http://api.lemonldap.internal:8080";
            extraConfig = ''
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_redirect off;
            '';
          };
        };
      };
    };
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 8888 80 443 25 587 12443 14443];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for howabout:blank#blocked
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  # system.stateVersion = "24.05"; # Did you read the comment?
#   containers.key = {
#     bindMounts = {
#       "/var/lib/acme/key.gv.coop/" = {
#         hostPath = "/var/lib/acme/key.gv.coop/";
#         isReadOnly = true;
#       }; 
#     };
#     autoStart = true;
#     # privateNetwork = true;
#     # hostAddress = "192.168.105.10";
#     # localAddress = "192.168.105.11";
#     # hostAddress6 = "fa01::1";
#     # localAddress6 = "fa01::2";
#     config = { config, pkgs, lib, ...  }: {
#       environment.systemPackages = with pkgs; [
#         ((vim_configurable.override {  }).customize{
#           name = "vim";
#           vimrcConfig.customRC = ''
#             " your custom vimrc
#             set mouse=a
#             set nocompatible
#             colo torte
#             syntax on
#             set tabstop     =2
#             set softtabstop =2
#             set shiftwidth  =2
#             set expandtab
#             set autoindent
#             set smartindent
#             " ...
#           '';
#           }
#         )
#         git
#         lynx
#         openldap
#       ];
#       # virtualisation.docker.enable = true;
#       system.stateVersion = "24.05";
#       nix.settings.experimental-features = "nix-command flakes";
#       networking = {
#         firewall = {
#           enable = false;
#           allowedTCPPorts = [  443 587 12443 ]; 
#         };
#         useHostResolvConf = lib.mkForce false;
#       };
#       systemd.tmpfiles.rules = [
#         "d /var/run/.secret 0755 root nginx"
#         "f /var/run/.secret/.keycloak 0644 root root"
#         # "f /var/run/.secret/.keycloakdata 0666 root root"
#       ];
#       # security.acme.acceptTerms = true;
#       users = {
#         groups = {
#           "acme" = {
#             gid = 993;
#             members = ["acme"];
#           };
#           "wwwrun" = {
#             gid = 54;
#             members = ["acme" "wwwrun"];
#           };
#         };
#         users = {
#           "acme" = {
#             uid = 994;
#             group = "acme";
#           };
#           "wwwrun" = {
#             uid = 54;
#             group = "wwwrun";
#           };
#         };
#       };
#       services = {
#         resolved.enable = true;
        
#       };
#     };
#   };
}

