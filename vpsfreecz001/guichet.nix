{ config, pkgs, lib, ... }:
{
  users.users."guichet" = {
      isNormalUser = true;
  };
  # home-manager.users.fossil = {pkgs, ...}: { # 2025-10-18
  #   home.packages = with pkgs; [ 
  #     go
  #     cope
  #     python311
  #   ];
  #   home.stateVersion = "25.05";
  #   programs.home-manager.enable = true;
  # };
  # systemd.services.guichet = { # 2025-10-18
  #   enable = true;
  #   wantedBy = ["default.target"];
  #   script = "/home/guichet/guichet/guichet";
  #   description = "Guicher, Self-Service LDAP account admin";
  #   serviceConfig = {
  #     WorkingDirectory = "/home/guichet/guichet";
  #     User = "guichet";
  #     Group = "users";
  #   };
  # };
}
