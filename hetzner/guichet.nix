{ config, pkgs, lib, ... }:
{
  users.users."guichet" = {
      isNormalUser = true;
  };
  home-manager.users.fossil = {pkgs, ...}: {
    home.packages = with pkgs; [ 
      go
      cope
      python311
    ];
    home.stateVersion = "23.05";
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
}
