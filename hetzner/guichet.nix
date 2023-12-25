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
  security.sudo.extraConfig = ''
    Cmnd_Alias FILEBROWSER_CMDS = /run/current-system/sw/bin/systemctl --user start filebrowser, /run/current-system/sw/bin/systemctl --user stop filebrowser, /run/current-system/sw/bin/systemctl --user status filebrowser, /run/current-system/sw/bin/systemctl --restart start filebrowser
    filebrowser ALL=(ALL) NOPASSWD: FILEBROWSER_CMDS
  '';
  systemd.user.services."filebrowser@" = {
    enable = true;
    wantedBy = ["default.target"];
    scriptArgs = "%u %i";
    # preStart = "mkdir -p /opt/filebrowser/dbs/%u/%i; touch /opt/filebrowser/dbs/%u/%i/temoin.txt";
    script = "/opt/filebrowser/dbs/filebrowser.sh $filebrowser_user $filebrowser_database";
    description = "File Browser, un interface web à un système de fichiers pour %u on %i";
    environment = {
      filebrowser_user = "%u";
      filebrowser_database = "%i";
    };
    # serviceConfig = {
    #   WorkingDirectory = " /opt/filebrowser/dbs/";
    #   User = "%u";
    #   Group = "wwwrun";
    # };
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
