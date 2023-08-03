{ config, pkgs, lib, ... }:
let 
  mannchriRsaPublic = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAuBWybYSoR6wyd1EG5YnHPaMKE3RQufrK7ycej7avw3Ug8w8Ppx2BgRGNR6EamJUPnHEHfN7ZZCKbrAnuP3ar8mKD7wqB2MxVqhSWvElkwwurlijgKiegYcdDXP0JjypzC7M73Cus3sZT+LgiUp97d6p3fYYOIG7cx19TEKfNzr1zHPeTYPAt5a1Kkb663gCWEfSNuRjD2OKwueeNebbNN/OzFSZMzjT7wBbxLb33QnpW05nXlLhwpfmZ/CVDNCsjVD1+NXWWmQtpRCzETL6uOgirhbXYW8UyihsnvNX8acMSYTT9AA3jpJRrUEMum2VizCkKh7bz87x7gsdA4wF0/w== rsa-key-20220407";
in
{
  nix.settings.experimental-features = "nix-command flakes";
  imports = [
    ./vpsadminos.nix
    ./httpd.nix
    ./mailserver.nix
    ./guichet.nix
    ./postgresql.nix
#    ./users.nix
    ./wagtail.nix
    ./common.nix # Des configurations communes pratiques
    <home-manager/nixos>
  ];

#  virtualisation.docker.enable = true;
#  users.extraGroups.docker.members = [ "mannchri" ];
#  pkgs.dockerTools.pullImage = {
#    imageName = "dnknth/ldap-ui";
#    finalImageTag = "latest";
#    imageDigest = "sha256:c34a8feb5978888ebe5ff86884524b30759469c91761a560cdfe968f6637f051";
#    sha256 = "";
#  };

  users.users = rec {
    fossil = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [ mannchriRsaPublic ];
    };
    mannchri = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [ mannchriRsaPublic ];
      extraGroups = [ "wheel" "networkmanager" ];
    };
  };
  home-manager.users.fossil = {pkgs, ...}: {
    home.packages = with pkgs; [ 
      fossil
    ];
    home.stateVersion = "23.05";
    programs.home-manager.enable = true;
  };
  home-manager.users.mannchri = {pkgs, ...}: {
    home.packages = [ pkgs.atool pkgs.httpie ];
    home.stateVersion = "23.05";
    programs.home-manager.enable = true;
    programs.vim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [ vim-airline ];
      settings = { ignorecase = true; tabstop = 2; };
      extraConfig = ''
        set mouse=a
        set nocompatible
        colo torte
        syntax on
        set tabstop     =2
        set softtabstop =2
        set shiftwidth  =2
        set expandtab
        set autoindent
        set smartindent
      '';
    };
  };

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "no";
  #users.extraUsers.root.openssh.authorizedKeys.keys =
  #  [ "..." ];
  
  networking.firewall.allowedTCPPorts = [ 80 443 636 ];

  systemd.extraConfig = ''
    DefaultTimeoutStartSec=600s
  '';

  time.timeZone = "Europe/Amsterdam";

  system.stateVersion = "23.05";

  environment.sessionVariables = rec {
    EDITOR="vim";
    WAGTAIL_ENV = "production";
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "contact@lesgrandsvoisins.com";
  };
}