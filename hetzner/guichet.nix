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
      Group = "users";
    };
  };
  systemd.timers."guichet-wwwrun-fix-perms" = {
  wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "5m";
      Unit = "guichet-wwwrun-fix-perms.service";
    };
  };

  systemd.services."guichet-wwwrun-fix-perms" = {
    script = ''
      set -eu
      ${pkgs.coreutils}/bin/chown -R wwwrun:users /var/www/{secret,dav} ; ${pkgs.coreutils}/bin/chmod g+w /var/www/{secret,dav}
    '';
    serviceConfig = {
      Type = "oneshot";
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
