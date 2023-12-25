{ config, pkgs, lib, ... }:
{
  users.users."guichet" = {
      isNormalUser = true;
      extraGroups = [ "wwwrun" ];
  };
  home-manager.users.fossil = {pkgs, ...}: {
    home.packages = with pkgs; [ 
      go
      cope
      python311
    ];
    home.stateVersion = "23.11";
    programs.home-manager.enable = true;
  };
  systemd.services.guichet = {
    enable = true;
    wantedBy = ["default.target"];
    script = "/home/guichet/guichet/guichet";
    description = "Guichet, Self-Service LDAP account admin";
    serviceConfig = {
      WorkingDirectory = "/home/guichet/guichet";
      User = "guichet";
      Group = "wwwrun";
    };
  };
  systemd.services.filebrowser = {
    enable = true;
    wantedBy = ["default.target"];
    script = "/run/current-system/sw/bin/filebrowser";
    description = "File Browser, un interface web à un système de fichiers";
    serviceConfig = {
      WorkingDirectory = "/home/filebrowser";
      User = "filebrowser";
      Group = "wwwrun";
    };
  };
  systemd.timers."guichet-wwwrun-fix-perms" = {
  wantedBy = [ "timers.target" ];
    timerConfig = {
      OnUnitActiveSec = "5m";
      Unit = "guichet-wwwrun-fix-perms.service";
    };
  };

  systemd.services."guichet-wwwrun-fix-perms" = {
    script = ''
      set -eu
      ${pkgs.coreutils}/bin/chown -R wwwrun:users /var/www/{secret,dav} 
      ${pkgs.coreutils}/bin/chown -R guichet:wwwrun /home/guichet/guichet/static
      ${pkgs.coreutils}/bin/chmod -R g+w /var/www/{secret,dav}
    '';
    serviceConfig = {
      User = "root";
    };
  };
  # systemd.services.guichetwork = {
  #   enable = true;
  #   wantedBy = ["default.target"];
  #   script = "/home/guichet/guichet2/guichet";
  #   description = "Guichet, Self-Service LDAP account admin";
  #   serviceConfig = {
  #     WorkingDirectory = "/home/guichet/guichet2";
  #     User = "guichet";
  #     Group = "users";
  #   };
  # };
}
