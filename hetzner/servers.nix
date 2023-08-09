{ config, pkgs, lib, ... }:

let 
  mannchriRsaPublic = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/mailserver/vars/cert-public.nix));
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz";
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];
  ## Apostrophe CMS
  users.users.aaa = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ mannchriRsaPublic ];
  };
  home-manager.users.aaa = {pkgs, ...}: {
    # I'll use Mongo in a Docker Container
#    nixpkgs = {
#      config = {
#        allowUnfree = true;
#        allowUnfreePredicate = (_: true);
#      };
#    };
    home.stateVersion = "23.05";
    programs.home-manager.enable = true;
    home.packages = with pkgs; [ 
      nodejs_20
#      mongodb
    ];
  };
  ## GHOSTIO
  users.users.ghostio = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ mannchriRsaPublic ];
  };
  home-manager.users.ghostio = {pkgs, ...}: {
    home.stateVersion = "23.05";
    programs.home-manager.enable = true;
    home.packages = with pkgs; [ 
      mariadb
      nodejs_20
    ];
  };
  ## ODOO FOR
  users.users.odoofor = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ mannchriRsaPublic ];
  };
  home-manager.users.odoofor = {pkgs, ...}: {
    home.stateVersion = "23.05";
    programs.home-manager.enable = true;
    home.packages = with pkgs; [ 
      postgresql
      python311
      python311Packages
    ];
  };
  ## ODOO THREE
  users.users.odoothree = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ mannchriRsaPublic ];
  };
  home-manager.users.odoothree = {pkgs, ...}: {
    home.stateVersion = "23.05";
    programs.home-manager.enable = true;
    home.packages = with pkgs; [ 
      postgresql
      python311
      python311Packages
    ];
  };
  ## ODOO TOO
  users.users.odootoo = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ mannchriRsaPublic ];
  };
  home-manager.users.odootoo = {pkgs, ...}: {
    home.stateVersion = "23.05";
    programs.home-manager.enable = true;
    home.packages = with pkgs; [ 
      postgresql
      python311
      python311Packages
    ];
  };
  ## ODOO
  users.users.odoo = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ mannchriRsaPublic ];
  };
#  home-manager.users.odoo = {pkgs, ...}: {
#    home.stateVersion = "23.05";
#    programs.home-manager.enable = true;
#    home.packages = with pkgs; [ 
#      postgresql
#      python311
#      python311Packages
#    ];
#  };
  # Docker
  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
}