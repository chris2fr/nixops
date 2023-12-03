{ config, pkgs, lib, ... }:
let
in
{
  networking.nat = {
    enable = true;
    internalInterfaces = ["ve-+"];
    externalInterface = "ens3";
    # Lazy IPv6 connectivity for the container
    enableIPv6 = true;
  };

  containers.wagtail = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.11";
    hostAddress6 = "fc00::1";
    localAddress6 = "fc00::2";

    config = { config, pkgs, ... }: {
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
        ];

      networking = {
        firewall = {
          enable = false;
          allowedTCPPorts = [ 80 443 ];
        };
        # Use systemd-resolved inside the container
        useHostResolvConf = lib.mkForce false;
      };
        
      services.resolved.enable = true;

      services.postgresql = {
        enable = true;
        enableTCPIP = true;
        ensureDatabases = [
          "wagtail"
          "previous"
          "fairemain"
        ];
        ensureUsers = [
          {
            name = "wagtail";
            ensurePermissions = {
              "DATABASE \"wagtail\"" = "ALL PRIVILEGES";
              "DATABASE \"previous\"" = "ALL PRIVILEGES";
              "DATABASE \"fairemain\"" = "ALL PRIVILEGES";
              "ALL TABLES IN SCHEMA public" = "ALL PRIVILEGES";
            };
          }
        ];
      };
      users.users.wagtail.isNormalUser = true;
      systemd.services.wagtail = {
        description = "Les Grands Voisins Wagtail Website";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          WorkingDirectory = "/home/wagtail/wagtail-lesgv/";
          ExecStart = ''/home/wagtail/venv/bin/gunicorn --env WAGTAIL_ENV='production' --access-logfile access.log --chdir /home/wagtail/wagtail-lesgv --workers 3 --bind unix:/var/lib/wagtail/wagtail-lesgv.sock lesgv.wsgi:application'';
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