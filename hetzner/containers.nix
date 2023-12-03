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
      time.timeZone = "Europe/Amsterdam";
      system.stateVersion = "23.05";

      networking = {
        firewall = {
          enable = true;
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
    home-manager.users.wagtail = {pkgs, ...}: {
      home.packages = with pkgs; [ 
        python311
        python311Packages.pillow
        python311Packages.gunicorn
        python311Packages.pip
        libjpeg
        zlib
        libtiff
        freetype
        python311Packages.venvShellHook
      ];
      home.stateVersion = "23.05";
      programs.home-manager.enable = true;
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