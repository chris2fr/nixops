  systemd.tmpfiles.rules = [
    "d /var/local/ffdncoin 0755 ffdncoin users"
  ];
  users.users.ffdncoin = {
    isNormalUser = true;
    uid = 11111;
  };
  containers.ffdncoin = {
    autoStart = true;
    bindMounts = { 
      "/var/local/ffdncoin" = { 
        hostPath = "/var/local/ffdncoin";
        isReadOnly = false; 
      }; 
    };
    config = { config, pkgs, ... }: {
      networking.firewall.allowedTCPPorts = [ 22 25 80 443 143 587 993 995 636 ]; 
      users.users.ffdncoin.uid = 1003;
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
        python311Packages.manimpango
        python311Packages.pip
        python311Packages.devtools
        python311Packages.django-auth-ldap
        python311Packages.pq
        python311Packages.aiosasl
        python311Packages.pylibjpeg-libjpeg
        python311Packages.virtualenv
        ];
      users.users.ffdncoin = {
        isNormalUser = true;
        uid = 11111;
      };
      systemd.tmpfiles.rules = [
        "d /var/local/ffdncoin 0755 ffdncoin users"
        "d /var/local/ffdncoin/settings_local.py 0644 ffdncoin users"
      ];

      # systemd.services.ffdncoin = {
      #   description = "ResDigita FFDN Coin";
      #   after = [ "network.target" ];
      #   wantedBy = [ "multi-user.target" ];
      #   serviceConfig = {
      #     WorkingDirectory = "/var/local/ffdncoin/";
      #     ExecStart = ''/var/local/ffdncoin/venv/bin/gunicorn --env LDAP_ACTIVATE='true' --access-logfile /var/log/wagtail/access.log --error-logfile /var/log/wagtail/error.log --chdir /home/wagtail/wagtail-lesgv --workers 12 --bind 127.0.0.1:8000 lesgv.wsgi:application'';
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
