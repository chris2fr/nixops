{ config, pkgs, lib, ... }:

let 
in
{
  
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
    home.stateVersion = "24.05";
    programs.home-manager.enable = true;
  };
    # systemd.services.wagtail = {
    #   description = "Les Grands Voisins Wagtail Website";
    #   after = [ "network.target" ];
    #   wantedBy = [ "multi-user.target" ];
    #   serviceConfig = {
    #     WorkingDirectory = "/home/wagtail/wagtail-lesgv/";
    #     ExecStart = ''/home/wagtail/venv/bin/gunicorn --env WAGTAIL_ENV='production' --access-logfile access.log --chdir /home/wagtail/wagtail-lesgv --workers 3 --bind unix:/var/lib/wagtail/wagtail-lesgv.sock lesgv.wsgi:application'';
    #     Restart = "always";
    #     RestartSec = "10s";
    #     User = "wagtail";
    #     Group = "users";
    #   };
    #   unitConfig = {
    #     StartLimitInterval = "1min";
    #   };
    # };

}