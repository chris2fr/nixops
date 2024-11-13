# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).
{ config, pkgs, lib, ... }:
let
  mannchriRsaPublic = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/mailserver/vars/cert-public.nix));
  keyLesgrandsvoisinsVikunja  = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.keylesgrandsvoisins.vikunja));
  keycloakVikunja  = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.keycloak.vikunja));
  keyGVcoopVikunja = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.keygvcoop.vikunja));
  emailVikunja  = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.keygvcoop.vikunja));
  emailList  = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.email.list));
  bindPW  = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.bind));
  keySftpgo = (lib.removeSuffix "\n" (builtins.readFile  /etc/nixos/.secrets.key.sftpgo ));
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz";
in
{
  nix.settings.experimental-features = "nix-command flakes";
  nixpkgs.config.allowUnfree = true; 
  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 113272;
    "fs.inotify.max_user_instances" = 256;
    "fs.inotify.max_queued_events" = 32768;
  };
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./httpd.nix
    ./mailserver.nix
    ./guichet.nix
    ./postgresql.nix
    ./users.nix
    ./systemd.nix
    ./wagtail.nix
    ./common.nix # Des configurations communes pratiques
    ./servers.nix # I am migrating other services here
    ./containers.nix
    ./nginx.nix
    (import "${home-manager}/nixos")
  ];
  systemd.tmpfiles.rules = [
    "d /var/www/key.lesgrandsvoisins.com 0755 www users"
    "d /var/www/lesgrandsvoisins.com 0755 www users"
    "d /var/www/lesgrandsvoisins 0755 wagtail users"
    "d /var/www/lesgrandsvoisins/static 0755 wagtail users"
    "d /var/www/lesgrandsvoisins/medias 0755 wagtail users"
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
    # burp
    openssl
    postgresql_13
    qemu
    # (pkgs.callPackage ./etc/sftpgo/sftpgo/default.nix { }  )
    (pkgs.callPackage ./etc/sftpgo/sftpgo-plugin-auth/sftpgoPluginAuth.nix { }  )
  ];
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
    nat = {
      forwardPorts = [
      {
        destination = "192.168.103.2:443";
        proto = "tcp";
        sourcePort = 11443;
      }
      # {
      #   destination = "192.168.105.11:14443";
      #   proto = "tcp";
      #   sourcePort = 1443;
      # }
      # {
      #   destination = "192.168.105.11:12443";
      #   proto = "tcp";
      #   sourcePort = 12443;
      # }
      # {
      #   destination = "192.168.107.11:10389";
      #   proto = "tcp";
      #   sourcePort = 10389;
      #   # loopbackIPs = ["116.202.236.241" "2a01:4f8:241:4faa::"];
      # }
      # {
      #   destination = "192.168.107.11:10636";
      #   proto = "tcp";
      #   sourcePort = 10636;
      # }
      # {
      #   destination = "192.168.107.11:10389";
      #   proto = "tcp";
      #   sourcePort = 10389;
      # }
      # {
      #   destination = "192.168.107.11:10636";
      #   proto = "tcp";
      #   sourcePort = 10636;
      # }
      ];
    };
    # firewall.enable = false;
    firewall.trustedInterfaces = [ "docker0" "lxdbr1" "lxdbr0" "ve-silverbullet" "ve-openldap"];
    # Syncthing ports: 8384 for remote access to GUI
    # 22000 TCP and/or UDP for sync traffic
    # 21027/UDP for discovery
    # source: https://docs.syncthing.net/users/firewall.html
    firewall.allowedTCPPorts = [ 22 25 80 443 143 587 993 995
      636 
      8443 
      9080 9443 
      10080 10443 
      11443
      12080 12443
      14443
      8384 22000 
      22000 21027 
      10389 10636 
      14389 14636
      1360
    ];
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
  
  # home-manager.users.crabfit = {
  #   home.packages = with pkgs; [ 
  #     yarn
  #   ];
  #   home.stateVersion = "24.05";
  #   programs.home-manager.enable = true;
  # };
  home-manager.users = {
    fossil = {pkgs, ...}: {
      home.packages = with pkgs; [ 
        fossil
      ];
      home.stateVersion = "24.05";
      programs.home-manager.enable = true;
    };
    # radicale = {pkgs, ...}: {
    #   home.packages = with pkgs; [ 
    #     python311
    #     python311Packages.gunicorn
    #   ];
    #   home.stateVersion = "24.05";
    #   programs.home-manager.enable = true;
    # };
    guichet = {pkgs, ...}: {
      home.packages = with pkgs; [ 
        go
        gnumake
        python311
        nodejs_20
      ];
      home.stateVersion = "24.05";
      programs.home-manager.enable = true;
    };
    filebrowser = {pkgs, ...}: {
      home.packages = with pkgs; [ 
        filebrowser
      ];
      home.stateVersion = "24.05";
      programs.home-manager.enable = true;
    };
    mannchri = {pkgs, ...}: {
      home.packages = [ 
        pkgs.atool 
        pkgs.httpie 
        pkgs.nodejs_20
      ];
      home.stateVersion = "24.05";
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
  
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
  environment.sessionVariables = rec {
    EDITOR="vim";
    WAGTAIL_ENV = "production";
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "contact@lesgrandsvoisins.com";
    defaults.webroot = "/var/www";
  };
  services = { 
    # seafile = {
    #   enable = true;
    #   adminEmail = "chris@lesgrandsvoisins.com";
    #   initialAdminPassword = emailList;
    #   seahubAddress = "https://drive.lesgrandsvoisins.com:10443";
    # };
    etebase-server = {
      enable = true;
      unixSocket = "/var/lib/etebase-server/etebase-server.sock"; 
      user = "etebase-server";
      settings = {
        global.debug = false;
        global.secret_file = "/var/lib/etebase-server/.secrets.etebase"; # mind permissions
        allowed_hosts.allowed_host1 = "ete.village.ngo";
      };
    };
    # etesync-dav = {
    #   enable = true;
    #   apiUrl = "https://ete.village.ngo";
    #   # sslCertificate = "/var/lib/acme/ete.village.ngo/full.pem";
    #   # sslCertificateKey = "/var/lib/acme/ete.village.ngo/key.pem";
    #   host = "https://etedav.village.ngo";
    # };
    syncthing = {
      enable = true;
      openDefaultPorts = true;
      overrideFolders = true;
      overrideDevices = true;
      settings = {
        devices = {
          "mannchrilenovoslim7" = { 
            id = "VJKOQSN-AC3YKXV-AV4N74C-MH7HZ4R-GBTAGOV-SETMPBT-GCKJC5M-G6XSVQL"; 
            autoAcceptFolders = true;
          };
          "mannchriphone" = {
            id = "SUJCVUC-XXVY326-42GP5IU-UO6RMEJ-2IHAXEL-KBA4YPU-BQFQMYN-YG66ZQZ";
            autoAcceptFolders = true;
          };
        };
        folders = {
          "LogSeqMann" = {       
            enable = true;
            id = "LogSeqMann";
            label = "LogSeqMann";
            path = "/var/lib/syncthing/LogSeqMann";
            devices = [ "mannchrilenovoslim7" "mannchriphone" ];
            ignorePerms = false;  # By default, Syncthing doesn't sync file permissions. This line enables it for this folder.
          };
        };
      };
    };
    # coredns = {
    #   enable = true;
    #   config = ''

    #   '';
    # };
    vaultwarden = {
      enable = true;
    };
    uptime-kuma = {
      enable = true;
    };
    ethercalc = {
      enable = true;
      port = 8123;
    };
    xandikos = {
      enable = true;
      port = 5280;
      extraOptions = [ "--autocreate"
        "--defaults"
      ];
    };
    radicale = {
      enable = true;
      settings = {
        auth.type = "http_x_remote_user";
        # logging.level = "debug";
        # web.type = "none";
        # server = {
        #   ssl = true;
        #   certificate = "/var/lib/acme/dav.resdigita.com/fullchain.pem";
        #   key = "/var/lib/acme/dav.resdigita.com/key.pem";
        #   certificate_authority = "/var/lib/acme/dav.resdigita.com/fullchain.pem";
        # };
      };
      rights = {
        root = {
          user = ".+";
          collection = "";
          permissions = "R";
        };
        principal = {
          user = ".+";
          collection = "{user}/[^/]+";
          permissions = "rw";
        };
        shared = {
          user = ".*";
          collection = "(shared|resdigita|interetpublic|lesgrandsvoisins)/[^/]*";
          permissions = "RW";
        };
      };
    };
    vikunja = {
      enable = true;
      frontendScheme = "https";
      frontendHostname = "task.lesgrandsvoisins.com";
      # frontendHostname = "vikunja.lesgrandsvoisins.com";
      # frontendHostname = "vikunja.gv.coop";
      # frontendHostname = "vikunja.village.ngo";
      # database.type = "postgres";
      settings = {
        mailer = {
          enabled = true;
          host = "mail.lesgrandsvoisins.com";
          authtype = "login";
          username = "list@lesgrandsvoisins.com";
          password = emailList;
        };
        defaultsettings = {
          week_start = 1;
          language = "fr-FR";
          timezone = "Europe/Paris";
          discoverable_by_email = true;
          discoverable_by_name = true;
        };
        service = {
          timezone = "Europe/Paris";
        };  
        auth = {
          local.enabled = false;
          openid.enabled = true;
          # openid.redirecturl = "https://vikunja.village.ngo/auth/openid/";
          # openid.redirecturl = "https://vikunja.gv.coop/auth/openid/";
          openid.redirecturl = "https://task.lesgrandsvoisins.com/auth/openid/";
          openid.providers = [
          {
            name = "keyLesGrandsVoisinsCom";
            authurl = "https://key.lesgrandsvoisins.com/realms/master";
            logouturl = "https://key.lesgrandsvoisins.com/realms/master/protocol/openid-connect/logout";
            clientid = "vikunja";
            clientsecret = keyLesgrandsvoisinsVikunja;
          }
          # {
          #   name = "keyGVcoop";
          #   authurl = "https://key.gv.coop/realms/master";
          #   logouturl = "https://key.gv.coop/realms/master/protocol/openid-connect/logout";
          #   clientid = "vikunja";
          #   clientsecret = keyGVcoopVikunja;
          # }
          {
            name = "VillageNgo";
            authurl = "https://keycloak.village.ngo/realms/master";
            logouturl = "https://keycloak.village.ngo/realms/master/protocol/openid-connect/logout";
            clientid = "vikunja";
            clientsecret = keycloakVikunja;
          }
          ];
        };
      };
    };
    sftpgo = {
      enable = true;
      user = "sftpgo";  
      group = "wwwrun";
      dataDir = "/var/www/dav/data";
      extraArgs = [
          "--log-level"
          "info"
        ];
      settings = {
        webdavd.bindings = [
          {
            port = 14443;
            address = "116.202.236.241";
            certificate_file = "/var/lib/acme/sftpgo.lesgrandsvoisins.com/full.pem";
            certificate_key_file = "/var/lib/acme/sftpgo.lesgrandsvoisins.com/key.pem";
            enable_https = true;
          }
          {
            port = 14443;
            address = "[2a01:4f8:241:4faa::]";
            certificate_file = "/var/lib/acme/sftpgo.lesgrandsvoisins.com/full.pem";
            certificate_key_file = "/var/lib/acme/sftpgo.lesgrandsvoisins.com/key.pem";
            enable_https = true;
          }
        ];
        sftpd.bindings = [
          {
            address = "116.202.236.241";
          }
          {
            address = "[2a01:4f8:241:4faa::]";
          }
        ];
        httpd.bindings = [
          {
            port = 10443;
            address = "116.202.236.241";
            certificate_file = "/var/lib/acme/sftpgo.lesgrandsvoisins.com/full.pem";
            certificate_key_file = "/var/lib/acme/sftpgo.lesgrandsvoisins.com/key.pem";
            enable_https = true;
            oidc = {
              config_url = "https://key.lesgrandsvoisins.com/realms/master/";
              client_id = "sftpgo";
              client_secret = keySftpgo;
              username_field = "username";
              redirect_base_url = "https://sftpgo.lesgrandsvoisins.com";
            };
            branding = {
              name = "sftpgo.lesgrandsovisins.com : Accès au Drive des Grands Voisins";
              short_name = "Drive des GV (SFTPGO)";
            };
          }
          {
            port = 10443;
            address = "[2a01:4f8:241:4faa::]";
            certificate_file = "/var/lib/acme/sftpgo.lesgrandsvoisins.com/full.pem";
            certificate_key_file = "/var/lib/acme/sftpgo.lesgrandsvoisins.com/key.pem";
            enable_https = true;
            oidc = {
              config_url = "https://key.lesgrandsvoisins.com/realms/master/";
              client_id = "sftpgo";
              client_secret = keySftpgo;
              redirect_base_url = "https://sftpgo.lesgrandsvoisins.com";
              username_field = "username";
            };
            branding = {
              name = "sftpgo.lesgrandsovisins.com : Accès au Drive des Grands Voisins";
              short_name = "Drive des GV (SFTPGO)";
            };
          }
        ];
        plugins = [{
          type = "auth";
          cmd = "/run/current-system/sw/bin/sftpgo-plugin-auth";
          args = ["serve"
            "--config-file"
            "/var/run/sftpgo/sftpgo-plugin-auth.json"
          ];
          auth_options.scope = 5;
          auto_mtls = true;
        }];
      };  
    };
    minio = {
      enable = true;
    };
    homepage-dashboard = {
      enable = true;
      listenPort = 8882;
      openFirewall = true;
    #   widgets = [
    #     {
    #       logo = {
    #         icon = "https://www.lesgrandsvoisins.com/media/images/gv.original.svg";
    #       };
    #     }
    #     {
    #       greeting = {
    #         text_size = 1;
    #         text = "Homepage-Dashboard.resdigita.com. Ce tableau de bord fournit des liens vers toutes les ressources de ResDigita des GV.";
    #       };
    #     }
    #   ];
    #   services = [
    #     {
    #     "Services GV unifiés stables" = [
    #       {
    #       "Keycloak pour la connexion unifiée" = {
    #   href = "https://keycloak.resdigita.com/realms/master/account";
    #   description = "Serveur de connexion et déconnexion unifiées (SSO en OAuth2) pour plusieurs services GV.";
    #   icon = "https://avatars.githubusercontent.com/u/4921466";
    #       };
    #       }
    #       {
    #       "HedgeDoc carnets collaboratifs en markdown" = {
    #   href = "https://hedgedoc.resdigita.com/auth/oauth2";
    #   icon = "https://hedgedoc.resdigita.com/icons/android-chrome-512x512.png";
    #   description = "Un serveur de documents en format Markdown pouvant être modifiés par plusieurs personnes en même temps. ";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Ressasie de login GV" = [
    #       {
    #       "Guichet du profil et du mot de passe" = {
    #   href = "https://guichet.resdigita.com/user";
    #   icon = "https://www.lesgrandsvoisins.com/media/images/gv.original.svg";
    #   description = "Depuis Guichet, vous pouvez ajouter et supprimer des boîtes-aux-lettres de courriel.";
    #       };
    #       }
    #       {
    #       "Roundcube Webmail" = {
    #   href = "https://mail.lesgrandsvoisins.com";
    #   description = "Consulter vos courriels des comptes des GV avec pour login le courriel du compte GV et le mot de passe de votre compte des GV.";
    #   icon = "https://mail.lesgrandsvoisins.com/skins/elastic/images/logo.svg?s=1";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Services à accès ouverts stables" = [
    #       {
    #       "BigBlueButton pour les réunions visio et formation" = {
    #   href = "https://meet.lesgrandsvoisins.com/";
    #   description = "Un espace de rencontres visio qui tient vraiement la route.";
    #   icon = "https://bigbluebutton.org/wp-content/uploads/2021/01/BigBlueButton_icon.svg.png ";
    #       };
    #       }
    #       {
    #       "Uptime-Kuma pour les statuts des sites essentiels" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Sites webs publics" = [
    #       {
    #       "LesGrandsVoisins.fr est notre portail" = {
    #  href = "https://www.lesgrandsvoisins.com/";
    #  description = "Le site internet des GV.";
    #  icon = "https://www.lesgrandsvoisins.com/media/images/gv.original.svg";
    #       };
    #       }
    #       {
    #       "Blog.LesGrandsVoisisns.com pour les nouvelles" = {
    #  href = "https://blog.lesgrandsvoisins.com";
    #  icon = "https://blog.lesgrandsvoisins.com/ghost/assets/img/apple-touch-icon-74680e326a7e87b159d366c7d4fb3d4b.png";
    #  description = "Le blog des Grands Voisins.";
    #       };
    #       }
    #       {
    #       "Quartz.ResDigita.com pour la doc technique" = {
    #   href = "https://quartz.resdigita.com/";
    #   icon = "https://quartz.jzhao.xyz/static/icon.png";
    #   description = "Documentation de Resdigita des GV sur l'ensemble de nos services autonomes de par et pour les GV ";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Services GV unifiés en bêta" = [
    #       {
    #       "Vikunja gestionnaire des tâches à faire en équipe" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Services à accès ouverts en bêta" = [
    #       {
    #       "VaultWarden pour les maux des mots de passe compatible BitWarden" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #       {
    #       "EtherCalc pour un tableur collaboratif" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #       {
    #       "Crabfit pour trouver un moment de rendez-vous" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Comptes indépendants" = [
    #       {
    #       "Wagtail.resdigita.com pour la gestion du contenu des sites webs" = {
    #         href = "";
    #         description = "";            href = "";
    #         description = "";
    #         icon = "";
    #       {
    #       "Ghost pour la gestion du blog.lesgrandsvoisins.com" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #       {
    #       "ListMonk pour les listes de diffusion" = {
    #   href = "https://list.lesgrandsvoisins.com";
    #   description = "Le serveur de listes de diffusion des GV.";
    #   noticon = "https://listmonk.app/static/images/logo.svg";
    #   icon = "https://listmonk.app/static/images/favicon.png";
    #       };
    #       }
    #       {
    #       "Uptime-Kuma pour le statut des services" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Services GV unifiés en alpha" = [
    #       {
    #       "SilverBullet cahier à plusieurs" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #       {
    #       "FileBrowser casier numérique" = {
    #   href = "https://filebrowser.resdigita.com/files/";
    #   icon = "httpwidgets = [
    #     {
    #       logo = {
    #         icon = "https://www.lesgrandsvoisins.com/media/images/gv.original.svg";
    #       };
    #     }
    #     {
    #       greeting = {
    #         text_size = 1;
    #         text = "Homepage-Dashboard.resdigita.com. Ce tableau de bord fournit des liens vers toutes les ressources de ResDigita des GV.";
    #       };
    #     }
    #   ];
    #   services = [
    #     {
    #     "Services GV unifiés stables" = [
    #       {
    #       "Keycloak pour la connexion unifiée" = {
    #   href = "https://keycloak.resdigita.com/realms/master/account";
    #   description = "Serveur de connexion et déconnexion unifiées (SSO en OAuth2) pour plusieurs services GV.";
    #   icon = "https://avatars.githubusercontent.com/u/4921466";
    #       };
    #       }
    #       {
    #       "HedgeDoc carnets collaboratifs en markdown" = {
    #   href = "https://hedgedoc.resdigita.com/auth/oauth2";
    #   icon = "https://hedgedoc.resdigita.com/icons/android-chrome-512x512.png";
    #   description = "Un serveur de documents en format Markdown pouvant être modifiés par plusieurs personnes en même temps. ";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Ressasie de login GV" = [
    #       {
    #       "Guichet du profil et du mot de passe" = {
    #   href = "https://guichet.resdigita.com/user";
    #   icon = "https://www.lesgrandsvoisins.com/media/images/gv.original.svg";
    #   description = "Depuis Guichet, vous pouvez ajouter et supprimer des boîtes-aux-lettres de courriel.";
    #       };
    #       }
    #       {
    #       "Roundcube Webmail" = {
    #   href = "https://mail.lesgrandsvoisins.com";
    #   description = "Consulter vos courriels des comptes des GV avec pour login le courriel du compte GV et le mot de passe de votre compte des GV.";
    #   icon = "https://mail.lesgrandsvoisins.com/skins/elastic/images/logo.svg?s=1";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Services à accès ouverts stables" = [
    #       {
    #       "BigBlueButton pour les réunions visio et formation" = {
    #   href = "https://meet.lesgrandsvoisins.com/";
    #   description = "Un espace de rencontres visio qui tient vraiement la route.";
    #   icon = "https://bigbluebutton.org/wp-content/uploads/2021/01/BigBlueButton_icon.svg.png ";
    #       };
    #       }
    #       {
    #       "Uptime-Kuma pour les statuts des sites essentiels" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Sites webs publics" = [
    #       {
    #       "LesGrandsVoisins.fr est notre portail" = {
    #  href = "https://www.lesgrandsvoisins.com/";
    #  description = "Le site internet des GV.";
    #  icon = "https://www.lesgrandsvoisins.com/media/images/gv.original.svg";
    #       };
    #       }
    #       {
    #       "Blog.LesGrandsVoisisns.com pour les nouvelles" = {
    #  href = "https://blog.lesgrandsvoisins.com";
    #  icon = "https://blog.lesgrandsvoisins.com/ghost/assets/img/apple-touch-icon-74680e326a7e87b159d366c7d4fb3d4b.png";
    #  description = "Le blog des Grands Voisins.";
    #       };
    #       }
    #       {
    #       "Quartz.ResDigita.com pour la doc technique" = {
    #   href = "https://quartz.resdigita.com/";
    #   icon = "https://quartz.jzhao.xyz/static/icon.png";
    #   description = "Documentation de Resdigita des GV sur l'ensemble de nos services autonomes de par et pour les GV ";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Services GV unifiés en bêta" = [
    #       {
    #       "Vikunja gestionnaire des tâches à faire en équipe" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Services à accès ouverts en bêta" = [
    #       {
    #       "VaultWarden pour les maux des mots de passe compatible BitWarden" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #       {
    #       "EtherCalc pour un tableur collaboratif" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #       {
    #       "Crabfit pour trouver un moment de rendez-vous" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Comptes indépendants" = [
    #       {
    #       "Wagtail.resdigita.com pour la gestion du contenu des sites webs" = {
    #         href = "";
    #         description = "";            href = "";
    #         description = "";
    #         icon = "";
    #       {
    #       "Ghost pour la gestion du blog.lesgrandsvoisins.com" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #       {
    #       "ListMonk pour les listes de diffusion" = {
    #   href = "https://list.lesgrandsvoisins.com";
    #   description = "Le serveur de listes de diffusion des GV.";
    #   noticon = "https://listmonk.app/static/images/logo.svg";
    #   icon = "https://listmonk.app/static/images/favicon.png";
    #       };
    #       }
    #       {
    #       "Uptime-Kuma pour le statut des services" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Services GV unifiés en alpha" = [
    #       {
    #       "SilverBullet cahier à plusieurs" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #       {
    #       "FileBrowser casier numérique" = {
    #   href = "https://filebrowser.resdigita.com/files/";
    #   icon = "https://www.gitbook.com/cdn-cgi/image/width=36,dpr=2,height=36,fit=contain,format=auto/https%3A%2F%2F3149836655-files.gitbook.io%2F~%2Ffiles%2Fv0%2Fb%2Fgitbook-legacy-files%2Fo%2Fspaces%252F-M8KDxOujDoPpJyJJ5_i%252Favatar-1590579241040.png%3Fgeneration%3D1590579241552005%26alt%3Dmedia";
    #   description = "Un espace pour ses fichiers et pour les partager.";
    #       };
    #       }
    #       {
    #       "Radicale pour les calendriers partagés" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };widgets = [
    #     {
    #       logo = {
    #         icon = "https://www.lesgrandsvoisins.com/media/images/gv.original.svg";
    #       };
    #     }
    #     {
    #       greeting = {
    #         text_size = 1;
    #         text = "Homepage-Dashboard.resdigita.com. Ce tableau de bord fournit des liens vers toutes les ressources de ResDigita des GV.";
    #       };
    #     }
    #   ];
    #   services = [
    #     {
    #     "Services GV unifiés stables" = [
    #       {
    #       "Keycloak widgets = [
    #     {
    #       logo = {
    #         icon = "https://www.lesgrandsvoisins.com/media/images/gv.original.svg";
    #       };
    #     }
    #     {
    #       greeting = {
    #         text_size = 1;
    #         text = "Homepage-Dashboard.resdigita.com. Ce tableau de bord fournit des liens vers toutes les ressources de ResDigita des GV.";
    #       };
    #     }
    #   ];
    #   services = [
    #     {
    #     "Services GV unifiés stables" = [
    #       {
    #       "Keycloak pour la connexion unifiée" = {
    #   href = "https://keycloak.resdigita.com/realms/master/account";
    #   description = "Serveur de connexion et déconnexion unifiées (SSO en OAuth2) pour plusieurs services GV.";
    #   icon = "https://avatars.githubusercontent.com/u/4921466";
    #       };
    #       }
    #       {
    #       "HedgeDoc carnets collaboratifs en markdown" = {
    #   href = "https://hedgedoc.resdigita.com/auth/oauth2";
    #   icon = "https://hedgedoc.resdigita.com/icons/android-chrome-512x512.png";
    #   description = "Un serveur de documents en format Markdown pouvant être modifiés par plusieurs personnes en même temps. ";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Ressasie de login GV" = [
    #       {
    #       "Guichet du profil et du mot de passe" = {
    #   href = "https://guichet.resdigita.com/user";
    #   icon = "https://www.lesgrandsvoisins.com/media/images/gv.original.svg";
    #   description = "Depuis Guichet, vous pouvez ajouter et supprimer des boîtes-aux-lettres de courriel.";
    #       };
    #       }
    #       {
    #       "Roundcube Webmail" = {
    #   href = "https://mail.lesgrandsvoisins.com";
    #   description = "Consulter vos courriels des comptes des GV avec pour login le courriel du compte GV et le mot de passe de votre compte des GV.";
    #   icon = "https://mail.lesgrandsvoisins.com/skins/elastic/images/logo.svg?s=1";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Services à accès ouverts stables" = [
    #       {
    #       "BigBlueButton pour les réunions visio et formation" = {
    #   href = "https://meet.lesgrandsvoisins.com/";
    #   description = "Un espace de rencontres visio qui tient vraiement la route.";
    #   icon = "https://bigbluebutton.org/wp-content/uploads/2021/01/BigBlueButton_icon.svg.png ";
    #       };
    #       }
    #       {
    #       "Uptime-Kuma pour les statuts des sites essentiels" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Sites webs publics" = [
    #       {
    #       "LesGrandsVoisins.fr est notre portail" = {
    #  href = "https://www.lesgrandsvoisins.com/";
    #  description = "Le site internet des GV.";
    #  icon = "https://www.lesgrandsvoisins.com/media/images/gv.original.svg";
    #       };
    #       }
    #       {
    #       "Blog.LesGrandsVoisisns.com pour les nouvelles" = {
    #  href = "https://blog.lesgrandsvoisins.com";
    #  icon = "https://blog.lesgrandsvoisins.com/ghost/assets/img/apple-touch-icon-74680e326a7e87b159d366c7d4fb3d4b.png";
    #  description = "Le blog des Grands Voisins.";
    #       };
    #       }
    #       {
    #       "Quartz.ResDigita.com pour la doc technique" = {
    #   href = "https://quartz.resdigita.com/";
    #   icon = "https://quartz.jzhao.xyz/static/icon.png";
    #   description = "Documentation de Resdigita des GV sur l'ensemble de nos services autonomes de par et pour les GV ";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Services GV unifiés en bêta" = [
    #       {
    #       "Vikunja gestionnaire des tâches à faire en équipe" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Services à accès ouverts en bêta" = [
    #       {
    #       "VaultWarden pour les maux des mots de passe compatible BitWarden" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #       {
    #       "EtherCalc pour un tableur collaboratif" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }widgets = [
    #     {
    #       logo = {
    #         icon = "https://www.lesgrandsvoisins.com/media/images/gv.original.svg";
    #       };
    #     }
    #     {
    #       greeting = {
    #         text_size = 1;
    #         text = "Homepage-Dashboard.resdigita.com. Ce tableau de bord fournit des liens vers toutes les ressources de ResDigita des GV.";
    #       };
    #     }
    #   ];
    #   services = [
    #     {
    #     "Services GV unifiés stables" = [
    #       {
    #       "Keycloak pour la connexion unifiée" = {
    #   href = "https://keycloak.resdigita.com/realms/master/account";
    #   description = "Serveur de connexion et déconnexion unifiées (SSO en OAuth2) pour plusieurs services GV.";
    #   icon = "https://avatars.githubusercontent.com/u/4921466";
    #       };
    #       }
    #       {
    #       "HedgeDoc carnets collaboratifs en markdown" = {
    #   href = "https://hedgedoc.resdigita.com/auth/oauth2";
    #   icon = "https://hedgedoc.resdigita.com/icons/android-chrome-512x512.png";
    #   description = "Un serveur de documents en format Markdown pouvant être modifiés par plusieurs personnes en même temps. ";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Ressasie de login GV" = [
    #       {
    #       "Guichet du profil et du mot de passe" = {
    #   href = "https://guichet.resdigita.com/user";
    #   icon = "https://www.lesgrandsvoisins.com/media/images/gv.original.svg";
    #   description = "Depuis Guichet, vous pouvez ajouter et supprimer des boîtes-aux-lettres de courriel.";
    #       };
    #       }
    #       {
    #       "Roundcube Webmail" = {
    #   href = "https://mail.lesgrandsvoisins.com";
    #   description = "Consulter vos courriels des comptes des GV avec pour login le courriel du compte GV et le mot de passe de votre compte des GV.";
    #   icon = "https://mail.lesgrandsvoisins.com/skins/elastic/images/logo.svg?s=1";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Services à accès ouverts stables" = [
    #       {
    #       "BigBlueButton pour les réunions visio et formation" = {
    #   href = "https://meet.lesgrandsvoisins.com/";
    #   description = "Un espace de rencontres visio qui tient vraiement la route.";
    #   icon = "https://bigbluebutton.org/wp-content/uploads/2021/01/BigBlueButton_icon.svg.png ";
    #       };
    #       }
    #       {
    #       "Uptime-Kuma pour les statuts des sites essentiels" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Sites webs publics" = [
    #       {
    #       "LesGrandsVoisins.fr est notre portail" = {
    #  href = "https://www.lesgrandsvoisins.com/";
    #  description = "Le site internet des GV.";
    #  icon = "https://www.lesgrandsvoisins.com/media/images/gv.original.svg";
    #       };
    #       }
    #       {
    #       "Blog.LesGrandsVoisisns.com pour les nouvelles" = {
    #  href = "https://blog.lesgrandsvoisins.com";
    #  icon = "https://blog.lesgrandsvoisins.com/ghost/assets/img/apple-touch-icon-74680e326a7e87b159d366c7d4fb3d4b.png";
    #  description = "Le blog des Grands Voisins.";
    #       };
    #       }
    #       {
    #       "Quartz.ResDigita.com pour la doc technique" = {
    #   href = "https://quartz.resdigita.com/";
    #   icon = "https://quartz.jzhao.xyz/static/icon.png";
    #   description = "Documentation de Resdigita des GV sur l'ensemble de nos services autonomes de par et pour les GV ";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Services GV unifiés en bêta" = [
    #       {
    #       "Vikunja gestionnaire des tâches à faire en équipe" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Services à accès ouverts en bêta" = [
    #       {
    #       "VaultWarden pour les maux des mots de passe compatible BitWarden" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #       {
    #       "EtherCalc pour un tableur collaboratif" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #       {
    #       "Crabfit pour trouver un moment de rendez-vous" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Comptes indépendants" = [
    #       {
    #       "Wagtail.resdigita.com pour la gestion du contenu des sites webs" = {
    #         href = "";
    #         description = "";            href = "";
    #         description = "";
    #         icon = "";
    #       {
    #       "Ghost pour la gestion du blog.lesgrandsvoisins.com" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #       {
    #       "ListMonk pour les listes de diffusion" = {
    #   href = "https://list.lesgrandsvoisins.com";
    #   description = "Le serveur de listes de diffusion des GV.";
    #   noticon = "https://listmonk.app/static/images/logo.svg";
    #   icon = "https://listmonk.app/static/images/favicon.png";
    #       };
    #       }
    #       {widgets = [
    #     {
    #       logo = {
    #         icon = "https://www.lesgrandsvoisins.com/media/images/gv.original.svg";
    #       };
    #     }
    #     {
    #       greeting = {
    #         text_size = 1;
    #         text = "Homepage-Dashboard.resdigita.com. Ce tableau de bord fournit des liens vers toutes les ressources de ResDigita des GV.";
    #       };
    #     }
    #   ];
    #   services = [
    #     {
    #     "Services GV unifiés stables" = [
    #       {
    #       "Keycloak pour la connexion unifiée" = {
    #   href = "https://keycloak.resdigita.com/realms/master/account";
    #   description = "Serveur de connexion et déconnexion unifiées (SSO en OAuth2) pour plusieurs services GV.";
    #   icon = "https://avatars.githubusercontent.com/u/4921466";
    #       };
    #       }
    #       {
    #       "HedgeDoc carnets collaboratifs en markdown" = {
    #   href = "https://hedgedoc.resdigita.com/auth/oauth2";
    #   icon = "https://hedgedoc.resdigita.com/icons/android-chrome-512x512.png";
    #   description = "Un serveur de documents en format Markdown pouvant être modifiés par plusieurs personnes en même temps. ";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Ressasie de login GV" = [
    #       {
    #       "Guichet du profil et du mot de passe" = {
    #   href = "https://guichet.resdigita.com/user";
    #   icon = "https://www.lesgrandsvoisins.com/media/images/gv.original.svg";
    #   description = "Depuis Guichet, vous pouvez ajouter et supprimer des boîtes-aux-lettres de courriel.";
    #       };
    #       }
    #       {
    #       "Roundcube Webmail" = {
    #   href = "https://mail.lesgrandsvoisins.com";
    #   description = "Consulter vos courriels des comptes des GV avec pour login le courriel du compte GV et le mot de passe de votre compte des GV.";
    #   icon = "https://mail.lesgrandsvoisins.com/skins/elastic/images/logo.svg?s=1";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Services à accès ouverts stables" = [
    #       {
    #       "BigBlueButton pour les réunions visio et formation" = {
    #   href = "https://meet.lesgrandsvoisins.com/";
    #   description = "Un espace de rencontres visio qui tient vraiement la route.";
    #   icon = "https://bigbluebutton.org/wp-content/uploads/2021/01/BigBlueButton_icon.svg.png ";
    #       };
    #       }
    #       {
    #       "Uptime-Kuma pour les statuts des sites essentiels" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Sites webs publics" = [
    #       {
    #       "LesGrandsVoisins.fr est notre portail" = {
    #  href = "https://www.lesgrandsvoisins.com/";
    #  description = "Le site internet des GV.";
    #  icon = "https://www.lesgrandsvoisins.com/media/images/gv.original.svg";
    #       };
    #       }
    #       {
    #       "Blog.LesGrandsVoisisns.com pour les nouvelles" = {
    #  href = "https://blog.lesgrandsvoisins.com";
    #  icon = "https://blog.lesgrandsvoisins.com/ghost/assets/img/apple-touch-icon-74680e326a7e87b159d366c7d4fb3d4b.png";
    #  description = "Le blog des Grands Voisins.";
    #       };
    #       }
    #       {
    #       "Quartz.ResDigita.com pour la doc technique" = {
    #   href = "https://quartz.resdigita.com/";
    #   icon = "https://quartz.jzhao.xyz/static/icon.png";
    #   description = "Documentation de Resdigita des GV sur l'ensemble de nos services autonomes de par et pour les GV ";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Services GV unifiés en bêta" = [
    #       {
    #       "Vikunja gestionnaire des tâches à faire en équipe" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Services à accès ouverts en bêta" = [
    #       {
    #       "VaultWarden pour les maux des mots de passe compatible BitWarden" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #       {
    #       "EtherCalc pour un tableur collaboratif" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #       {
    #       "Crabfit pour trouver un moment de rendez-vous" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Comptes indépendants" = [
    #       {
    #       "Wagtail.resdigita.com pour la gestion du contenu des sites webs" = {
    #         href = "";
    #         description = "";            href = "";
    #         description = "";
    #         icon = "";
    #       {
    #       "Ghost pour la gestion du blog.lesgrandsvoisins.com" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #       {
    #       "ListMonk pour les listes de diffusion" = {
    #   href = "https://list.lesgrandsvoisins.com";
    #   description = "Le serveur de listes de diffusion des GV.";
    #   noticon = "https://listmonk.app/static/images/logo.svg";
    #   icon = "https://listmonk.app/static/images/favicon.png";
    #       };
    #       }
    #       {
    #       "Uptime-Kuma pour le statut des services" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };widgets = [
    #     {
    #       logo = {
    #         icon = "https://www.lesgrandsvoisins.com/media/images/gv.original.svg";
    #       };
    #     }
    #     {
    #       greeting = {
    #         text_size = 1;
    #         text = "Homepage-Dashboard.resdigita.com. Ce tableau de bord fournit des liens vers toutes les ressources de ResDigita des GV.";
    #       };
    #     }
    #   ];
    #   services = [
    #     {
    #     "Services GV unifiés stables" = [
    #       {
    #       "Keycloak pour la connexion unifiée" = {
    #   href = "https://keycloak.resdigita.com/realms/master/account";
    #   description = "Serveur de connexion et déconnexion unifiées (SSO en OAuth2) pour plusieurs services GV.";
    #   icon = "https://avatars.githubusercontent.com/u/4921466";
    #       };
    #       }
    #       {
    #       "HedgeDoc carnets collaboratifs en markdown" = {
    #   href = "https://hedgedoc.resdigita.com/auth/oauth2";
    #   icon = "https://hedgedoc.resdigita.com/icons/android-chrome-512x512.png";
    #   description = "Un serveur de documents en format Markdown pouvant être modifiés par plusieurs personnes en même temps. ";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Ressasie de login GV" = [
    #       {
    #       "Guichet du profil et du mot de passe" = {
    #   href = "https://guichet.resdigita.com/user";
    #   icon = "https://www.lesgrandsvoisins.com/media/images/gv.original.svg";
    #   description = "Depuis Guichet, vous pouvez ajouter et supprimer des boîtes-aux-lettres de courriel.";
    #       };
    #       }
    #       {
    #       "Roundcube Webmail" = {
    #   href = "https://mail.lesgrandsvoisins.com";
    #   description = "Consulter vos courriels des comptes des GV avec pour login le courriel du compte GV et le mot de passe de votre compte des GV.";
    #   icon = "https://mail.lesgrandsvoisins.com/skins/elastic/images/logo.svg?s=1";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Services à accès ouverts stables" = [
    #       {
    #       "BigBlueButton pour les réunions visio et formation" = {
    #   href = "https://meet.lesgrandsvoisins.com/";
    #   description = "Un espace de rencontres visio qui tient vraiement la route.";
    #   icon = "https://bigbluebutton.org/wp-content/uploads/2021/01/BigBlueButton_icon.svg.png ";
    #       };
    #       }
    #       {
    #       "Uptime-Kuma pour les statuts des sites essentiels" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Sites webs publics" = [
    #       {
    #       "LesGrandsVoisins.fr est notre portail" = {
    #  href = "https://www.lesgrandsvoisins.com/";
    #  description = "Le site internet des GV.";
    #  icon = "https://www.lesgrandsvoisins.com/media/images/gv.original.svg";
    #       };
    #       }
    #       {
    #       "Blog.LesGrandsVoisisns.com pour les nouvelles" = {
    #  href = "https://blog.lesgrandsvoisins.com";
    #  icon = "https://blog.lesgrandsvoisins.com/ghost/assets/img/apple-touch-icon-74680e326a7e87b159d366c7d4fb3d4b.png";
    #  description = "Le blog des Grands Voisins.";
    #       };
    #       }
    #       {
    #       "Quartz.ResDigita.com pour la doc technique" = {
    #   href = "https://quartz.resdigita.com/";
    #   icon = "https://quartz.jzhao.xyz/static/icon.png";
    #   description = "Documentation de Resdigita des GV sur l'ensemble de nos services autonomes de par et pour les GV ";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Services GV unifiés en bêta" = [
    #       {
    #       "Vikunja gestionnaire des tâches à faire en équipe" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Services à accès ouverts en bêta" = [
    #       {
    #       "VaultWarden pour les maux des mots de passe compatible BitWarden" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #       {
    #       "EtherCalc pour un tableur collaboratif" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #       {
    #       "Crabfit pour trouver un moment de rendez-vous" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Comptes indépendants" = [
    #       {
    #       "Wagtail.resdigita.com pour la gestion du contenu des sites webs" = {
    #         href = "";
    #         description = "";            href = "";
    #         description = "";
    #         icon = "";
    #       {
    #       "Ghost pour la gestion du blog.lesgrandsvoisins.com" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #       {
    #       "ListMonk pour les listes de diffusion" = {
    #   href = "https://list.lesgrandsvoisins.com";
    #   description = "Le serveur de listes de diffusion des GV.";
    #   noticon = "https://listmonk.app/static/images/logo.svg";
    #   icon = "https://listmonk.app/static/images/favicon.png";
    #       };
    #       }
    #       {
    #       "Uptime-Kuma pour le statut des services" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Services GV unifiés en alpha" = [
    #       {
    #       "SilverBullet cahier à plusieurs" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #       {
    #       "FileBrowser casier numérique" = {
    #   href = "https://filebrowser.resdigita.com/files/";
    #   icon = "https://www.gitbook.com/cdn-cgi/image/width=36,dpr=2,height=36,fit=contain,format=auto/https%3A%2F%2F3149836655-files.gitbook.io%2F~%2Ffiles%2Fv0%2Fb%2Fgitbook-legacy-files%2Fo%2Fspaces%252F-M8KDxOujDoPpJyJJ5_i%252Favatar-1590579241040.png%3Fgeneration%3D1590579241552005%26alt%3Dmedia";
    #   description = "Un espace pour ses fichiers et pour les partager.";
    #       };
    #       }
    #       {
    #       "Radicale pour les calendriers partagés" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #       {
    #       "Xandikos pour un calendrier public partagé" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Services GV unifiés dépréciés" = [
    #       {
    #       "KeeWeb pour la gestion des mots de passe" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #   ];
    #       }
    #     ];
    #     }
    #     {
    #     "Services GV unifiés en alpha" = [
    #       {
    #       "SilverBullet cahier à plusieurs" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #       {
    #       "FileBrowser casier numérique" = {
    #   href = "https://filebrowser.resdigita.com/files/";
    #   icon = "https://www.gitbook.com/cdn-cgi/image/width=36,dpr=2,height=36,fit=contain,format=auto/https%3A%2F%2F3149836655-files.gitbook.io%2F~%2Ffiles%2Fv0%2Fb%2Fgitbook-legacy-files%2Fo%2Fspaces%252F-M8KDxOujDoPpJyJJ5_i%252Favatar-1590579241040.png%3Fgeneration%3D1590579241552005%26alt%3Dmedia";
    #   description = "Un espace pour ses fichiers et pour les partager.";
    #       };
    #       }
    #       {
    #       "Radicale pour les calendriers partagés" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #       {
    #       "Xandikos pour un calendrier public partagé" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Services GV unifiés dépréciés" = [
    #       {
    #       "KeeWeb pour la gestion des mots de passe" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #   ];
    #       "Uptime-Kuma pour le statut des services" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Services GV unifiés en alpha" = [
    #       {
    #       "SilverBullet cahier à plusieurs" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #       {
    #       "FileBrowser casier numérique" = {
    #   href = "https://filebrowser.resdigita.com/files/";
    #   icon = "https://www.gitbook.com/cdn-cgi/image/width=36,dpr=2,height=36,fit=contain,format=auto/https%3A%2F%2F3149836655-files.gitbook.io%2F~%2Ffiles%2Fv0%2Fb%2Fgitbook-legacy-files%2Fo%2Fspaces%252F-M8KDxOujDoPpJyJJ5_i%252Favatar-1590579241040.png%3Fgeneration%3D1590579241552005%26alt%3Dmedia";
    #   description = "Un espace pour ses fichiers et pour les partager.";
    #       };
    #       }
    #       {
    #       "Radicale pour les calendriers partagés" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #       {
    #       "Xandikos pour un calendrier public partagé" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Services GV unifiés dépréciés" = [
    #       {
    #       "KeeWeb pour la gestion des mots de passe" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #   ];
    #       {
    #       "Crabfit pour trouver un moment de rendez-vous" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Comptes indépendants" = [
    #       {
    #       "Wagtail.resdigita.com pour la gestion du contenu des sites webs" = {
    #         href = "";
    #         description = "";            href = "";
    #         description = "";
    #         icon = "";
    #       {
    #       "Ghost pour la gestion du blog.lesgrandsvoisins.com" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #       {
    #       "ListMonk pour les listes de diffusion" = {
    #   href = "https://list.lesgrandsvoisins.com";
    #   description = "Le serveur de listes de diffusion des GV.";
    #   noticon = "https://listmonk.app/static/images/logo.svg";
    #   icon = "https://listmonk.app/static/images/favicon.png";
    #       };
    #       }
    #       {
    #       "Uptime-Kuma pour le statut des services" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Services GV unifiés en alpha" = [
    #       {
    #       "SilverBullet cahier à plusieurs" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #       {
    #       "FileBrowser casier numérique" = {
    #   href = "https://filebrowser.resdigita.com/files/";
    #   icon = "https://www.gitbook.com/cdn-cgi/image/width=36,dpr=2,height=36,fit=contain,format=auto/https%3A%2F%2F3149836655-files.gitbook.io%2F~%2Ffiles%2Fv0%2Fb%2Fgitbook-legacy-files%2Fo%2Fspaces%252F-M8KDxOujDoPpJyJJ5_i%252Favatar-1590579241040.png%3Fgeneration%3D1590579241552005%26alt%3Dmedia";
    #   description = "Un espace pour ses fichiers et pour les partager.";
    #       };
    #       }
    #       {
    #       "Radicale pour les calendriers partagés" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #       {
    #       "Xandikos pour un calendrier public partagé" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Services GV unifiés dépréciés" = [
    #       {
    #       "KeeWeb pour la gestion des mots de passe" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #   ];pour la connexion unifiée" = {
    #   href = "https://keycloak.resdigita.com/realms/master/account";
    #   description = "Serveur de connexion et déconnexion unifiées (SSO en OAuth2) pour plusieurs services GV.";
    #   icon = "https://avatars.githubusercontent.com/u/4921466";
    #       };
    #       }
    #       {
    #       "HedgeDoc carnets collaboratifs en markdown" = {
    #   href = "https://hedgedoc.resdigita.com/auth/oauth2";
    #   icon = "https://hedgedoc.resdigita.com/icons/android-chrome-512x512.png";
    #   description = "Un serveur de documents en format Markdown pouvant être modifiés par plusieurs personnes en même temps. ";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Ressasie de login GV" = [
    #       {
    #       "Guichet du profil et du mot de passe" = {
    #   href = "https://guichet.resdigita.com/user";
    #   icon = "https://www.lesgrandsvoisins.com/media/images/gv.original.svg";
    #   description = "Depuis Guichet, vous pouvez ajouter et supprimer des boîtes-aux-lettres de courriel.";
    #       };
    #       }
    #       {
    #       "Roundcube Webmail" = {
    #   href = "https://mail.lesgrandsvoisins.com";
    #   description = "Consulter vos courriels des comptes des GV avec pour login le courriel du compte GV et le mot de passe de votre compte des GV.";
    #   icon = "https://mail.lesgrandsvoisins.com/skins/elastic/images/logo.svg?s=1";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Services à accès ouverts stables" = [
    #       {
    #       "BigBlueButton pour les réunions visio et formation" = {
    #   href = "https://meet.lesgrandsvoisins.com/";
    #   description = "Un espace de rencontres visio qui tient vraiement la route.";
    #   icon = "https://bigbluebutton.org/wp-content/uploads/2021/01/BigBlueButton_icon.svg.png ";
    #       };
    #       }
    #       {
    #       "Uptime-Kuma pour les statuts des sites essentiels" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Sites webs publics" = [
    #       {
    #       "LesGrandsVoisins.fr est notre portail" = {
    #  href = "https://www.lesgrandsvoisins.com/";
    #  description = "Le site internet des GV.";
    #  icon = "https://www.lesgrandsvoisins.com/media/images/gv.original.svg";
    #       };
    #       }
    #       {
    #       "Blog.LesGrandsVoisisns.com pour les nouvelles" = {
    #  href = "https://blog.lesgrandsvoisins.com";
    #  icon = "https://blog.lesgrandsvoisins.com/ghost/assets/img/apple-touch-icon-74680e326a7e87b159d366c7d4fb3d4b.png";
    #  description = "Le blog des Grands Voisins.";
    #       };
    #       }
    #       {
    #       "Quartz.ResDigita.com pour la doc technique" = {
    #   href = "https://quartz.resdigita.com/";
    #   icon = "https://quartz.jzhao.xyz/static/icon.png";
    #   description = "Documentation de Resdigita des GV sur l'ensemble de nos services autonomes de par et pour les GV ";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Services GV unifiés en bêta" = [
    #       {
    #       "Vikunja gestionnaire des tâches à faire en équipe" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Services à accès ouverts en bêta" = [
    #       {
    #       "VaultWarden pour les maux des mots de passe compatible BitWarden" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #       {
    #       "EtherCalc pour un tableur collaboratif" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #       {
    #       "Crabfit pour trouver un moment de rendez-vous" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Comptes indépendants" = [
    #       {
    #       "Wagtail.resdigita.com pour la gestion du contenu des sites webs" = {
    #         href = "";
    #         description = "";            href = "";
    #         description = "";
    #         icon = "";
    #       {
    #       "Ghost pour la gestion du blog.lesgrandsvoisins.com" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #       {
    #       "ListMonk pour les listes de diffusion" = {
    #   href = "https://list.lesgrandsvoisins.com";
    #   description = "Le serveur de listes de diffusion des GV.";
    #   noticon = "https://listmonk.app/static/images/logo.svg";
    #   icon = "https://listmonk.app/static/images/favicon.png";
    #       };
    #       }
    #       {
    #       "Uptime-Kuma pour le statut des services" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Services GV unifiés en alpha" = [
    #       {
    #       "SilverBullet cahier à plusieurs" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #       {
    #       "FileBrowser casier numérique" = {
    #   href = "https://filebrowser.resdigita.com/files/";
    #   icon = "https://www.gitbook.com/cdn-cgi/image/width=36,dpr=2,height=36,fit=contain,format=auto/https%3A%2F%2F3149836655-files.gitbook.io%2F~%2Ffiles%2Fv0%2Fb%2Fgitbook-legacy-files%2Fo%2Fspaces%252F-M8KDxOujDoPpJyJJ5_i%252Favatar-1590579241040.png%3Fgeneration%3D1590579241552005%26alt%3Dmedia";
    #   description = "Un espace pour ses fichiers et pour les partager.";
    #       };
    #       }
    #       {
    #       "Radicale pour les calendriers partagés" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #       {
    #       "Xandikos pour un calendrier public partagé" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Services GV unifiés dépréciés" = [
    #       {
    #       "KeeWeb pour la gestion des mots de passe" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #   ];
    #       }
    #       {
    #       "Xandikos pour un calendrier public partagé" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Services GV unifiés dépréciés" = [
    #       {
    #       "KeeWeb pour la gestion des mots de passe" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #   ];s://www.gitbook.com/cdn-cgi/image/width=36,dpr=2,height=36,fit=contain,format=auto/https%3A%2F%2F3149836655-files.gitbook.io%2F~%2Ffiles%2Fv0%2Fb%2Fgitbook-legacy-files%2Fo%2Fspaces%252F-M8KDxOujDoPpJyJJ5_i%252Favatar-1590579241040.png%3Fgeneration%3D1590579241552005%26alt%3Dmedia";
    #   description = "Un espace pour ses fichiers et pour les partager.";
    #       };
    #       }
    #       {
    #       "Radicale pour les calendriers partagés" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #       {
    #       "Xandikos pour un calendrier public partagé" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #     {
    #     "Services GV unifiés dépréciés" = [
    #       {
    #       "KeeWeb pour la gestion des mots de passe" = {
    #         href = "";
    #         description = "";
    #         icon = "";
    #       };
    #       }
    #     ];
    #     }
    #   ];
    };
    openssh = {
      enable = true;
      settings.PermitRootLogin = "prohibit-password";
    };
    # keycloak = {
    #   enable = true;
    #   settings = {
    #     https-port = 10443;
    #     http-port = 10080;
    #     # proxy = "passthrough";
    #     proxy = "reencrypt";
    #     hostname = "keycloak.resdigita.com";
    #   };
    #   sslCertificate = "/var/lib/acme/keycloak.resdigita.com/fullchain.pem";
    #   sslCertificateKey = "/var/lib/acme/keycloak.resdigita.com/key.pem";
    #   database.passwordFile = "/etc/nixos/.secret.keycloakdata";
    #   # themes = {lesgv = (pkgs.callPackage "/etc/nixos/keycloaktheme/derivation.nix" {});};
    # };
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
  virtualisation.libvirtd.enable = true;
  # programs.virt-manager.enable = true;
  # dconf.settings = {
  #   "org/virt-manager/virt-manager/connections" = {
  #     autoconnect = ["qemu:///system"];
  #     uris = ["qemu:///system"];
  #   };
  # };
  

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

