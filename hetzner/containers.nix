{ config, pkgs, lib, ... }:
let
  # seafilePassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.seafile));
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz";
  my-python-packages = ps: with ps; [
    bleach
    cffi
    chardet
    django
    django-formtools
    django-picklefield
    django-simple-captcha
    django-statici18n
    django-webpack-loader
    djangorestframework
    future
    gunicorn
    markdown
    mysqlclient
    mysqlclient
    openpyxl
    pillow
    pip
    pycryptodome
    pyjwt
    pysaml2
    python-dateutil
    python-ldap
    qrcode
    requests
    requests-oauthlib
    setuptools
    simplejson
    python3-gnutls
  ];
  mannchriRsaPublic = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAuBWybYSoR6wyd1EG5YnHPaMKE3RQufrK7ycej7avw3Ug8w8Ppx2BgRGNR6EamJUPnHEHfN7ZZCKbrAnuP3ar8mKD7wqB2MxVqhSWvElkwwurlijgKiegYcdDXP0JjypzC7M73Cus3sZT+LgiUp97d6p3fYYOIG7cx19TEKfNzr1zHPeTYPAt5a1Kkb663gCWEfSNuRjD2OKwueeNebbNN/OzFSZMzjT7wBbxLb33QnpW05nXlLhwpfmZ/CVDNCsjVD1+NXWWmQtpRCzETL6uOgirhbXYW8UyihsnvNX8acMSYTT9AA3jpJRrUEMum2VizCkKh7bz87x7gsdA4wF0/w== rsa-key-20220407";
  home-manager2305 = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz";
  hasaeraRsaPublic = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAuBWybYSoR6wyd1EG5YnHPaMKE3RQufrK7ycej7avw3Ug8w8Ppx2BgRGNR6EamJUPnHEHfN7ZZCKbrAnuP3ar8mKD7wqB2MxVqhSWvElkwwurlijgKiegYcdDXP0JjypzC7M73Cus3sZT+LgiUp97d6p3fYYOIG7cx19TEKfNzr1zHPeTYPAt5a1Kkb663gCWEfSNuRjD2OKwueeNebbNN/OzFSZMzjT7wBbxLb33QnpW05nXlLhwpfmZ/CVDNCsjVD1+NXWWmQtpRCzETL6uOgirhbXYW8UyihsnvNX8acMSYTT9AA3jpJRrUEMum2VizCkKh7bz87x7gsdA4wF0/w== rsa-key-20220407";
  ldapDomainName = "ldap.gv.coop";
  lgvLdapDomainName = "ldap.lesgrandsvoisins.com";
  ldapBaseDN = "dc=gv,dc=coop";
  lgvLdapBaseDN = "dc=lesgrandsvoisins,dc=com";
  bindPassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.bind));
  alicePassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.alice));
  bobPassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.bob));
  sogoPassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.sogo));
  oauthPassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.oauthpassword));
  # domainName = "mail.gv.coop";
  domainName = "mail.lesgrandsvoisins.com";
  whitelistSubnets =  [ 
      "10.0.0.0/8" 
      "172.16.0.0/12" 
      "192.168.0.0/16"
      "8.8.8.8" # Resolves the IP via DNS
      "mail.gv.coop" 
      "mail.lesgrandsvoisins.com"
  ];
  mailServerDomainAliases = [ 
    "lesgrandsvoisins.com"
  ];
in
{
  networking = {
    nat = {
      enable = true;
      internalInterfaces = ["ve-+"];
      externalInterface = "eno1";
      # Lazy IPv6 connectivity for the container
      enableIPv6 = true;
    };
  };
  # networking.interfaces.vlan2 = {
  #   virtual = true;
  #   ipv4.addresses = [
	#     { address="192.168.102.1"; prefixLength=24; } 
  #   ];
  #   ipv6.addresses = [
  #     { address="fc00::2:1"; prefixLength=112; } 
  #   ];
  # };
  # containers.sftpgo = {
  #   autoStart = true;
  #   privateNetwork = true;
  #   hostAddress = "192.168.108.1";
  #   localAddress = "192.168.108.2";
  #   hostAddress6 = "fc00::4:1";
  #   localAddress6 = "fc00::4:2"; 
  #   # bindMounts = {
  #   #   "/var/lib/acme/sftpgo.lesgrandsvoisins.com/" = {
  #   #     hostPath = "/var/lib/acme/wordpress.resdigita.com/";
  #   #     isReadOnly = true;
  #   #   }; 
  #   #   "/var/www/dav/data/" = {
  #   #     hostPath = "//var/www/dav/data/";
  #   #     isReadOnly = false;
  #   #   }; 
  #   #   "/var/run/sftpgo/" = {
  #   #     hostPath = "/var/run/sftpgo/";
  #   #     isReadOnly = false;
  #   #   }; 
  #   # };
  #   config = { config, pkgs, lib, ... }: {
  #     nix.settings.experimental-features = "nix-command flakes";
  #     # imports = [ (import "${home-manager}/nixos") ];
  #     environment.systemPackages = with pkgs; [
  #       ((vim_configurable.override {  }).customize{
  #         name = "vim";
  #         vimrcConfig.customRC = ''
  #           " your custom vimrc
  #           set mouse=a
  #           set nocompatible
  #           colo torte
  #           syntax on
  #           set tabstop     =2
  #           set softtabstop =2
  #           set shiftwidth  =2
  #           set expandtab
  #           set autoindent
  #           set smartindent
  #           " ...
  #         '';
  #         }
  #       )
  #     ];
  #     # users = {
  #     #   users = {
  #     #     sftpgo = {
  #     #       uid = 1020;
  #     #       group = "sftpgo";
  #     #     };
  #     #   };
  #     #   groups = {
  #     #     sftpgo = {
  #     #       gid = 979;
  #     #       name = "sftpgo";
  #     #     };
  #     #     wwwrun = {
  #     #       gid = 54;
  #     #       members = ["wwwrun"];
  #     #     };
  #     #   };
  #     # };
  #     nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
  #       "sftpgo"
  #     ];
  #     networking = {
  #       hostName = "sftpgo"; 
  #       firewall.allowedTCPPorts = [ 22 25 80 443 143 587 993 995 636 ];
  #       useHostResolvConf = lib.mkForce false;
  #     };
  #     system = {
  #       # copySystemConfiguration = true;
  #       stateVersion = "24.05";
  #     };
  #     time.timeZone = "Europe/Paris";
  #     i18n.defaultLocale = "fr_FR.UTF-8";  
  #     environment.sessionVariables = rec {
  #       EDITOR="vim";
  #     };
  #     services = {
  #       resolved.enable = true;
  #       openssh = {
  #         enable = true;
  #         settings.PermitRootLogin = "prohibit-password";
  #       };
  #       sftpgo = {
  #         enable = true;
  #         user = "sftpgo";  
  #         group = "wwwrun";
  #         dataDir = "/var/www/dav/data";
  #         extraArgs = [
  #             "--log-level"
  #             "info"
  #           ];
  #         settings = {
  #           proxy_protocol = 0;
  #           webdavd.bindings = [
  #             {
  #               port = 80;
  #               address = "192.168.108.2";
  #               # certificate_file = "/var/lib/acme/sftpgo.lesgrandsvoisins.com/full.pem";
  #               # certificate_key_file = "/var/lib/acme/sftpgo.lesgrandsvoisins.com/key.pem";
  #               # enable_https = true;
  #             }
  #             {
  #               port = 80;
  #               address = "[fc00::4:2]";
  #               # certificate_file = "/var/lib/acme/sftpgo.lesgrandsvoisins.com/full.pem";
  #               # certificate_key_file = "/var/lib/acme/sftpgo.lesgrandsvoisins.com/key.pem";
  #               # enable_https = true;
  #             }
  #           ];
  #           sftpd.bindings = [
  #             {
  #               port = 2022;
  #               address = "192.168.108.2";
  #             }
  #             {
  #               port = 2022;
  #               address = "[fc00::4:2]";
  #             }
  #           ];
  #           httpd = {
  #             static_files_path = "/var/run/sftpgo/static";
  #             templates_path = "/var/run/sftpgo/templates";
  #             bindings = [
  #             {
  #               port = 80;
  #               address = "192.168.108.2";
  #               # certificate_file = "/var/lib/acme/sftpgo.lesgrandsvoisins.com/full.pem";
  #               # certificate_key_file = "/var/lib/acme/sftpgo.lesgrandsvoisins.com/key.pem";
  #               # enable_https = true;
                

  #               # oidc = {
  #               #   config_url = "https://key.lesgrandsvoisins.com/realms/master";
  #               #   client_id = "sftpgo";
  #               #   client_secret = keySftpgo;
  #               #   username_field = "username";
  #               #   redirect_base_url = "https://sftpgo.lesgrandsvoisins.com:10443";
  #               #   scopes = [
  #               #     "openid"
  #               #     "profile"
  #               #     "email"        
  #               #   ];
  #               #   implicit_roles = true;
  #               # };
  #               branding = {
  #                 web_admin = {
  #                   name = "sftpgo.lesgrandsovisins.com : Accès Administrateur au Drive des Grands Voisins";
  #                   short_name = "ADMIN du Drive des Grands Voisins";
  #                 };
  #                 web_client = {
  #                   name = "sftpgo.lesgrandsovisins.com : Accès au Drive des Grands Voisins";
  #                   short_name = "Drive des Grands Voisins";
  #                 };
  #               };
  #             }
  #             {
  #               port = 80;
  #               address = "[fc00::4:2]";
  #               # certificate_file = "/var/lib/acme/sftpgo.lesgrandsvoisins.com/full.pem";
  #               # certificate_key_file = "/var/lib/acme/sftpgo.lesgrandsvoisins.com/key.pem";
  #               # enable_https = true;
  #               # oidc = {
  #               #   config_url = "https://key.lesgrandsvoisins.com/realms/master";
  #               #   client_id = "sftpgo";
  #               #   client_secret = keySftpgo;
  #               #   redirect_base_url = "https://sftpgo.lesgrandsvoisins.com:10443";
  #               #   username_field = "username";
  #               #   scopes = [
  #               #     "openid"
  #               #     "profile"
  #               #     "email"
  #               #   ];
  #               #   implicit_roles = true;
  #               # };
  #               branding = {
  #                 web_admin = {
  #                   name = "sftpgo.lesgrandsovisins.com : Accès Administrateur au Drive des Grands Voisins";
  #                   short_name = "ADMIN du Drive des Grands Voisins";
  #                 };
  #                 web_client = {
  #                   name = "sftpgo.lesgrandsovisins.com : Accès au Drive des Grands Voisins";
  #                   short_name = "Drive des Grands Voisins";
  #                 };
  #               };
  #             }
  #           ];
  #           };
  #           plugins = [{
  #             type = "auth";
  #             cmd = "/run/current-system/sw/bin/sftpgo-plugin-auth";
  #             args = ["serve"
  #               "--config-file"
  #               "/var/run/sftpgo/sftpgo-plugin-auth.json"
  #             ];
  #             auth_options.scope = 5;
  #             auto_mtls = true;
  #           }];
  #         };  
  #       };
  #     };
  #   };
  # };
  containers.wordpress = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.103.1";
    localAddress = "192.168.103.2";
    hostAddress6 = "fc00::3:1";
    localAddress6 = "fc00::3:2"; 
    bindMounts = {
      "/var/lib/acme/wordpress.resdigita.com/" = {
        hostPath = "/var/lib/acme/wordpress.resdigita.com/";
        isReadOnly = true;
      }; 
    };
    config = { config, pkgs, lib, ... }: {
      imports = [ (import "${home-manager}/nixos") ];
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
        cowsay
        home-manager
        curl
        wget
        lynx
        git
        tmux
        bat
        python311Packages.pillow
        python311Packages.pylibjpeg-libjpeg
        zlib
        lzlib
        dig
        killall
        pwgen
        openldap
        mysql80
        python311Packages.pypdf2
        python311Packages.python-ldap
        python311Packages.pq
        python311Packages.aiosasl
        python311Packages.psycopg2
        mariadb
        (pkgs.php82.buildEnv {
          extensions = ({ enabled, all }: enabled ++ (with all; [
            imagick
          ]));
          extraConfig = ''
          '';
        })
        php82Extensions.imagick
      ];
      networking = {
        hostName = "wordpress"; 
        firewall.allowedTCPPorts = [ 22 25 80 443 143 587 993 995 636 ];
        useHostResolvConf = lib.mkForce false;
      };
      system = {
        copySystemConfiguration = true;
        stateVersion = "24.05";
      };
      environment.sessionVariables = rec {
        EDITOR="vim";
        WAGTAIL_ENV = "production";
      };
      security.acme = {
        acceptTerms = true;
        defaults.email = "contact@lesgrandsvoisins.com";
        defaults.webroot = "/var/www";
      };
      # ## Adding Linux Containers
      # virtualisation = {
      #   lxd.enable = true;
      #   lxc.enable = true;
      #   lxc.lxcfs.enable = true;
      # };
      time.timeZone = "Europe/Paris";
      i18n.defaultLocale = "fr_FR.UTF-8";
      users.users.mannchri = {
        isNormalUser = true;
        openssh.authorizedKeys.keys = [ mannchriRsaPublic ];
        extraGroups = [ "wheel" ];
      };
      users.users.hasaera = {
        isNormalUser = true;
        openssh.authorizedKeys.keys = [ hasaeraRsaPublic ];
        extraGroups = [ "wheel" ];
      };
      home-manager.users.mannchri = {pkgs, ...}: {
        home.packages = [ pkgs.atool pkgs.httpie ];
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
      home-manager.users.hasaera = {pkgs, ...}: {
        home.packages = [ pkgs.atool pkgs.httpie ];
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
      services = {
        resolved.enable = true;
        openssh = {
          enable = true;
          settings.PermitRootLogin = "prohibit-password";
        };
        httpd = {
          enable = true; 
          enablePHP = true;
          phpPackage = pkgs.php.buildEnv {
            extensions = ({ enabled, all }: enabled ++ (with all; [
                imagick
            ]));
            extraConfig = ''
            '';
          };
          phpOptions = ''
            upload_max_filesize = 128M
            post_max_size = 256M
            max_execution_time = 300
          '';
          virtualHosts."wordpress.resdigita.com" = {
            serverAliases = [
              "ghh.resdigita.com"
              "*"
            ];
            listen = [{port = 443; ssl=true;}];
            sslServerCert = "/var/lib/acme/wordpress.resdigita.com/fullchain.pem";
            sslServerChain = "/var/lib/acme/wordpress.resdigita.com/fullchain.pem";
            sslServerKey = "/var/lib/acme/wordpress.resdigita.com/key.pem";
            # enableACME = true;
            # forceSSL = true;
            documentRoot = "/var/www/ghh";
            extraConfig = ''
              <Directory /var/www/ghh>
                DirectoryIndex index.php
                Require all granted
                AllowOverride FileInfo
                FallbackResource /index.php
              </Directory>
              '';
          };
        };
        mysql = {
          package = pkgs.mariadb;
          enable = true;
        };
      };
    };
  };
  containers.silverbullet = {
    autoStart = true;
    privateNetwork = true;
    # macvlans = ["vlan2"];
    # hostBridge = "br2";
    hostAddress = "192.168.102.1";
    localAddress = "192.168.102.2";
    hostAddress6 = "fc00::2:1";
    localAddress6 = "fc00::2:2";
    bindMounts = {
      "/var/lib/silverbullet/back" = {
        hostPath = "/var/lib/silverbullet/back";
        isReadOnly = false;
      }; 
      # "/var/lib/burp/etc/silverbullet.resdigita.com" = {
      #   hostPath = "/var/lib/acme/silverbullet.resdigita.com";
      #   isReadOnly = true;
      # }; 
    };
    config = { config, pkgs, ... }: {
      nix.settings.experimental-features = "nix-command flakes";
      time.timeZone = "Europe/Amsterdam";
      system.stateVersion = "24.05";
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
        python311
        busybox
        curl
        wget
        lynx
        dig    
        git
        tmux
        killall
        pwgen
        gettext
        home-manager
        # burp
        # backintime
        # deno
        kopia
      ];
      networking = {
        firewall.allowedTCPPorts = [ 3000 4971 4972 22 25 80 443 143 587 993 995 636 8443 9443 ];
        # useHostResolvConf = true;
        useHostResolvConf = lib.mkForce false;
        # nameservers = ["8.8.8.8" "8.8.4.4" "2001:4860:4860::8888" "2001:4860:4860::8844"];
        # nameservers = ["8.8.8.8" "8.8.4.4"];
      };
      users.users = {
        mannchri.isNormalUser = true;
        silverbullet.isNormalUser = true;
      };
      imports = [
         (import "${home-manager}/nixos")
      ];
      home-manager.users.silverbullet = {pkgs, ...}: {
        home.packages = with pkgs; [ 
          deno
        ];
        home.stateVersion = "24.05";
        programs.home-manager.enable = true;
      };
      services = {
        resolved.enable = true;
        # bourgbackup = {
        #   enable = true;
        #   jobs = {
        #      paths = "/home/silverbullet/quartz/";
        #      exclude = [ "/home/silverbullet/quartz/.git" ];
        #      repo = "/mnt/host/silverbullet";
        #      startAt = "daily";
        #   };
        # };
      };
      systemd = {
        timers.kopia = {
          description = "Kopia backup schedule";
          timerConfig = {
            Unit = "kopia.service";
            OnUnitActiveSec = "1h";
            OnBootSec = "15min";
          };
          wantedBy = ["timers.target"];
        };
        services = {
          kopia = {
            description = "Kopia Snapshot of Silverbullet";
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
              WorkingDirectory = "/home/silverbullet/quartz/";
              Environment = "PATH=/run/wrappers/bin:/home/silverbullet/.nix-profile/bin:/nix/profile/bin:/home/silverbullet/.local/state/nix/profile/bin:/etc/profiles/per-user/silverbullet/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin;";
              Restart = "no";
              User = "silverbullet";
              Group = "users";
            };
            script = ''
              /run/current-system/sw/bin/kopia repository connect from-config --token ${(lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.kopia.silverbullet))}
              /run/current-system/sw/bin/kopia snapshot create /home/silverbullet/quartz/
              return 0
            '';
          };
          silverbullet = {
            description = "SilverBullet.Resdigita.com";
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
              WorkingDirectory = "/home/silverbullet/.nix-profile/bin/";
              Environment = "PATH=/home/silverbullet/.deno/bin:/run/wrappers/bin:/home/silverbullet/.nix-profile/bin:/nix/profile/bin:/home/silverbullet/.local/state/nix/profile/bin:/etc/profiles/per-user/silverbullet/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin;";
              ExecStart = ''/home/silverbullet/.deno/bin/silverbullet -L 192.168.102.2 /home/silverbullet/quartz/'';
              Restart = "always";
              RestartSec = "10s";
              User = "silverbullet";
              Group = "users";
            };
            unitConfig = {
              StartLimitInterval = "1min";
            };
          };
        };
      };
    };
  };
  containers.wagtail = {
    autoStart = true;
    # privateNetwork = true;
    # hostBridge = "br0";
    # hostAddress = "192.168.100.10";
    # localAddress = "192.168.100.11";
    # hostAddress6 = "fc00::1";
    # localAddress6 = "fc00::2";

    bindMounts = { 
      "/var/www/wagtail" = { 
        hostPath = "/var/www/wagtail";
        isReadOnly = false; 
       }; 
       "/home/wagtail/francemali/medias" = { 
        hostPath = "/var/www/francemali/medias";
        isReadOnly = false; 
       }; 
      "/home/wagtail/francemali/staticfiles" = { 
        hostPath = "/var/www/francemali/static";
        isReadOnly = false; 
       }; 
       "/home/wagtail/cantine/medias" = { 
        hostPath = "/var/www/cantine/medias";
        isReadOnly = false; 
       }; 
      "/home/wagtail/cantine/staticfiles" = { 
        hostPath = "/var/www/cantine/static";
        isReadOnly = false; 
       }; 
       "/home/wagtail/web-fastoche/medias" = { 
        hostPath = "/var/www/web-fastoche/medias";
        isReadOnly = false; 
       }; 
      "/home/wagtail/web-fastoche/staticfiles" = { 
        hostPath = "/var/www/web-fastoche/static";
        isReadOnly = false; 
       }; 
       "/home/wagtail/resdigita-fastoche/medias" = { 
        hostPath = "/var/www/resdigita-fastoche/medias";
        isReadOnly = false; 
       }; 
      "/home/wagtail/resdigita-fastoche/staticfiles" = { 
        hostPath = "/var/www/resdigita-fastoche/static";
        isReadOnly = false; 
       }; 
       "/home/wagtail/village/medias" = { 
        hostPath = "/var/www/village/medias";
        isReadOnly = false; 
       }; 
      "/home/wagtail/village/staticfiles" = { 
        hostPath = "/var/www/village/static";
        isReadOnly = false; 
       }; 
       "/home/wagtail/villagengo/medias" = { 
        hostPath = "/var/www/villagengo/medias";
        isReadOnly = false; 
       }; 
      "/home/wagtail/villagengo/staticfiles" = { 
        hostPath = "/var/www/villagengo/static";
        isReadOnly = false; 
       };        
       "/home/wagtail/www-fastoche/medias" = { 
        hostPath = "/var/www/www-fastoche/medias";
        isReadOnly = false; 
       }; 
      "/home/wagtail/www-fastoche/staticfiles" = { 
        hostPath = "/var/www/www-fastoche/static";
        isReadOnly = false; 
       }; 
       "/home/wagtail/resdigitaorg/medias" = { 
        hostPath = "/var/www/resdigitaorg/medias";
        isReadOnly = false; 
       }; 
      "/home/wagtail/resdigitaorg/staticfiles" = { 
        hostPath = "/var/www/resdigitaorg/static";
        isReadOnly = false; 
       }; 
       "/home/wagtail/wagtail-village/medias" = { 
        hostPath = "/var/www/wagtail-village/medias";
        isReadOnly = false; 
       }; 
      "/home/wagtail/wagtail-village/staticfiles" = { 
        hostPath = "/var/www/wagtail-village/static";
        isReadOnly = false; 
       }; 
       "/home/wagtail/lesgrandsvoisins/medias" = { 
        hostPath = "/var/www/lesgrandsvoisins/medias";
        isReadOnly = false; 
       }; 
      "/home/wagtail/lesgrandsvoisins/staticfiles" = { 
        hostPath = "/var/www/lesgrandsvoisins/static";
        isReadOnly = false; 
       }; 
       "/home/wagtail/wagtail-fastoche/medias" = { 
        hostPath = "/var/www/wagtail-fastoche/medias";
        isReadOnly = false; 
       }; 
      "/home/wagtail/wagtail-fastoche/staticfiles" = { 
        hostPath = "/var/www/wagtail-fastoche/static";
        isReadOnly = false; 
       }; 
       "/home/wagtail/django-fastoche/media" = { 
        hostPath = "/var/www/django-fastoche/media";
        isReadOnly = false; 
       }; 
      "/home/wagtail/django-fastoche/staticfiles" = { 
        hostPath = "/var/www/django-fastoche/static";
        isReadOnly = false; 
       };
       "/home/wagtail/django-village/media" = { 
        hostPath = "/var/www/django-village/media";
        isReadOnly = false; 
       }; 
      "/home/wagtail/django-village/staticfiles" = { 
        hostPath = "/var/www/django-village/static";
        isReadOnly = false; 
       };
       "/home/wagtail/sites-faciles/medias" = { 
        hostPath = "/var/www/sites-faciles/medias";
        isReadOnly = false; 
       }; 
      "/home/wagtail/sites-faciles/staticfiles" = { 
        hostPath = "/var/www/sites-faciles/static";
        isReadOnly = false; 
       }; 
       "/home/wagtail/designsystem-fastoche" = { 
        hostPath = "/var/www/designsystem-fastoche";
        isReadOnly = false; 
       }; 
       "/home/wagtail/designsystem-village/example" = { 
        hostPath = "/var/www/designsystem-village/example";
        isReadOnly = false; 
       }; 
       "/home/wagtail/designsystem-village/dist" = { 
        hostPath = "/var/www/designsystem-village/dist";
        isReadOnly = false; 
       };
      # "/run/wagtail-sockets" = { 
      #   hostPath = "/run/wagtail-sockets";
      #   isReadOnly = false; 
      #  }; 
     };
    config = { config, pkgs, ... }: {
      # networking = {
      #   firewall.allowedTCPPorts = [ 22 25 80 443 143 587 993 995 636 8443 9443 ]; 
      # };
      users.users.wagtail.uid = 1003;
      # users.groups.users.gid = 1003;
      users.groups.wwwrun.gid = 54;
      users.groups.wwwrun.members = ["wagtail"];
      nix.settings.experimental-features = "nix-command flakes";
      time.timeZone = "Europe/Amsterdam";
      system.stateVersion = "24.05";
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
        python311
        python311Packages.pillow
        python311Packages.gunicorn
        python311Packages.pip
        libjpeg
        zlib
        libtiff
        freetype
        python311Packages.venvShellHook
        curl
        wget
        lynx
        dig    
        python311Packages.pylibjpeg-libjpeg
        git
        tmux
        bat
        cowsay
        lzlib
        killall
        pwgen
        python311Packages.pypdf2
        python311Packages.python-ldap
        python311Packages.pq
        python311Packages.aiosasl
        python311Packages.psycopg2
        gettext
        sqlite
        postgresql_14
        pipx
        gnumake
        poetry
        nodejs_22
        yarn
        jq
        ];

      # networking = {
      #   firewall = {
      #     enable = false;
      #     allowedTCPPorts = [ 80 443 ];
      #   };
        # Use systemd-resolved inside the container
        # useHostResolvConf = lib.mkForce false;
      #};
        
      # services.resolved.enable = true;

      # services.postgresql = {
      #   enable = true;
      #   enableTCPIP = true;
      #   ensureDatabases = [
      #     "wagtail"
      #     "previous"
      #     "fairemain"
      #   ];
          # # ensureDBOwnership = true;
      # };
      users.users.wagtail.isNormalUser = true;
      # systemd.sockets.wagtail = {
      #   description = "Socket for Wagtail";
      #   listenStreams = ["/run/wagtail-sockets/wagtail.sock"];
      #   wantedBy = ["sockets.target"];
      #   socketConfig = {
      #     SocketUser = "wagtail";
      #     SocketMode = "0660";
      #   };
      # };
      systemd.tmpfiles.rules = [
       "d /run/wagtail-sockets/ 0770 wagtail wwwrun"
       "f /run/wagtail-sockets/wagtail.sock 0660 wagtail wwwrun"
      ];
      systemd.services.wagtail = {
        description = "Les Grands Voisins Wagtail Website";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        # requires = [ "wagtail.socket" ];
        serviceConfig = {
          WorkingDirectory = "/home/wagtail/wagtail-lesgv/";
          # ExecStart = ''/home/wagtail/venv/bin/gunicorn --env WAGTAIL_ENV='production' --access-logfile access.log --chdir /home/wagtail/wagtail-lesgv --workers 3 --bind unix:/var/lib/wagtail/wagtail-lesgv.sock lesgv.wsgi:application'';
          ExecStart = ''/home/wagtail/venv/bin/gunicorn --env WAGTAIL_ENV='production' --access-logfile /var/log/wagtail/access.log --error-logfile /var/log/wagtail/error.log --chdir /home/wagtail/wagtail-lesgv --workers 12 --bind 127.0.0.1:8008 lesgv.wsgi:application'';
          # ExecStart = ''/home/wagtail/venv/bin/gunicorn --env WAGTAIL_ENV='production' --access-logfile /var/log/wagtail/access.log --error-logfile /var/log/wagtail/error.log --chdir /home/wagtail/wagtail-lesgv --workers 12 --bind unix:/run/wagtail-sockets/wagtail.sock lesgv.wsgi:application'';
          Restart = "always";
          RestartSec = "10s";
          User = "wagtail";
          Group = "users";
        };
        unitConfig = {
          StartLimitInterval = "1min";
        };
      };
      systemd.services.sites-faciles = {
        description = "Les Grands Voisins Wagtail Website based on facile";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          WorkingDirectory = "/home/wagtail/sites-faciles/";
          # ExecStart = ''/home/wagtail/sites-faciles/venv/bin/gunicorn --env WAGTAIL_ENV='production' --access-logfile access-facile.log --chdir /home/wagtail/sites-faciles --workers 3 --bind unix:/var/lib/wagtail/sites-faciles.sock facile.wsgi:application'';
          ExecStart = ''/home/wagtail/sites-faciles/venv/bin/gunicorn --env WAGTAIL_ENV='production' --access-logfile /var/log/wagtail/sites-faciles-access.log --error-logfile /var/log/wagtail/sites-faciles-error.log --chdir /home/wagtail/sites-faciles --workers 12 --bind 0.0.0.0:8080 wagtail_village.config.wsgi:application'';
          Restart = "always";
          RestartSec = "10s";
          User = "wagtail";
          Group = "users";
        };
        unitConfig = {
          StartLimitInterval = "1min";
        };
      };
      systemd.services.francemali = {
        description = "FranceMali.org Website based on Sites-Faciles par la DIRNUM";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          WorkingDirectory = "/home/wagtail/francemali/";
          # ExecStart = ''/home/wagtail/francemali/venv/bin/gunicorn --env WAGTAIL_ENV='production' --access-logfile access-facile.log --chdir /home/wagtail/francemali --workers 3 --bind unix:/var/lib/wagtail/francemali.sock facile.wsgi:application'';
          ExecStart = ''/home/wagtail/francemali/venv/bin/gunicorn --env WAGTAIL_ENV='production' --access-logfile /var/log/wagtail/francemali-access.log --error-logfile /var/log/wagtail/francemali-error.log --chdir /home/wagtail/francemali --workers 12 --bind 0.0.0.0:8888 wagtail_cfran.config.wsgi:application'';
          Restart = "always";
          RestartSec = "10s";
          User = "wagtail";
          Group = "users";
        };
        unitConfig = {
          StartLimitInterval = "1min";
        };
      };
      systemd.services.web-fastoche = {
        description = "www.cfran.org Website based on Wagtail-cfran";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          WorkingDirectory = "/home/wagtail/web-fastoche/";
          # ExecStart = ''/home/wagtail/web-fastoche/venv/bin/gunicorn --env WAGTAIL_ENV='production' --access-logfile access-facile.log --chdir /home/wagtail/web-fastoche --workers 3 --bind unix:/var/lib/wagtail/web-fastoche.sock facile.wsgi:application'';
          ExecStart = ''/home/wagtail/web-fastoche/venv/bin/gunicorn --env WAGTAIL_ENV='production' --access-logfile /var/log/wagtail/web-fastoche-access.log --error-logfile /var/log/wagtail/web-fastoche-error.log --chdir /home/wagtail/web-fastoche --workers 12 --bind 0.0.0.0:8889 wagtail_village.config.wsgi:application'';
          Restart = "always";
          RestartSec = "10s";
          User = "wagtail";
          Group = "users";
        };
        unitConfig = {
          StartLimitInterval = "1min";
        };
      };
      systemd.services.wagtail-fastoche = {
        description = "wagtail.fastoche.org Website based on Wagtail-fastoche";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          WorkingDirectory = "/home/wagtail/wagtail-fastoche/";
          # ExecStart = ''/home/wagtail/wagtail-fastoche/venv/bin/gunicorn --env WAGTAIL_ENV='production' --access-logfile access-facile.log --chdir /home/wagtail/wagtail-fastoche --workers 3 --bind unix:/var/lib/wagtail/wagtail-fastoche.sock facile.wsgi:application'';
          ExecStart = ''/home/wagtail/wagtail-fastoche/venv/bin/gunicorn --env WAGTAIL_ENV='production' --access-logfile /var/log/wagtail/wagtail-fastoche-access.log --error-logfile /var/log/wagtail/wagtail-fastoche-error.log --chdir /home/wagtail/wagtail-fastoche --workers 12 --bind 0.0.0.0:8890 wagtail_fastoche.config.wsgi:application'';
          Restart = "always";
          RestartSec = "10s";
          User = "wagtail";
          Group = "users";
        };
        unitConfig = {
          StartLimitInterval = "1min";
        };
      };
      systemd.services.wagtail-village = {
        description = "wagtail.village.ngo Website based on Wagtail-village";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          WorkingDirectory = "/home/wagtail/wagtail-village/";
          # ExecStart = ''/home/wagtail/wagtail-village/venv/bin/gunicorn --env WAGTAIL_ENV='production' --access-logfile access-facile.log --chdir /home/wagtail/wagtail-village --workers 3 --bind unix:/var/lib/wagtail/wagtail-village.sock facile.wsgi:application'';
          ExecStart = ''/home/wagtail/wagtail-village/venv/bin/gunicorn --env WAGTAIL_ENV='production' --access-logfile /var/log/wagtail/wagtail-village-access.log --error-logfile /var/log/wagtail/wagtail-village-error.log --chdir /home/wagtail/wagtail-village --workers 12 --bind 0.0.0.0:8897 wagtail_village.config.wsgi:application'';
          Restart = "always";
          RestartSec = "10s";
          User = "wagtail";
          Group = "users";
        };
        unitConfig = {
          StartLimitInterval = "1min";
        };
      };
      systemd.services.cantine = {
        description = "cantine.resdigita.com Website based on wagtail-village";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          WorkingDirectory = "/home/wagtail/cantine/";
          ExecStart = ''/home/wagtail/cantine/venv/bin/gunicorn --env WAGTAIL_ENV='production' --access-logfile /var/log/wagtail/cantine-access.log --error-logfile /var/log/wagtail/cantine-error.log --chdir /home/wagtail/cantine --workers 12 --bind 0.0.0.0:8900 wagtail_village.config.wsgi:application'';
          Restart = "always";
          RestartSec = "10s";
          User = "wagtail";
          Group = "users";
        };
        unitConfig = {
          StartLimitInterval = "1min";
        };
      };
      systemd.services.resdigitaorg = {
        description = "www.resdigita.org Website based on wagtail-village";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          WorkingDirectory = "/home/wagtail/resdigitaorg/";
          ExecStart = ''/home/wagtail/resdigitaorg/venv/bin/gunicorn --env WAGTAIL_ENV='production' --access-logfile /var/log/wagtail/resdigitaorg-access.log --error-logfile /var/log/wagtail/resdigitaorg-error.log --chdir /home/wagtail/resdigitaorg --workers 12 --bind 0.0.0.0:8899 wagtail_village.config.wsgi:application'';
          Restart = "always";
          RestartSec = "10s";
          User = "wagtail";
          Group = "users";
        };
        unitConfig = {
          StartLimitInterval = "1min";
        };
      };
      systemd.services.resdigita-fastoche = {
        description = "wagtail.fastoche.org Website based on resdigita-fastoche";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          WorkingDirectory = "/home/wagtail/resdigita-fastoche/";
          ExecStart = ''/home/wagtail/resdigita-fastoche/venv/bin/gunicorn --env WAGTAIL_ENV='production' --access-logfile /var/log/wagtail/resdigita-fastoche-access.log --error-logfile /var/log/wagtail/resdigita-fastoche-error.log --chdir /home/wagtail/resdigita-fastoche --workers 12 --bind 0.0.0.0:8892 wagtail_fastoche.config.wsgi:application'';
          Restart = "always";
          RestartSec = "10s";
          User = "wagtail";
          Group = "users";
        };
        unitConfig = {
          StartLimitInterval = "1min";
        };
      };
      systemd.services.www-fastoche = {
        description = "wagtail.fastoche.org Website based on www-fastoche";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          WorkingDirectory = "/home/wagtail/www-fastoche/";
          ExecStart = ''/home/wagtail/www-fastoche/venv/bin/gunicorn --env WAGTAIL_ENV='production' --access-logfile /var/log/wagtail/www-fastoche-access.log --error-logfile /var/log/wagtail/www-fastoche-error.log --chdir /home/wagtail/www-fastoche --workers 12 --bind 0.0.0.0:8893 wagtail_fastoche.config.wsgi:application'';
          Restart = "always";
          RestartSec = "10s";
          User = "wagtail";
          Group = "users";
        };
        unitConfig = {
          StartLimitInterval = "1min";
        };
      };
      systemd.services.wagtail-lesgrandsvoisins = {
        description = "wagtail.lesgrandsvoisins.com on 8894";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          WorkingDirectory = "/home/wagtail/lesgrandsvoisins/";
          ExecStart = ''/home/wagtail/lesgrandsvoisins/venv/bin/gunicorn --env WAGTAIL_ENV='production' --access-logfile /var/log/wagtail/lesgrandsvoisins-access.log --error-logfile /var/log/wagtail/lesgrandsvoisins-error.log --chdir /home/wagtail/lesgrandsvoisins --workers 12 --bind 0.0.0.0:8894 lesgrandsvoisins.wsgi:application'';
          Restart = "always";
          RestartSec = "10s";
          User = "wagtail";
          Group = "users";
        };
        unitConfig = {
          StartLimitInterval = "1min";
        };
      };
      systemd.services.django-village = {
        description = "django.cfran.org Website based on django-village";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          WorkingDirectory = "/home/wagtail/django-village/";
          # ExecStart = ''/home/wagtail/django-village/venv/bin/gunicorn --env WAGTAIL_ENV='production' --access-logfile access-facile.log --chdir /home/wagtail/django-village --workers 3 --bind unix:/var/lib/wagtail/django-village.sock facile.wsgi:application'';
          ExecStart = ''/home/wagtail/django-village/venv/bin/gunicorn --access-logfile /var/log/wagtail/django-village-access.log --error-logfile /var/log/wagtail/django-village-error.log --chdir /home/wagtail/django-village --workers 12 --bind 0.0.0.0:8891 django_village.config.wsgi:application'';
          Restart = "always";
          RestartSec = "10s";
          User = "wagtail";
          Group = "users";
        };
        unitConfig = {
          StartLimitInterval = "1min";
        };
      };
      systemd.services.villagengo = {
        description = "www.village.ngo";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          WorkingDirectory = "/home/wagtail/villagengo/";
          ExecStart = ''/home/wagtail/villagengo/venv/bin/gunicorn --access-logfile /var/log/wagtail/villagengo-access.log --error-logfile /var/log/wagtail/villagengo-error.log --chdir /home/wagtail/villagengo --workers 12 --bind 0.0.0.0:8895 wagtail_cefran.config.wsgi:application'';
          Restart = "always";
          RestartSec = "10s";
          User = "wagtail";
          Group = "users";
        };
        unitConfig = {
          StartLimitInterval = "1min";
        };
      };
      systemd.services.village = {
        description = "www.village.ngo";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          WorkingDirectory = "/home/wagtail/village/";
          ExecStart = ''/home/wagtail/village/venv/bin/gunicorn --access-logfile /var/log/wagtail/village-access.log --error-logfile /var/log/wagtail/village-error.log --chdir /home/wagtail/village --workers 12 --bind 0.0.0.0:8896 wagtail_village.config.wsgi:application'';
          Restart = "always";
          RestartSec = "10s";
          User = "wagtail";
          Group = "users";
        };
        unitConfig = {
          StartLimitInterval = "1min";
        };
      };
    };
  };
  containers.discourse = {
    bindMounts = {
      "/var/lib/acme/discourse.village.ngo/" = {
        hostPath = "/var/lib/acme/discourse.village.ngo/";
        isReadOnly = true;
      }; 
      # "/run/discourse/sockets/unicorn.sock"
    };
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.104.10";
    localAddress = "192.168.104.11";
    hostAddress6 = "fe00::1";
    localAddress6 = "fe00::2";
    config = { config, pkgs, lib, ...  }: {
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
        # postgresql_13
        git
        lynx
      ];
      nixpkgs.config.permittedInsecurePackages = [
        "discourse-3.2.5"
      ];
      virtualisation.docker.enable = true;
      system.stateVersion = "24.05";
      nix.settings.experimental-features = "nix-command flakes";
      networking = {
        firewall.enable = false;
        # firewall = {
        #   enable = true;
        #   allowedTCPPorts = [ 80 443 ];
        # };
        # Use systemd-resolved inside the container
        useHostResolvConf = lib.mkForce false;
      };
      security.acme.acceptTerms = true;
      # users.users = {
      #   "discourse" = {
      #     createHome = true;
      #   };
      # };
      users = {
        groups = {
          "acme" = {
            gid = 993;
            members = ["acme"];
          };
          "wwwrun" = {
            gid = 54;
            members = ["nginx" "discourse"];
          };
        };
        users = {
          "acme" = {
            uid = 994;
            group = "acme";
          };
          "wwwrun" = {
            uid = 54;
            group = "wwwrun";
          };
        };
      };
      services = {
        resolved.enable = true;
        nginx.virtualHosts."discourse.village.ngo" = {
          sslCertificate = "/var/lib/acme/discourse.village.ngo/full.pem";
          sslCertificateKey = "/var/lib/acme/discourse.village.ngo/key.pem";
          locations."/" = {
            proxyPass = "http://unix:/var/discourse/shared/standalone/nginx.http.sock";
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_http_version 1.1;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_ssl_trusted_certificate /var/lib/acme/discourse.village.ngo/full.pem;
              proxy_ssl_verify off;
            '';
          };
        };
        discourse = {
          enable = true;
          hostname = "discourse.village.ngo";
          sslCertificate = "/var/lib/acme/discourse.village.ngo/full.pem";
          sslCertificateKey = "/var/lib/acme/discourse.village.ngo/key.pem";
          siteSettings = {
            security.forceHttps = true;
          };
          enableACME = false;
          plugins = [ 
            config.services.discourse.package.plugins.discourse-openid-connect
            # config.services.discourse.package.plugins.discourse-oauth2-basic
            # config.services.discourse.package.plugins.discourse-saml
          ];
          admin = {
            email = "gv@village.ngo";
            fullName = "Super Admin";
            username = "admin";
            passwordFile = "/etc/discourse/.admin";
          };
          mail = {
            outgoing = {
              serverAddress = "mail.lesgrandsvoisins.com";
              authentication = "plain";
              username = "gv@village.ngo";
              passwordFile = "/etc/.secrets.gvvillagengo";
              # port = 587;
              # forceTLS = true;
              # opensslVerifyMode = "none";
            };
          };
        };
        postgresql = {
          enable = true;
          package = pkgs.postgresql_13;
        };
      };
    };
  };
  containers.key = {
    bindMounts = {
      "/var/lib/acme/key.lesgrandsvoisins.com/" = {
        hostPath = "/var/lib/acme/key.lesgrandsvoisins.com/";
        isReadOnly = true;
      }; 
    };
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.105.10";
    localAddress = "192.168.105.11";
    hostAddress6 = "fa01::1";
    localAddress6 = "fa01::2";
    config = { config, pkgs, lib, ...  }: {
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
        git
        lynx
        openldap
        postgresql
      ];
      # virtualisation.docker.enable = true;
      system.stateVersion = "24.05";
      nix.settings.experimental-features = "nix-command flakes";
      networking = {
        firewall = {
          enable = false;
          allowedTCPPorts = [  443 587 14443 ]; 
        };
        useHostResolvConf = lib.mkForce false;
      };
      systemd.tmpfiles.rules = [
       "f /etc/.secret.keydata 0660 root root"
      ];
      # security.acme.acceptTerms = true;
      users = {
        groups = {
          "acme" = {
            gid = 993;
            members = ["acme"];
          };
          "wwwrun" = {
            gid = 54;
            members = ["acme" "wwwrun"];
          };
        };
        users = {
          "acme" = {
            uid = 994;
            group = "acme";
          };
          "wwwrun" = {
            uid = 54;
            group = "wwwrun";
          };
        };
      };
      services = {
        resolved.enable = true;
        keycloak = {
          enable = true;
          database = {
            username="key";
            name="key";
            # passwordFile="/etc/.secrets.key";
            passwordFile="/etc/.secrets.key";
            # createLocally=false;
            # host="localhost";
            # useSSL = false;
          };
          settings = {
            https-port = 14443;
            http-port = 14080;
            # proxy = "passthrough";
            proxy = "reencrypt";
            hostname = "key.lesgrandsvoisins.com";
            # hostname-admin = "adminkey.lesgrandsvoisins.com";
          };
          sslCertificate = "/var/lib/acme/key.lesgrandsvoisins.com/fullchain.pem";
          sslCertificateKey = "/var/lib/acme/key.lesgrandsvoisins.com/key.pem";
          # themes = {lesgv = (pkgs.callPackage "/etc/nixos/keycloaktheme/derivation.nix" {});};
        };
      };
    };
  };
  containers.keycloak = {
    bindMounts = {
      "/var/lib/acme/keycloak.village.ngo/" = {
        hostPath = "/var/lib/acme/keycloak.village.ngo/";
        isReadOnly = true;
      }; 
    };
    autoStart = true;
    # privateNetwork = true;
    # hostAddress = "192.168.105.10";
    # localAddress = "192.168.105.11";
    # hostAddress6 = "fa01::1";
    # localAddress6 = "fa01::2";
    config = { config, pkgs, lib, ...  }: {
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
        git
        lynx
        openldap
      ];
      # virtualisation.docker.enable = true;
      system.stateVersion = "24.05";
      nix.settings.experimental-features = "nix-command flakes";
      networking = {
        firewall = {
          enable = false;
          allowedTCPPorts = [  443 587 12443 ]; 
        };
        useHostResolvConf = lib.mkForce false;
      };
      systemd.tmpfiles.rules = [
       "f /etc/.secret.keycloakdata 0660 root root"
      ];
      # security.acme.acceptTerms = true;
      users = {
        groups = {
          "acme" = {
            gid = 993;
            members = ["acme"];
          };
          "wwwrun" = {
            gid = 54;
            members = ["acme" "wwwrun"];
          };
        };
        users = {
          "acme" = {
            uid = 994;
            group = "acme";
          };
          "wwwrun" = {
            uid = 54;
            group = "wwwrun";
          };
        };
      };
      services = {
        resolved.enable = true;
        keycloak = {
          enable = true;
          database = {
            passwordFile = "/etc/.secrets.keycloak";
            # useSSL = false;
          };
          settings = {
            https-port = 12443;
            http-port = 12080;
            # proxy = "passthrough";
            proxy = "reencrypt";
            hostname = "keycloak.village.ngo";
          };
          sslCertificate = "/var/lib/acme/keycloak.village.ngo/fullchain.pem";
          sslCertificateKey = "/var/lib/acme/keycloak.village.ngo/key.pem";
          # themes = {lesgv = (pkgs.callPackage "/etc/nixos/keycloaktheme/derivation.nix" {});};
        };
      };
    };
  };
  systemd.tmpfiles.rules = [
    "d /var/local/cherryldap 0755 cherryldap users"
  ];
  users.users.cherryldap = {
    isNormalUser = true;
    uid = 11111;
  };
  containers.cherryldap = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.106.1";
    localAddress = "192.168.106.2";
    hostAddress6 = "fc00::6:1";
    localAddress6 = "fc00::6:2"; 
    bindMounts = { 
      "/var/local/cherryldap" = { 
        hostPath = "/var/local/cherryldap";
        isReadOnly = false; 
      }; 
    };
    config = { config, pkgs, ... }: {
      nix.settings.experimental-features = "nix-command flakes";
      time.timeZone = "Europe/Paris";
      system.stateVersion = "24.05";
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
        # python311Packages.cherrypy-cors
        # python311Packages.pillow
        # python311Packages.gunicorn
        # python311Packages.pip
        # libjpeg
        # zlib
        # libtiff
        # freetype
        # python311Packages.venvShellHook
        curl
        wget
        lynx
        libclang
        # dig    
        # python311Packages.pylibjpeg-libjpeg
        git
        # tmux
        # bat
        # cowsay
        # lzlib
        # killall
        # pwgen
        # python311Packages.pypdf2
        # python311Packages.pq
        # python311Packages.aiosasl
        # python311Packages.psycopg2
        # gettext
        # sqlite
        # postgresql_14
        # pipx
        gnumake
        gcc
        glibcLocales
        # python311Packages.manimpango
        # python311Packages.devtools

        # python311Packages.django-auth-ldap
        # python311Packages.pq
        # python311Packages.aiosasl
        # python311Packages.pylibjpeg-libjpeg
        # python311Packages.virtualenv
        # python311Packages.toolz
        # libpqxx
        # postgresql
        openldap
        # python311Packages.pgcli
        # cairo
        # cairomm
        # python311Packages.pycairo
        # python311Packages.cairosvg
        # python311Packages.cairocffi

        gnutls
        gnulib
        gnumake
        openssl
        cyrus_sasl
        # ldapcherry
        (pkgs.python3.withPackages (python-pkgs: [
          # python-pkgs.devtools
          # python-pkgs.pydevtool
          python-pkgs.cherrypy
          python-pkgs.mako
          python-pkgs.pyyaml
          python-pkgs.python-ldap
          python-pkgs.yq
          python-pkgs.pip
          # python-pkgs.python-ldap-test
          # python-pkgs.ldappool
          # python-pkgs.wheel
          # python-pkgs.wheelUnpackHook
          # python-pkgs.installer
          # python-pkgs.bootstrap.installer
          # python-pkgs.pandas
          # python-pkgs.requests
        ]))

        ninja
        cmake
        # PHP
        php
        ];
      networking = {
        hostName = "cherryldap"; 
        firewall.allowedTCPPorts = [ 22 25 53 80 443 143 587 993 995 636 ];
        useHostResolvConf = lib.mkForce false;
      };     
      services.resolved.enable = true;   
      users.users.cherryldap = {
        isNormalUser = true;
        uid = 11111;
      };
      systemd.tmpfiles.rules = [
        "d /var/local/cherryldap 0755 cherryldap users"
        "d /var/local/cherryldap/settings_local.py 0644 cherryldap users"
      ];

      # systemd.services.cherryldap = {
      #   description = "ResDigita FFDN Coin";
      #   after = [ "network.target" ];
      #   wantedBy = [ "multi-user.target" ];
      #   serviceConfig = {
      #     WorkingDirectory = "/var/local/cherryldap/";
      #     ExecStart = ''/var/local/cherryldap/venv/bin/gunicorn --env LDAP_ACTIVATE='true' --env='DEFAULT_FROM_EMAIL' --access-logfile /var/log/cherryldap-access.log --error-logfile /var/log/cherryldap-error.log --chdir /var/local/cherryldap --workers 12 --bind 127.0.0.1:8000 lesgv.wsgi:application'';
      #     Restart = "always";
      #     RestartSec = "10s";
      #     User = "wagtail";
      #     Group = "users";
      #   };
      #   unitConfig = {
      #     StartLimitInterval = "1min";
      #   };
      # };
    };
  };
  containers.lgvldap = {
    autoStart = true;
    bindMounts = { 
      "/var/lib/acme/${lgvLdapDomainName}" = { 
        hostPath = "/var/lib/acme/${lgvLdapDomainName}";
        isReadOnly = false; 
      }; 
    };
    config = { config, pkgs, lib, ...  }: {
      nix.settings.experimental-features = "nix-command flakes";
      system.stateVersion = "24.05";
      time.timeZone = "Europe/Paris";
      environment.systemPackages = with pkgs; [
        lynx
        nettools
        wget
        dig
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
        # postgresql_14
        pwgen
      ];
      imports = [
        (builtins.fetchTarball {
          url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/ldap-support/nixos-mailserver-nixos-24.05.tar.gz";
          sha256 = "sha256:15v6b5z8gjspps5hyq16bffbwmq0rwfwmdhyz23frfcni3qkgzpc";
        })
      ];
      users = {
        groups = {
          "acme".gid = 993;
          "wwwrun".gid = 54;
        };
        users = {
          "acme" = {
            uid = 994;
            group = "acme";
          };
          "wwwrun" = {
            uid = 54;
            group = "wwwrun";
          };
        };
      };
      systemd.tmpfiles.rules = [
        "d /var/lib/acme/${lgvLdapDomainName} 0755 acme wwwrun"
        "f /var/lib/openldap/pmw/schema/pwm.ldif 0755 openldap openldap"
        "d /var/www/lesgrandsvoisins.com/ldap 0775 wwwrun wwwrun"
      ];
      security.acme.defaults.email = "chris@mann.fr";
      security.acme.acceptTerms = true;
      services = {
        openldap = {
          enable = true;
          urlList = ["ldap://${lgvLdapDomainName}:14389/ ldaps://${lgvLdapDomainName}:14636/ ldapi:///"];
          settings = {
            attrs = {
              olcLogLevel = "conns config";
              /* settings for acme ssl */
              olcTLSCACertificateFile = "/var/lib/acme/${lgvLdapDomainName}/full.pem";
              olcTLSCertificateFile = "/var/lib/acme/${lgvLdapDomainName}/full.pem";
              olcTLSCertificateKeyFile = "/var/lib/acme/${lgvLdapDomainName}/key.pem";
              olcTLSCipherSuite = "HIGH:MEDIUM:+3DES:+RC4:+aNULL";
              olcTLSCRLCheck = "none";
              olcTLSVerifyClient = "never";
              olcTLSProtocolMin = "3.1";
              olcThreads = "16";
            };
             # Flake this
            children = {
              "cn=schema".includes = [
                "${pkgs.openldap}/etc/schema/core.ldif"
                "${pkgs.openldap}/etc/schema/cosine.ldif"
                "${pkgs.openldap}/etc/schema/inetorgperson.ldif"
                "${pkgs.openldap}/etc/schema/nis.ldif"
              ]; 
              "olcDatabase={1}mdb".attrs = {
                objectClass = [ "olcDatabaseConfig" "olcMdbConfig" ];
                olcDbIndex = [
                  "displayName,description eq,sub"
                  "uid,ou,c eq"
                  "carLicense,labeledURI,telephoneNumber,mobile,homePhone,title,street,l,st,postalCode eq"
                  "objectClass,cn,sn,givenName,mail eq"
                ];
                olcDatabase = "{1}mdb";
                olcDbDirectory = "/var/lib/openldap/data";
                olcSuffix = "${lgvLdapBaseDN}";
                /* your admin account, do not use writeText on a production system */
                olcRootDN = "cn=admin,${lgvLdapBaseDN}";
                olcRootPW = (builtins.readFile /etc/nixos/.secrets.bind);
                olcAccess = [
                  /* custom access rules for userPassword attributes */
                  /* allow read on anything else */
                  ''{0}to dn.subtree="ou=newusers,${lgvLdapBaseDN}"
                      by dn.exact="cn=newuser,ou=users,${lgvLdapBaseDN}" write
                      by group.exact="cn=administration,ou=groups,${lgvLdapBaseDN}" write
                      by self write
                      by anonymous auth
                      by * read''
                  ''{1}to dn.subtree="ou=invitations,${lgvLdapBaseDN}"
                      by dn.exact="cn=newuser,ou=users,${lgvLdapBaseDN}" write
                      by group.exact="cn=administration,ou=groups,${lgvLdapBaseDN}" write
                      by self write
                      by anonymous auth
                      by * read''
                  ''{2}to dn.subtree="ou=users,${lgvLdapBaseDN}"
                      by dn.exact="cn=admin@lesgrandsvoisins.com,ou=users,${lgvLdapBaseDN}" manage
                      by dn.exact="cn=newuser,ou=users,${lgvLdapBaseDN}" write
                      by group.exact="cn=administration,ou=groups,${lgvLdapBaseDN}" write
                      by self write
                      by anonymous auth
                      by * read''
                  ''{3}to attrs=userPassword
                      by dn.exact="cn=admin@lesgrandsvoisins.com,ou=users,${lgvLdapBaseDN}" manage
                      by self write
                      by anonymous auth
                      by * none''
                  ''{4}to *
                      by dn.exact="cn=sogo@lesgrandsvoisins.com,ou=users,${lgvLdapBaseDN}" manage
                      by dn.exact="cn=chris@lesgrandsvoisins.com,ou=users,${lgvLdapBaseDN}" manage
                      by dn.exact="cn=chris@mann.fr,ou=users,${lgvLdapBaseDN}" manage
                      by dn.exact="cn=admin@lesgrandsvoisins.com,ou=users,${lgvLdapBaseDN}" manage
                      by self write
                      by anonymous auth''
                  /* custom access rules for userPassword attributes */
                  ''{5}to attrs=cn,sn,givenName,displayName,member,memberof
                      by self write
                      by * read''
                  ''{6}to *
                      by * read''
                ];
              };
            };
          };
        };
      };
      systemd.services.openldap = {
        wants = [ "acme-${lgvLdapDomainName}.service" ];
        after = [ "acme-${lgvLdapDomainName}.service" ];
        serviceConfig = {
          RemainAfterExit = false;
        };
      };
      users.groups.wwwrun.members = [ "openldap" ];
      users.groups.acme.members = [ "openldap" ];
    };
  };
  containers.openldap = {
    autoStart = true;
    # localAddress6 = "2a01:4f8:241:4faa::1";
    # privateNetwork = true;
    # hostAddress = "192.168.107.10";
    # localAddress = "192.168.107.11";
    # hostAddress6 = "fa01::1";
    # localAddress6 = "fa01::2";
    bindMounts = { 
      "/var/lib/acme/${ldapDomainName}" = { 
        hostPath = "/var/lib/acme/${ldapDomainName}";
        isReadOnly = false; 
      }; 
    };
    config = { config, pkgs, lib, ...  }: {
      nix.settings.experimental-features = "nix-command flakes";
      system.stateVersion = "24.05";
      # networking = {
      #   firewall.allowedTCPPorts = [ 18080 10389 10686 22 80 443 389 636 993 11211 25 ];
      #   # trustedInterfaces = ["eno1" "lo"];
      #   # hosts = {
      #   #   "192.168.107.11" = ["ldap.gv.coop"];
      #   # };
      #   # useHostResolvConf = true;
      #   useHostResolvConf = lib.mkForce false;
      #   # resolvconf.enable = true;
      # };
      time.timeZone = "Europe/Paris";
      environment.systemPackages = with pkgs; [
        lynx
        nettools
        wget
        dig
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
        # postgresql_14
        pwgen
      ];
      imports = [
        (builtins.fetchTarball {
          url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/ldap-support/nixos-mailserver-nixos-24.05.tar.gz";
          sha256 = "sha256:15v6b5z8gjspps5hyq16bffbwmq0rwfwmdhyz23frfcni3qkgzpc";
        })
      ];
      users = {
        groups = {
          "acme".gid = 993;
          "wwwrun".gid = 54;
        };
        users = {
          "acme" = {
            uid = 994;
            group = "acme";
          };
          "wwwrun" = {
            uid = 54;
            group = "wwwrun";
          };
        };
      };
      systemd.tmpfiles.rules = [
        "d /var/lib/acme/${ldapDomainName} 0755 acme wwwrun"
        "f /var/lib/openldap/pmw/schema/pwm.ldif 0755 openldap openldap"
        "d /var/www/lesgrandsvoisins.com/ldap 0775 wwwrun wwwrun"
      ];
      security.acme.defaults.email = "chris@mann.fr";
      security.acme.acceptTerms = true;
      services = {
        openssh = {
          enable = true;
        };

        # resolved = {
        #   enable = true;
        #   fallbackDns = [
        #       "8.8.8.8"
        #       "2001:4860:4860::8844"
        #     ];
        # };
        tomcat = {
          enable = true;
          extraEnvironment = [
            "PWM_APPLICATIONPATH=/var/tomcat/pwm"
          ];
          # extraConfigFiles = [
          #   "/var/tomcat/conf/extra-users.xml"
          # ];
          # javaOpts = [
          #   "-Dcom.sun.jndi.ldap.object.disableEndpointIdentification=true"
          # ];
          serverXml = ''<?xml version="1.0" encoding="UTF-8"?>
            <Server port="18005" shutdown="SHUTDOWN">
              <Listener className="org.apache.catalina.startup.VersionLoggerListener" />
              <!-- Security listener. Documentation at /docs/config/listeners.html
              <Listener className="org.apache.catalina.security.SecurityListener" />
              -->
              <!-- APR library loader. Documentation at /docs/apr.html -->
              <Listener className="org.apache.catalina.core.AprLifecycleListener" SSLEngine="on" />
              <!-- Prevent memory leaks due to use of particular java/javax APIs-->
              <Listener className="org.apache.catalina.core.JreMemoryLeakPreventionListener" />
              <Listener className="org.apache.catalina.mbeans.GlobalResourcesLifecycleListener" />
              <Listener className="org.apache.catalina.core.ThreadLocalLeakPreventionListener" />

              <!-- Global JNDI resources
                  Documentation at /docs/jndi-resources-howto.html
              -->
                <GlobalNamingResources>
                <!-- Editable user database that can also be used by
                    UserDatabaseRealm to authenticate users
                -->
                <Resource name="UserDatabase" auth="Container"
                          type="org.apache.catalina.UserDatabase"
                          description="User database that can be updated and saved"
                          factory="org.apache.catalina.users.MemoryUserDatabaseFactory"
                          pathname="conf/extra-users.xml" />
                </GlobalNamingResources>
                <Service name="Catalina">
                 <Connector port="18080" protocol="HTTP/1.1"
                    connectionTimeout="20000"
                    redirectPort="8443"
                    maxParameterCount="1000"
                    />
                  <Engine name="Catalina" defaultHost="localhost">
                        <!-- Use the LockOutRealm to prevent attempts to guess user passwords
                        via a brute-force attack -->
                    <Realm className="org.apache.catalina.realm.LockOutRealm">
                      <!-- This Realm uses the UserDatabase configured in the global JNDI
                          resources under the key "UserDatabase".  Any edits
                          that are performed against this UserDatabase are immediately
                          available for use by the Realm.  -->
                      <Realm className="org.apache.catalina.realm.UserDatabaseRealm"
                            resourceName="UserDatabase"/>
                    </Realm>

                    <Host name="localhost"  appBase="webapps"
                          unpackWARs="true" autoDeploy="true">

                      <!-- SingleSignOn valve, share authentication between web applications
                          Documentation at: /docs/config/valve.html -->
                      <!--
                      <Valve className="org.apache.catalina.authenticator.SingleSignOn" />
                      -->

                      <!-- Access log processes all example.
                          Documentation at: /docs/config/valve.html
                          Note: The pattern used is equivalent to using pattern="common" -->
                      <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
                            prefix="localhost_access_log" suffix=".txt"
                            pattern="%h %l %u %t &quot;%r&quot; %s %b" />
                    </Host>
                  </Engine>
              </Service>
            </Server>
          '';
        };
        openldap = {
          enable = true;
          urlList = ["ldap://ldap.gv.coop:10389/ ldaps://ldap.gv.coop:10636/ ldapi:///"];
          #  urlList = ["ldap://ldap.gv.coop:10389/ ldaps://ldap.gv.coop:10636/ ldapi:///"];
          # urlList = [ 
          #   "ldap://ldap.gv.coop:10389/" 
          #   "ldap://192.168.107.11:10389/"
          #   "ldaps://192.168.107.11:10636/"
          #   "ldaps://ldap.gv.coop:10636/"
          #   "ldapi:///"
          #   "ldap://localhost:10389/"
          #   "ldaps://localhost:10636/" 
          # ];
          settings = {
            attrs = {
              # olcTLSReqCert = "allow" ;
              # TLS_CACERTDIR /home/myuser/cacertss
              # LDAPTLS_CACERT /home/myuser/cacerts@@s
              olcLogLevel = "conns config";
              /* settings for acme ssl */
              olcTLSCACertificateFile = "/var/lib/acme/${ldapDomainName}/full.pem";
              olcTLSCertificateFile = "/var/lib/acme/${ldapDomainName}/full.pem";
              # olcTLSCertificateFile = "/var/lib/acme/${ldapDomainName}/cert.pem";
              olcTLSCertificateKeyFile = "/var/lib/acme/${ldapDomainName}/key.pem";
              olcTLSCipherSuite = "HIGH:MEDIUM:+3DES:+RC4:+aNULL";
              olcTLSCRLCheck = "none";
              olcTLSVerifyClient = "never";
              olcTLSProtocolMin = "3.1";
              olcThreads = "16";
            };
             # Flake this
            children = {
              "cn=schema".includes = [
                "${pkgs.openldap}/etc/schema/core.ldif"
                "${pkgs.openldap}/etc/schema/cosine.ldif"
                "${pkgs.openldap}/etc/schema/inetorgperson.ldif"
                "${pkgs.openldap}/etc/schema/nis.ldif"
                "/var/lib/openldap/pmw/schema/pwm.ldif"
              ]; 
              # Type: attribute
              # Name: pwmData
              # Definition: ( 1.3.6.1.4.1.35015.1.2.7 NAME 'pwmData' SYNTAX 1.3.6.1.4.1.1466.115.121.1.40 )


              # Type: attribute
              # Name: pwmEventLog
              # Definition: ( 1.3.6.1.4.1.35015.1.2.1 NAME 'pwmEventLog' SYNTAX 1.3.6.1.4.1.1466.115.121.1.40 )


              # Type: attribute
              # Name: pwmGUID
              # Definition: ( 1.3.6.1.4.1.35015.1.2.4 NAME 'pwmGUID' SYNTAX 1.3.6.1.4.1.1466.115.121.1.15 )


              # Type: attribute
              # Name: pwmLastPwdUpdate
              # Definition: ( 1.3.6.1.4.1.35015.1.2.3 NAME 'pwmLastPwdUpdate' SYNTAX 1.3.6.1.4.1.1466.115.121.1.24 )


              # Type: attribute
              # Name: pwmOtpSecret
              # Definition: ( 1.3.6.1.4.1.35015.1.2.6 NAME 'pwmOtpSecret' SYNTAX 1.3.6.1.4.1.1466.115.121.1.40 )


              # Type: attribute
              # Name: pwmResponseSet
              # Definition: ( 1.3.6.1.4.1.35015.1.2.2 NAME 'pwmResponseSet' SYNTAX 1.3.6.1.4.1.1466.115.121.1.40 )


              # Type: attribute
              # Name: pwmToken
              # Definition: ( 1.3.6.1.4.1.35015.1.2.5 NAME 'pwmToken' SYNTAX 1.3.6.1.4.1.1466.115.121.1.15 )


              # Type: objectclass
              # Name: pwmUser
              # Definition: ( 1.3.6.1.4.1.35015.1.1.1 NAME 'pwmUser' AUXILIARY MAY ( pwmLastPwdUpdate $ pwmEventLog $ pwmResponseSet $ pwmGUID $ pwmToken $ pwmOtpSecret $ pwmData ) )
              "olcDatabase={1}mdb".attrs = {
                objectClass = [ "olcDatabaseConfig" "olcMdbConfig" ];
                olcDbIndex = [
                  "displayName,description eq,sub"
                  "uid,ou,c eq"
                  "carLicense,labeledURI,telephoneNumber,mobile,homePhone,title,street,l,st,postalCode eq"
                  "objectClass,cn,sn,givenName,mail eq"
                ];
                olcDatabase = "{1}mdb";
                olcDbDirectory = "/var/lib/openldap/data";
                olcSuffix = "${ldapBaseDN}";
                /* your admin account, do not use writeText on a production system */
                olcRootDN = "cn=admin,${ldapBaseDN}";
                olcRootPW = (builtins.readFile /etc/nixos/.secrets.bind);
                olcAccess = [
                  /* custom access rules for userPassword attributes */
                  /* allow read on anything else */
                  ''{0}to dn.subtree="ou=newusers,${ldapBaseDN}"
                      by dn.exact="cn=newuser@lesgrandsvoisins.com,ou=users,${ldapBaseDN}" write
                      by group.exact="cn=administration,ou=groups,${ldapBaseDN}" write
                      by self write
                      by anonymous auth
                      by * read''
                  ''{1}to dn.subtree="ou=invitations,${ldapBaseDN}"
                      by dn.exact="cn=newuser@lesgrandsvoisins.com,ou=users,${ldapBaseDN}" write
                      by group.exact="cn=administration,ou=groups,${ldapBaseDN}" write
                      by self write
                      by anonymous auth
                      by * read''
                  ''{2}to dn.subtree="ou=users,${ldapBaseDN}"
                      by dn.exact="cn=admin@lesgrandsvoisins.com,ou=users,${ldapBaseDN}" manage
                      by dn.exact="cn=newuser@lesgrandsvoisins.com,ou=users,${ldapBaseDN}" write
                      by group.exact="cn=administration,ou=groups,${ldapBaseDN}" write
                      by self write
                      by anonymous auth
                      by * read''
                  ''{3}to attrs=userPassword
                      by dn.exact="cn=admin@lesgrandsvoisins.com,ou=users,${ldapBaseDN}" manage
                      by self write
                      by anonymous auth
                      by * none''
                  ''{4}to *
                      by dn.exact="cn=sogo@lesgrandsvoisins.com,ou=users,${ldapBaseDN}" manage
                      by dn.exact="cn=chris@lesgrandsvoisins.com,ou=users,${ldapBaseDN}" manage
                      by dn.exact="cn=chris@mann.fr,ou=users,${ldapBaseDN}" manage
                      by dn.exact="cn=admin@lesgrandsvoisins.com,ou=users,${ldapBaseDN}" manage
                      by self write
                      by anonymous auth''
                  /* custom access rules for userPassword attributes */
                  ''{5}to attrs=cn,sn,givenName,displayName,member,memberof
                      by self write
                      by * read''
                  ''{6}to *
                      by * read''
                ];
              };
            };
          };
        };
      };
      #  /* ensure openldap is launched after certificates are created */
      #  systemd.services.openldap = {
      #    wants = [ "acme-${ldapDomainNameomainName}.service" ];
      #    after = [ "acme-${ldapDomainName}.service" ];
      #  };
      #  /* make acme certificates accessible by openldap */
      #  security.acme.defaults.group = "certs";
      #  users.groups.certs.members = [ "openldap" ];
      #  /* trigger the actual certificate generation for your hostname */
      #  security.acme.certs."${ldapDomainName}" = {
      #    extraDomainNames = [];
      #  };
      #############################
      systemd.services.openldap = {
        wants = [ "acme-${ldapDomainName}.service" ];
        after = [ "acme-${ldapDomainName}.service" ];
        serviceConfig = {
          RemainAfterExit = false;
        };
      };
      users.groups.wwwrun.members = [ "openldap" ];
      users.groups.acme.members = [ "openldap" ];
    };
  };
  # containers.mailserver = {
  #   autoStart = true;
  #   # localAddress6 = "2a01:4f8:241:4faa::1";
  #   privateNetwork = true;
  #   hostAddress = "192.168.107.10";
  #   localAddress = "192.168.107.11";
  #   hostAddress6 = "fa01::1";
  #   localAddress6 = "fa01::2";
  #   # bindMounts = { 
  #   #   "/var/lib/acme/${domainName}" = { 
  #   #     hostPath = "/var/lib/acme/${domainName}";
  #   #     isReadOnly = false; 
  #   #   }; 
  #   # };
  #   config = { config, pkgs, lib, ...  }: {
  #     imports = [
  #       (builtins.fetchTarball {
  #         url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/ldap-support/nixos-mailserver-nixos-24.05.tar.gz";
  #         # url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/nixos-24.05/nixos-mailserver-nixos-24.05.tar.gz";
  #         sha256 = "sha256:15v6b5z8gjspps5hyq16bffbwmq0rwfwmdhyz23frfcni3qkgzpc";
  #       })
  #     ];
  #     nix.settings.experimental-features = "nix-command flakes";
  #     system.stateVersion = "24.05";
  #     networking = {
  #       firewall.allowedTCPPorts = [ 22 80 443 1360 11211 25 ];
  #       # trustedInterfaces = ["eno1" "lo"];
  #       # hosts = {
  #       #   "192.168.107.11" = ["ldap.gv.coop"];
  #       # };
  #       # useHostResolvConf = true;
  #       useHostResolvConf = lib.mkForce false;
  #       # resolvconf.enable = true;
  #       nat = {
  #           externalIPv6 = "2a01:4f8:241:4faa::1";
  #           forwardPorts = [
  #             {
  #               destination = "192.168.107.11:1360";
  #               proto = "tcp";
  #               sourcePort = 1360;
  #             }
  #             {
  #               destination = "[fa01::2]:1360";
  #               proto = "tcp";
  #               sourcePort = 1360;
  #             }
  #           ];
  #       };
  #     };
  #     time.timeZone = "Europe/Paris";
  #     environment.systemPackages = with pkgs; [
  #       lynx
  #       nettools
  #       wget
  #       dig
  #       ((vim_configurable.override {  }).customize{
  #         name = "vim";
  #         vimrcConfig.customRC = ''
  #           " your custom vimrc
  #           set mouse=a
  #           set nocompatible
  #           colo torte
  #           syntax on
  #           set tabstop     =2
  #           set softtabstop =2
  #           set shiftwidth  =2
  #           set expandtab
  #           set autoindent
  #           set smartindent
  #           " ...
  #         '';
  #         }
  #       )
  #       # postgresql_14
  #       pwgen
  #     ];
  #     users = {
  #       groups = {
  #         "acme".gid = 993;
  #         "wwwrun".gid = 54;
  #       };
  #       users = {
  #         "acme" = {
  #           uid = 994;
  #           group = "acme";
  #         };
  #         "wwwrun" = {
  #           uid = 54;
  #           group = "wwwrun";
  #         };
  #         # dovecot2.extraGroups = ["wwwrun"];
  #       };
  #     };
  #     # systemd.tmpfiles.rules = [
  #     #   "d /var/lib/acme/${ldapDomainName} 0755 acme wwwrun"
  #     #   "f /var/lib/openldap/pmw/schema/pwm.ldif 0755 openldap openldap"
  #     # ];
  #     security.acme.defaults.email = "chris@mann.fr";
  #     security.acme.acceptTerms = true;
  #     security.acme.certs."mail.lesgrandsvoisins.com".listenHTTP = "1360";
  #     # security.acme.certs."mail.gv.coop".listenHTTP = "1360";
  #     mailserver = {
  #       enable = true;
  #       fqdn = domainName;
  #       domains = mailServerDomainAliases;
  #       certificateScheme = "acme";
  #       certificateFile = "/var/lib/acme/${domainName}/fullchain.pem";
  #       certificateDirectory = "/var/lib/acme/${domainName}/";
  #       keyFile =  "/var/lib/acme/${domainName}/key.pem"; 
  #       messageSizeLimit = 209715200;
  #       # indexDir = "/var/lib/dovecot/indices";
  #       ldap = {
  #         enable = true;
  #         bind = {
  #           dn = "cn=admin,${ldapBaseDN}";
  #           passwordFile = "/etc/nixos/.secrets.bind";
  #         };
  #         uris = [
  #           "ldaps://ldap.lesgrandsvoisins.com:10636/"
  #           # "ldaps://ldap.gv.coop:10636/"
  #         ];
  #         searchBase = "ou=users,${ldapBaseDN}";
  #         searchScope = "sub";
  #         tlsCAFile = "/var/lib/acme/${domainName}/fullchain.pem";
  #         startTls = false;
  #         # postfix = {
  #         #   mailAttribute = "mail";
  #         #   uidAttribute = "cn";
  #         #   #  filter = "(cn=%s)";
  #         # };
  #       };
  #       fullTextSearch = {
  #         enable = true;
  #         # index new email as they arrive
  #         autoIndex = true;
  #         # this only applies to plain text attachments, binary attachments are never indexed
  #         indexAttachments = false;
  #         enforced = "yes";
  #         memoryLimit = 2000;
  #       };
  #     };
  #     systemd.extraConfig = ''
  #       DefaultTimeoutStartSec=600s
  #     '';
  #     services = {
  #       postfix = {
  #         enable = true;
  #       };
  #       # postfix.config.maillog_file = "/var/log/postfix.log";
  #       # postfix.masterConfig.postlog = {
  #       #   command = "postlogd";
  #       #   type = "unix-dgram";
  #       #   privileged = true;
  #       #   private = false;
  #       #   chroot = false;
  #       #   maxproc = 1;
  #       # };
  #       # fail2ban = {
  #       #   enable = true;
  #       #   maxretry = 5; # Observe 5 violations before banning an IP
  #       #   ignoreIP = whitelistSubnets;
  #       #   bantime = "24h"; # Set bantime to one day
  #       #   bantime-increment = {
  #       #     enable = true; # Enable increment of bantime after each violation
  #       #     formula = "ban.Time * math.exp(float(ban.Count+1)*banFactor)/math.exp(1*banFactor)";
  #       #     # multipliers = "1 2 4 8 16 32 64";
  #       #     maxtime = "168h"; # Do not ban for more than 1 week
  #       #     overalljails = true; # Calculate the bantime based on all the violations
  #       #   };
  #       #   jails = {
  #       #     apache-nohome-iptables = ''
  #       #       # Block an IP address if it accesses a non-existent
  #       #       # home directory more than 5 times in 10 minutes,
  #       #       # since that indicates that it's scanning.
  #       #       filter = apache-nohome
  #       #       action = iptables-multiport[name=HTTP, port="http,https"]
  #       #       logpath = /var/log/httpd/error_log*
  #       #       backend = auto
  #       #       findtime = 600
  #       #       bantime  = 600
  #       #       maxretry = 5
  #       #     '';
  #       #     postfix = ''
  #       #       port     = smtp,465,submission,imap,imaps,pop3,pop3s
  #       #       action = iptables-multiport[name=HTTP, port="smtp,465,submission,imap,imaps,pop3,pop3s"]
  #       #       logpath  = /var/log/postfix.log
  #       #       backend  = auto
  #       #       enabled  = true
  #       #       filter   = postfix[mode=auth]
  #       #       mode     = more
  #       #     '';
  #       #     # dovecot = ''
  #       #     #   port     = smtp,465,submission
  #       #     #   logpath  = /var/log/fail2ban.log
  #       #     #   backend  = auto
  #       #     #   enabled  = true
  #       #     #   mode     = more
  #       #     # '';
  #       #     # postfix-sasl = ''
  #       #     #   filter   = postfix[mode=auth]
  #       #     #   port     = smtp,465,submission,imap,imaps,pop3,pop3s
  #       #     #   logpath  = /var/log/fail2ban.log
  #       #     #   backend  = auto
  #       #     #   enabled  = true
  #       #     #   mode     = more
  #       #     # '';
  #       #   };
  #       # };
  #       # roundcube = {
  #       #   enable = true;
  #       #   # this is the url of the vhost, not necessarily the same as the fqdn of
  #       #   # the mailserver
  #       #   hostName = "mail.gv.coop";
  #       #   #  dicts =  [ en fr de ];
  #       #   extraConfig = ''
  #       #       # starttls needed for authentication, so the fqdn required to match
  #       #       # the certificate
  #       #       $config['smtp_server'] = "tls://mail.gv.coop";
  #       #       $config['smtp_user'] = "%u";
  #       #       $config['smtp_pass'] = "%p";
  #       #       # $config['oauth_provider'] = 'generic';
  #       #       # $config['oauth_provider_name'] = 'authentik';
  #       #       # $config['oauth_client_id'] = 'q3nTVQdV2ctY8GeNKvPuHokNa5RxT0VhZbVFCyY3';
  #       #       # $config['oauth_client_secret'] = '${oauthPassword}';
  #       #       # $config['oauth_auth_uri'] = 'https://authentik.resdigita.com/application/o/authorize/';
  #       #       # $config['oauth_token_uri'] = 'https://authentik.resdigita.com/application/o/token/';
  #       #       # $config['oauth_identity_uri'] = 'https://authentik.resdigita.com/application/o/userinfo/';
  #       #       # $config['oauth_scope'] = "openid dovecotprofile email";
  #       #       # $config['oauth_auth_parameters'] = [];
  #       #       # $config['oauth_identity_fields'] = ['email'];
  #       #       $config['generic_message_footer_html'] = '<a href="https://www.gv.coop">Les Grands Voisins .com comme communautés</a>';
  #       #       $config['session_samesite'] = "Lax";
  #       #       $config['support_url'] = 'https://www.gv.coop';
  #       #       $config['product_name'] = 'Roundcube Webmail des GV';
  #       #       $config['session_debug'] = true;
  #       #       $config['session_domain'] = 'mail.gv.coop';
  #       #       $config['login_password_maxlen'] = 4096;
  #       #   '';
  #       #   dicts = [ pkgs.aspellDicts.fr pkgs.aspellDicts.en ];
  #       #   maxAttachmentSize = 75;
  #       # };
  #       # memcached = {
  #       #   enable = true;
  #       #   # maxMemory = 256;
  #       #   # enableUnixSocket = true;
  #       #   # port = 11211;
  #       #   # listen = "[::1]";
  #       #   # user = "sogo";
  #       # };
  #       openssh = {
  #         enable = true;
  #       };

  #       # resolved = {
  #       #   enable = true;
  #       #   fallbackDns = [
  #       #       "8.8.8.8"
  #       #       "2001:4860:4860::8844"
  #       #     ];
  #       # };

  #     };
  #   };
  # };
  # containers.seafile = {
  #   autoStart = true;container@freeipa.service
  #   privateNetwork = true;
  #   hostAddress = "192.168.101.10";domainName
  #   localAddress = "192.168.101.11";
  #   hostAddress6 = "fd00::1";
  #   localAddress6 = "fd00::2";
  #   config = { config, pkgs, lib, ...  }: {
  #     environment.systemPackages = with pkgs; [
  #       ((vim_configurable.override {  }).customize{
  #         name = "vim";
  #         vimrcConfig.customRC = ''
  #           " your custom vimrc
  #           set mouse=a
  #           set nocompatible
  #           colo torte
  #           syntax on
  #           set tabstop     =2
  #           set softtabstop =2
  #           set shiftwidth  =2
  #           set expandtabafthttps://app.mailjet.com/campaigns/creation/278443/confirmer
  #           set autoindent
  #           set smartindent
  #           " ...
  #         '';
  #         }
  #       )
  #       (python311.withPackages my-python-packages)
  #       # python311Packages.bleach 
  #       # python311Packages.captcha domainName
  #       # python311Packages.cffi 
  #       # python311Packages.chardet 
  #       # python311Packages.devtools
  #       # python311Packages.django
  #       # python311Packages.django_4
  #       # python311Packages.django-formtools
  #       # python311Packages.django-picklefield
  #       # python311Packages.django-simple-captcha
  #       # python311Packages.django-statici18n
  #       # python311Packages.django-webpack-loader
  #       # python311Packages.djangorestframework
  #       # python311Packages.future
  #       # python311Packages.gunicorn
  #       # python311Packages.ldap3
  #       # python311Packages.markdown 
  #       # python311Packages.mysqlclient
  #       # python311Packages.mysqlclient
  #       # python311Packages.openpyxl 
  #       # python311Packages.pillow 
  #       # python311Packages.pip
  #       # python311Packages.pycryptodome
  #       # python311Packages.pyjwt
  #       # python311Packages.pysaml2
  #       # python311Packages.python-dateutil
  #       # python311Packages.python-ldap
  #       # python311Packages.qrcode 
  #       # python311Packages.requests
  #       # python311Packages.requests-oauthlib
  #       #python311
  #       #python311Full
  #       autoconf
  #       automake 
  #       busybox
  #       ceph-client
  #       cmake
  #       curl
  #       cyrus_sasl
  #       docker
  #       docker-compose
  #       flex 
  #       fuse
  #       gcc
  #       git
  #       glib
  #       intltool
  #       jansson
  #       libarchive
  #       libevent
  #       libgcc
  #       libglibutilcontainer@freeipa.service
  #       libmysqlclient
  #       libtool
  #       libuuid
  #       lynx
  #       mariadb
  #       mariadb-embedded
  #       openldap
  #       openssh
  #       openssl
  #       openssl
  #       re2c
  #       seafile-server
  #       sqlitecontainer@freeipa.service
  #       stdenv
  #       util-linux
  #       vala
  #       vim
  #       wget
  #       libxml2
  #       netcat
  #       unzip
  #       libffi
  #       pcre
  #       libz
  #       xz
  #       nginx
  #       pkg-config
  #       poppler_utils
  #       libmemcached
  #       sudo
  #       libjwt
  #     ];
  #     virtualisation.docker.enable = true;
  #     system.stateVersion = "24.05";
  #     nix.settings.experimental-features = "nix-command flakes";
  #     networking = {
  #       firewall.enable = false;
  #       # firewall = {
  #       #   enable = true;
  #       #   allowedTCPPorts = [ 80 443 ];
  #       # };
  #       # Use systemd-resolved inside the container
  #       useHostResolvConf = lib.mk  # containers.freeipa = {
  #   autoStart = true;

  #   privateNetwork = true;
  #   hostAddress = "192.168.107.10";
  #   localAddress = "192.168.107.11";
  #   hostAddress6 = "fa01::1";
  #   localAddress6 = "fa01::2";
  #   config = { config, pkgs, lib, ...  }: {
  #     environment.systemPackages = with pkgs; [
  #       ((vim_configurable.override {  }).customize{
  #         name = "vim";
  #         vimrcConfig.customRC = ''
  #           " your custom vimrc
  #           set mouse=a
  #           set nocompatible
  #           colo torte
  #           syntax on
  #           set tabstop     =2
  #           set softtabstop =2
  #           set shiftwidth  =2
  #           set expandtab
  #           set autoindent
  #           set smartindent
  #           " ...
  #         '';
  #         }
  #       )
  #       freeipa
  #     ];
  #     system.stateVersion = "24.05";
  #     nix.settings.experimental-features = "nix-command flakes";
  #     networking = {
  #       firewall.allowedTCPPorts = [ 3000 4971 4972 22 25 80 443 143 587 993 995 636 8443 9443 ];
  #       # useHostResolvConf = true;
  #       useHostResolvConf = lib.mkForce false;
  #     };
  #     time.timeZone = "Europe/Amsterdam";
  #   };
  # };Force false;
  #     };
  #     users.users.seafile = {
  #       isNormalUser = true;
  #       extraGroups = ["docker"];
  #     };
  #     services = {
  #       resolved.enable = true;
  #       seafile = {
  #         enable = true;
  #         adminEmail = "chris@mann.fr";
  #         initialAdminPassword = "aes3xaiThe7Ungi0iDe0aehongideik";
  #         ccnetSettings.General.SERVICE_URL = "https://seafile.resdigita.com";
  #       };
  #       mysql = {
  #         enable = true;
  #         package = pkgs.mariadb;
  #       };
  #     };
  #   };
  # };    



  # containers.filestash = {
  #   autoStart = true;
  #   privateNetwork = true;
  #   hostAddress = "192.168.101.10";
  #   localAddress = "192.168.101.11";
  #   hostAddress6 = "fd00::1";
  #   localAddress6 = "fd00::2";
  #   config = { config, pkgs, lib, ...  }: {
  #     environment.systemPackages = with pkgs; [
  #       ((vim_configurable.override {  }).customize{
  #         name = "vim";
  #         vimrcConfig.customRC = ''
  #           " your custom vimrc  # containers.freeipa = {
  #   autoStart = true;

  #   privateNetwork = true;
  #   hostAddress = "192.168.107.10";
  #   localAddress = "192.168.107.11";
  #   hostAddress6 = "fa01::1";
  #   localAddress6 = "fa01::2";
  #   config = { config, pkgs, lib, ...  }: {
  #     environment.systemPackages = with pkgs; [
  #       ((vim_configurable.override {  }).customize{
  #         name = "vim";
  #         vimrcConfig.customRC = ''
  #           " your custom vimrc
  #           set mouse=a
  #           set nocompatible
  #           colo torte
  #           syntax on
  #           set tabstop     =2
  #           set softtabstop =2
  #           set shiftwidth  =2
  #           set expandtab
  #           set autoindent
  #           set smartindent
  #           " ...
  #         '';
  #         }
  #       )
  #       freeipa
  #     ];
  #     system.stateVersion = "24.05";
  #     nix.settings.experimental-features = "nix-command flakes";
  #     networking = {
  #       firewall.allowedTCPPorts = [ 3000 4971 4972 22 25 80 443 143 587 993 995 636 8443 9443 ];
  #       # useHostResolvConf = true;
  #       useHostResolvConf = lib.mkForce false;
  #     };
  #     time.timeZone = "Europe/Amsterdam";
  #   };
  # };
  #           set mouse=a
  #           set nocompatible
  #           colo torte
  #           syntax on
  #           set tabstop     =2
  #           set softtabstop =2
  #           set shiftwidth  =2
  #           set expandtab
  #           set autoindent
  #           set smartindent
  #           " ...
  #         '';
  #         }
  #       )
  #       wget
  #       vim
  #       curl
  #       lynx
  #       docker-compose
  #       docker
  #       glib
  #       gotools
  #       libraw
  #       python311
  #       stdenv
  #       vips
  #       util-linux
  #     ];
  #     system.stateVersion = "24.05";
  #     nix.settings.experimental-features = "nix-command flakes";
  #     networking = {
  #       firewall = {
  #         enable = true;
  #         allowedTCPPorts = [ 80 443 8334 ];
  #       };
  #       # Use systemd-resolved inside the container
  #       useHostResolvConf = lib.mkForce false;
  #     };
  #     users.users.filestash = {
  #       isNormalUser = true;
  #       extraGroups = ["docker"];
  #     };
  #     services = {
  #       resolved.enable = true;
  #     };
  #   };
  # };


  # networking.nat = {
  #   enable = true;
  #   internalInterfaces = ["ve-+"];
  #   externalInterface = "ens3";
  #   # Lazy IPv6 connectivity for the container
  #   enableIPv6 = true;
  # };

  # networking.vlans."vlandav" = {
  #   id = 8;
  #   interface = "eno1";
  # };

  # To be able to ping containers from the host, it is necessary
  # to create a macvlan on the host on the VLAN 1 network.
  # networking.macvlans.mv-eno1-host = {
  #   interface = "eno1";
  #   mode = "bridge";
  # };
  # networking.interfaces.eno1.ipv4.addresses = lib.mkForce [];
  # networking.interfaces.eno1.ipv6.addresses = lib.mkForce [];
  # networking.interfaces.mv-eno1-host = {
  #   ipv4.addresses = [ { address = "192.168.8.1"; prefixLength = 24; } ];
  #   ipv6.addresses = [ { address = "fc00::8:8:1"; prefixLength = 96; } ];
  # };

  # networking.interfaces."vlandav" = {
  #   ipv4 = {
  #     addresses = [
  #       {
  #         address = "10.8.8.1";
  #         prefixLength = 24;
  #       }
  #     ];
  #   };
  #   ipv6 = {
  #     addresses = [
  #       {
  #         address = "fc00::8:8:1";
  #         prefixLength = 96;
  #       }
  #     ];
  #   };  
  # };

    # networking.firewall.trustedInterfaces = [
    #   "br0"
    # ];

    # networking.bridges = { br0 = { interfaces = [ "enp0s31f6" "ve-dav" ]; }; };
    # networking.interfaces.br0 = {
    #   ipv4.addresses = [ { address = "192.168.8.1"; prefixLength = 24; } ];
    #   ipv6.addresses = [ { address = "fc00::8:8:1"; prefixLength = 96; } ];
    # };

  # containers.dav = {
  #     # autoStart = true;


  #     #hostBridge = "mv-eno1-host";
  #     # privateNetwork = true;
  #     # forwardPorts = [{
  #     #   containerPort = 80;
  #     #   hostPort = 8080;
  #     #   protocol = "tcp";
  #     # }{
  #     #   containerPort = 443;
  #     #   hostPort = 8443;
  #     #   protocol = "tcp";
  #     # }];
  #     # interfaces = ["mv-eno1-host"];
  #     # localAddress6 = "fc00::8:8:8/96";
  #     # localAddress = "192.168.8.8/24";
  #     # # macvlans = ["eno1"];
  #     # hostAddress6 = "fc00::8:8:1";
  #     # hostAddress = "192.168.8.1";

  #     bindMounts = {
  #       "/usr/local/lib" = {hostPath="/usr/local/lib";};
  #     };


  #     config = { config, pkgs, ... }: {
  #       # nix.settings.experimental-features = "nix-command flakes";
  #       time.timeZone = "Europe/Amsterdam";
  #       system.stateVersion = "24.05";
  #       imports = [
  #         ./common.nix
  #       ];
  #       # networking.interfaces.mv-eno1-host = {
  #       #   ipv4.addresses = [ { address = "192.168.8.8"; prefixLength = 24; } ];
  #       #   ipv6.addresses = [ { address = "fc00::8:8:8"; prefixLength = 96; } ];
  #       # };
  #       # environment.systemPackages = with pkgs; [
  #       #   httpd
  #       # ];
  #       services.httpd = {
  #         enable = true;
  #         # enablePHP = false;
  #         # adminAddr = "chris@lesgrandsvoisins.com";
  #         extraModules = [ "proxy" "proxy_http" "dav"
  #           { name = "auth_openidc"; path = "/usr/local/lib/modules/mod_auth_openidc.so"; }
  #         ];
  #         # virtualHosts = {
  #         #   "localhost" = {
  #         #      *.listen = 88
  #         #   };
  #         # };
  #         virtualHosts."localhost" = {
  #           listen = [{
  #             ip = "*";
  #             port = 8080;
  #           }];
  #           documentRoot = "/var/dav/";
  #           extraConfig = ''
  #             DavLockDB /tmp/DavLock
  #             OIDCProviderMetadataURL https://authentik.lesgrandsvoisins.com/application/o/dav/.well-known/openid-configuration
  #             OIDCClientID V7p2o3hX6Im6crzdExLI1lb81zMJEjDO3mO3rNBk
  #             OIDCClientSecret Qgi9BFz7UOzwsJUAtN5Pa28sUL4oyrbkv2gvpsELMUgksPoLReS2eu9aHqJezyyoquJV02IX0UFPB8cvIB8uC9OW42MC4q8qswVeuM6aOUSvEXas1lQKnwAxad5sWrXc
  #             OIDCRedirectURI https://dav.desgv.com/chris/redirect_uri
  #             OIDCCryptoPassphrase JoWT5Mz1DIzsgI3MT2GH82aA6Xamp2ni
  #             OIDCXForwardedHeaders   X-Forwarded-Port X-Forwarded-Host X-Forwarded-Proto

  #             <Location "/chris/">
  #               AuthType openid-connect
  #               Require valid-user
  #             </Location>

  #           <Directory "/var/dav/">

  #             Dav On


  #             # AuthName DAV
  #             # AuthType oauth2
  #             # OAuth2TokenVerify introspect https://authentik.lesgrandsvoisins.com/application/o/introspect/ introspect.ssl_verify=false&introspect.auth=client_secret_post&client_id=V7p2o3hX6Im6crzdExLI1lb81zMJEjDO3mO3rNBk&client_secret=Qgi9BFz7UOzwsJUAtN5Pa28sUL4oyrbkv2gvpsELMUgksPoLReS2eu9aHqJezyyoquJV02IX0UFPB8cvIB8uC9OW42MC4q8qswVeuM6aOUSvEXas1lQKnwAxad5sWrXc

  #             # Require oauth2_claim .*chris@lesgrandsvoinsins.com.*
  #             # require valid-user 

  #             # AuthType Basic
  #             # 
  #             # AuthUserFile /var/www/.htpasswd
  #             # require valid-user 

  #             # <LimitExcept GET HEAD OPTIONS>
  #             #   require user admin
  #             # </LimitExcept>
  #           </Directory>
  #           '';
  #         };
  #       };
  #     };
  # };

  # containers.roundcube = {
  #   autoStart = true;
  #   privateNetwork = true;

  # };

  # containers.crabfit = {
  #   autoStart = true;
  #   privateNetwork = true;
  #   config = { config, pkgs, ... }: {
  #     users.users.crabfit = {
  #        isNormalUser = true;
  #        createHome = true;
  #        useDefaultShell = true;
  #        extraGroups = ["docker"];
  #     };
  #     virtualisation.docker = {
  #       enable = true;
  #       rootless = {
  #         enable = true;
  #         setSocketVariable = true;
  #       };
  #     };
  #     networking.firewall.allowedTCPPorts = [ 22 25 80 443 143 587 993 995 636 8443 9443 ];
  #     nix.settings.experimental-features = "nix-command flakes";
  #     time.timeZone = "Europe/Amsterdam";
  #     system.stateVersion = "24.05";
  #     environment.sessionVariables = rec {
  #       NEXT_PUBLIC_API_URL = "apicrabfit.resdigita.com";
  #       FRONTEND_URL =	"https: //crabfit.resdigita.com";
  #     };
  #     environment.systemPackages = with pkgs; [
  #       ((vim_configurable.override {  }).customize{
  #         name = "vim";
  #         vimrcConfig.customRC = ''
  #           " your custom vimrc
  #           set mouse=a
  #           set nocompatible
  #           colo torte
  #           syntax on
  #           set tabstop     =2
  #           set softtabstop =2
  #           set shiftwidth  =2
  #           set expandtab
  #           set autoindent
  #           set smartindent
  #           " ...
  #         '';
  #         }
  #       )
  #       curl
  #       wget
  #       lynx
  #       dig    
  #       tmux
  #       bat
  #       cowsay
  #       git
  #       lzlib
  #       killall
  #       pwgen
  #       gettext
  #       sqlite
  #       nodePackages.vercel
  #       flyctl
  #       docker
  #       busybox
  #     ];
  #   };
  # };
  # containers.seafile = {
  #   autoStart = true;
  #   privateNetwork = true;
  #   hostAddress = "192.168.100.10";
  #   localAddress = "192.168.100.11";
  #   hostAddress6 = "fc00::1";
  #   localAddress6 = "fc00::2";
  #   config = { config, pkgs, ... }: {
  #     environment.systemPackages = with pkgs; [
  #       ((vim_configurable.override {  }).customize{
  #         name = "vim";
  #         vimrcConfig.customRC = ''
  #           " your custom vimrc
  #           set mouse=a
  #           set nocompatible
  #           colo torte
  #           syntax on
  #           set tabstop     =2
  #           set softtabstop =2
  #           set shiftwidth  =2
  #           set expandtab
  #           set autoindent
  #           set smartindent
  #           " ...
  #         '';
  #         }
  #       )
  #       nginx
  #       lynx
  #       python311
  #       python311Packages.setuptools
  #       python311Packages.pip memcached libmemcached pwgen sqlite
  #       wget curl
  #       mariadb
  #       seafile-server
  #       seafile-shared
  #       python311Packages.seaserv
  #       seahub
  #       ];
  #     system.stateVersion = "24.05";
  #     nix.settings.experimental-features = "nix-command flakes";
  #     networking = {
  #       firewall = {
  #         enable = true;
  #         allowedTCPPorts = [ 8000 8082 ];
  #       };
  #       # Use systemd-resolved inside the container
  #       # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
  #       useHostResolvConf = lib.mkForce false;
  #     };
  #     users.users.seafile = {
  #       isNormalUser = true;
  #     };
  #     services = {
  #       resolved.enable = true;
  #       mysql = {
  #         enable = true;
  #         package = pkgs.mariadb;
  #         ensureUsers = [
  #           {
  #             name = "seafile";
  #             ensurePermissions = {
  #               "seafile.*" = "ALL PRIVILEGES";
  #             };
  #           }
  #         ];
  #         ensureDatabases = ["seafile"];
  #         initialDatabases = [{name = "seafile";}];
  #       };
  #       nginx = {
  #         enable = true;
  #         virtualHosts."192.168.100.11" = {
  #           locations."/media" = {
  #              root = "/opt/seafile/seafile-server-latest/seahub";
  #           };
  #           locations."/" = {
  #            proxyPass = "http://192.168.100.11:8000";
  #            extraConfig = ''
  #              proxy_set_header   Host $host;
  #              proxy_set_header   X-Real-IP $remote_addr;
  #              proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
  #              proxy_set_header   X-Forwarded-Host $server_name;
  #              proxy_read_timeout  1200s;

  #              # used for view/edit office file via Office Online Server
  #              client_max_body_size 0;

  #              access_log      /var/log/nginx/seahub.access.log; # seafileformat;
  #              error_log       /var/log/nginx/seahub.error.log;
  #            '';
  #           };
  #           locations."/seafhttp" = {
  #            proxyPass = "http://192.168.100.11:8082";
  #            extraConfig = ''
  #              rewrite ^/seafhttp(.*)$ $1 break;
  #               proxy_pass http://127.0.0.1:8082;
  #               client_max_body_size 0;
  #               proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;

  #               proxy_connect_timeout  36000s;
  #               proxy_read_timeout  36000s;
  #               proxy_send_timeout  36000s;

  #               send_timeout  36000s;

  #               access_log      /var/log/nginx/seafhttp.access.log; # seafileformat;
  #               error_log       /var/log/nginx/seafhttp.error.log;
  #            '';
  #           };
  #         };
  #       };
  #       # seafile = {
  #       #     enable = true;
  #       #     adminEmail = "chris@mann.fr";
  #       #     initialAdminPassword = "Ahs3sae1";
  #       #     seafileSettings = {
  #       #       # https://manual.seafile.com/config/seafile-conf/
  #       #       fileserver.port = 8082;
  #       #       fileserver.host = "192.168.100.11";
  #       #     };
  #       #     # seahubExtraConf = ''
  #       #     #   ENABLE_OAUTH = True

  #       #     #   # If create new user when he/she logs in Seafile for the first time, defalut `True`.
  #       #     #   OAUTH_CREATE_UNKNOWN_USER = True

  #       #     #   # If active new user when he/she logs in Seafile for the first time, defalut `True`.
  #       #     #   OAUTH_ACTIVATE_USER_AFTER_CREATION = True

  #       #     #   # Usually OAuth works through SSL layer. If your server is not parametrized to allow HTTPS, some method will raise an "oauthlib.oauth2.rfc6749.errors.InsecureTransportError". Set this to `True` to avoid this error.
  #       #     #   OAUTH_ENABLE_INSECURE_TRANSPORT = True

  #       #     #   # Client id/secret generated by authorization server when you register your client application.
  #       #     #   OAUTH_CLIENT_ID = "seafile"
  #       #     #   OAUTH_CLIENT_SECRET = "${seafilePassword}"

  #       #     #   # Callback url when user authentication succeeded. Note, the redirect url you input when you register your client application MUST be exactly the same as this value.
  #       #     #   OAUTH_REDIRECT_URL = 'https://seafile.resdigita.com/oauth/callback/'

  #       #     #   # The following should NOT be changed if you are using Github as OAuth provider.
  #       #     #   OAUTH_PROVIDER_DOMAIN = 'keycloak.resdigita.com:10443'
  #       #     #   OAUTH_AUTHORIZATION_URL = 'https://keycloak.resdigita.com:10443/realms/master/protocol/openid-connect/auth'
  #       #     #   OAUTH_TOKEN_URL = 'https://keycloak.resdigita.com:10443/realms/master/protocol/openid-connect/token'
  #       #     #   OAUTH_USER_INFO_URL = 'https://keycloak.resdigita.com:10443/realms/master/protocol/openid-connect/userinfo'
  #       #     #   OAUTH_SCOPE = ["profile","email']
  #       #     #   OAUTH_ATTRIBUTE_MAP = {
  #       #     #       "id": (True, "email"),  # Please keep the 'email' option unchanged to be compatible with the login of users of version 11.0 and earlier.
  #       #     #       "name": (False, "name"),
  #       #     #       "email": (False, "contact_email"),
  #       #     #       "uid": (True, "uid"),   # Since 11.0 version, Seafile use 'uid' as the external unique identifier of the user.
  #       #     #                               # Different OAuth systems have different attributes, which may be: 'uid' or 'username', etc.
  #       #     #                               # If there is no 'uid' attribute, do not configure this option and keep the 'email' option unchanged,
  #       #     #                               # to be compatible with the login of users of version 11.0 and earlier.
  #       #     #   }
  #       #     # '';
  #       #     ccnetSettings = {
  #       #       # https://manual.seafile.com/config/ccnet-conf/
  #       #       General.SERVICE_URL = "http://192.168.100.11:8082";
  #       #     };
  #       # };
  #     };
  #   };
  # };
}