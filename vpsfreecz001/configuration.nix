{ config, pkgs, lib, ... }:
let 
  mannchriRsaPublic = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAuBWybYSoR6wyd1EG5YnHPaMKE3RQufrK7ycej7avw3Ug8w8Ppx2BgRGNR6EamJUPnHEHfN7ZZCKbrAnuP3ar8mKD7wqB2MxVqhSWvElkwwurlijgKiegYcdDXP0JjypzC7M73Cus3sZT+LgiUp97d6p3fYYOIG7cx19TEKfNzr1zHPeTYPAt5a1Kkb663gCWEfSNuRjD2OKwueeNebbNN/OzFSZMzjT7wBbxLb33QnpW05nXlLhwpfmZ/CVDNCsjVD1+NXWWmQtpRCzETL6uOgirhbXYW8UyihsnvNX8acMSYTT9AA3jpJRrUEMum2VizCkKh7bz87x7gsdA4wF0/w== rsa-key-20220407";
in
{
  nix.settings.experimental-features = "nix-command flakes";
  # nixpkgs.config.permittedInsecurePackages = [
  #               "jitsi-meet-1.0.8043"
  #             ];
  imports = [
    ./vpsadminos.nix
    ./httpd.nix
    # ./mailserver.nix # 2025-10-18
    ./guichet.nix
    ./postgresql.nix
#    ./users.nix
    ./wagtail.nix
    ./common.nix # Des configurations communes pratiques
    # <home-manager/nixos> # 2025-10-18
  ];
virtualisation.docker.enable = true;
virtualisation.podman.enable = true;
users.extraGroups.docker.members = [ "mannchri" ];
#  pkgs.dockerTools.pullImage = {
#    imageName = "dnknth/ldap-ui";
#    finalImageTag = "latest";
#    imageDigest = "sha256:c34a8feb5978888ebe5ff86884524b30759469c91761a560cdfe968f6637f051";
#    sha256 = "";
#  };
  # nixpkgs.dockerTools.pullImage = {
  #   imageName = "machines/filestash";
  #   imageDigest =
  #     "sha256:709bf7f6f021b48c5fb9982f74cd9c276c29dd404215eebc268ec9c9e1a76ca5";
  #   os = "linux";
  #   arch = "x86_64";
  # };

  # services.jitsi-meet = {
  #   enable = true;
  #   hostName = "jitsi.grandzine.org";
  #   interfaceConfig = {
  #     SHOW_JITSI_WATERMARK = false;
  #   };
  #   config = {
  #     prejoinPageEnabled = true;
  #     disableModeratorIndicator = true;
  #   };
  # };

  users.users = {
    fossil = rec {
      extraGroups = [ "docker" ];
      isNormalUser = true;
      openssh.authorizedKeys.keys = [ mannchriRsaPublic ];
    };
    filestash = rec {
      isNormalUser = true;
      extraGroups = [ "docker" ];
      openssh.authorizedKeys.keys = [ mannchriRsaPublic ];
    };
    mannchri = rec {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [ mannchriRsaPublic ];
      extraGroups = [ "wheel" "networkmanager" "docker" ];
    };
  };
  # home-manager.users = {
  #   # fossil = {pkgs, ...}: {
  #   #   home.packages = with pkgs; [ 
  #   #     fossil
  #   #   ];
  #   #   home.stateVersion = "25.05";
  #   #   programs.home-manager.enable = true;
  #   # };
  #   mannchri = {pkgs, ...}: {

  #     home.packages = [ pkgs.atool pkgs.httpie ];
  #     home.stateVersion = "25.05";
  #     programs.home-manager.enable = true;
  #     programs.vim = {
  #       enable = true;
  #       plugins = with pkgs.vimPlugins; [ vim-airline ];
  #       settings = { ignorecase = true; tabstop = 2; };
  #       extraConfig = ''
  #         set mouse=a
  #         set nocompatible
  #         colo torte
  #         syntax on
  #         set tabstop     =2
  #         set softtabstop =2
  #         set shiftwidth  =2
  #         set expandtab
  #         set autoindent
  #         set smartindent
  #       '';
  #     };
  #   };
  # };
  services = {
    openssh = {
      enable = true;
      settings.PermitRootLogin = "no";
    };
  };
  #users.extraUsers.root.openssh.authorizedKeys.keys =
  #  [ "..." ];
  networking = {
    firewall = {
      allowedTCPPorts = [ 22 68 80 443 636 ]; # 2025-10-18
      enable = true;
    };
    hostName = "vpsfreecz001"; # Define your hostname.
    enableIPv6 = true;
    # firewall.package
    nftables.enable = true;
  };
  systemd.extraConfig = ''
    DefaultTimeoutStartSec=600s
  '';
  time.timeZone = "Europe/Paris";
  system.stateVersion = "25.05";
  environment.sessionVariables = rec {
    EDITOR="vim";
    WAGTAIL_ENV = "production";
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "contact@lesgrandsvoisins.com";
  };
}