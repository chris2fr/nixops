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
  systemd.services.crabfitfront = {
    enable = true;
    wantedBy = ["default.target"];
    script = "${pkgs.yarn}/bin/yarn run start -p 3080";
    description = "Crab.fit front-end NextJS";
    serviceConfig = {
      WorkingDirectory = "/home/crabfit/crab.fit/frontend/";
      User = "crabfit";
      Group = "users";
    };
  };
  systemd.services.crabfitback = {
    enable = true;
    wantedBy = ["default.target"];
    script = "/home/crabfit/crab.fit/api/target/release/crabfit-api";
    description = "Crab.fit back in Rust avec Postgres";
    serviceConfig = {
      WorkingDirectory = "/home/crabfit/crab.fit/api/target/release/";
      User = "crabfit";
      Group = "users";
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
