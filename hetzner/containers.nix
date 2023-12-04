{ config, pkgs, lib, ... }:
let
in
{
  # networking.nat = {
  #   enable = true;
  #   internalInterfaces = ["ve-+"];
  #   externalInterface = "ens3";
  #   # Lazy IPv6 connectivity for the container
  #   enableIPv6 = true;
  # };

  containers.dav = {
      autoStart = true;
      config = { config, pkgs, ... }: {
        nix.settings.experimental-features = "nix-command flakes";
        time.timeZone = "Europe/Amsterdam";
        system.stateVersion = "23.11";
        imports = [
          ./common.nix
        ];
        environment.systemPackages = with pkgs; [
          httpd
        ];
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
     };
    config = { config, pkgs, ... }: {
      users.users.wagtail.uid = 1003;
      # users.groups.users.gid = 1003;
      nix.settings.experimental-features = "nix-command flakes";
      time.timeZone = "Europe/Amsterdam";
      system.stateVersion = "23.11";
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
            postgresql
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
      #   ensureUsers = [
      #     {
      #       name = "wagtail";
      #       ensurePermissions = {
      #         "DATABASE \"wagtail\"" = "ALL PRIVILEGES";
      #         "DATABASE \"previous\"" = "ALL PRIVILEGES";
      #         "DATABASE \"fairemain\"" = "ALL PRIVILEGES";
      #         "ALL TABLES IN SCHEMA public" = "ALL PRIVILEGES";
      #       };
      #     }
      #   ];
      # };
      users.users.wagtail.isNormalUser = true;
      systemd.services.wagtail = {
        description = "Les Grands Voisins Wagtail Website";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          WorkingDirectory = "/home/wagtail/wagtail-lesgv/";
          # ExecStart = ''/home/wagtail/venv/bin/gunicorn --env WAGTAIL_ENV='production' --access-logfile access.log --chdir /home/wagtail/wagtail-lesgv --workers 3 --bind unix:/var/lib/wagtail/wagtail-lesgv.sock lesgv.wsgi:application'';
          ExecStart = ''/home/wagtail/venv/bin/gunicorn --env WAGTAIL_ENV='production' --access-logfile access.log --chdir /home/wagtail/wagtail-lesgv --workers 3 --bind 127.0.0.1:8000 lesgv.wsgi:application'';
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
}