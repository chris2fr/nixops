{ config, pkgs, lib, ... }:

let 
  mannchriRsaPublic = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/mailserver/vars/cert-public.nix));
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz";
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];
  users.users.aaa = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ mannchriRsaPublic ];
  };
  home-manager.users.aaa = {pkgs, ...}: {
    nixpkgs = {
      config = {
        allowUnfree = true;
        allowUnfreePredicate = (_: true);
      };
    };
    home.stateVersion = "23.05";
    programs.home-manager.enable = true;
    home.packages = with pkgs; [ 
      nodejs_20
      mongodb
    ];
  };
  users.users.ghostio = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ mannchriRsaPublic ];
  }
  home-manager.users.ghostio = {pkgs, ...}: {
    home.stateVersion = "23.05";
    programs.home-manager.enable = true;
    home.packages = with pkgs; [ 
      mariadb
      nodejs_20
    ];
  };
}