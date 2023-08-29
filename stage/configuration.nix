# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, lib, ... }:
let
  mannchriRsaPublic = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAuBWybYSoR6wyd1EG5YnHPaMKE3RQufrK7ycej7avw3Ug8w8Ppx2BgRGNR6EamJUPnHEHfN7ZZCKbrAnuP3ar8mKD7wqB2MxVqhSWvElkwwurlijgKiegYcdDXP0JjypzC7M73Cus3sZT+LgiUp97d6p3fYYOIG7cx19TEKfNzr1zHPeTYPAt5a1Kkb663gCWEfSNuRjD2OKwueeNebbNN/OzFSZMzjT7wBbxLb33QnpW05nXlLhwpfmZ/CVDNCsjVD1+NXWWmQtpRCzETL6uOgirhbXYW8UyihsnvNX8acMSYTT9AA3jpJRrUEMum2VizCkKh7bz87x7gsdA4wF0/w== rsa-key-20220407";
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz";
  hasaeraRsaPublic = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAuBWybYSoR6wyd1EG5YnHPaMKE3RQufrK7ycej7avw3Ug8w8Ppx2BgRGNR6EamJUPnHEHfN7ZZCKbrAnuP3ar8mKD7wqB2MxVqhSWvElkwwurlijgKiegYcdDXP0JjypzC7M73Cus3sZT+LgiUp97d6p3fYYOIG7cx19TEKfNzr1zHPeTYPAt5a1Kkb663gCWEfSNuRjD2OKwueeNebbNN/OzFSZMzjT7wBbxLb33QnpW05nXlLhwpfmZ/CVDNCsjVD1+NXWWmQtpRCzETL6uOgirhbXYW8UyihsnvNX8acMSYTT9AA3jpJRrUEMum2VizCkKh7bz87x7gsdA4wF0/w== rsa-key-20220407";
in
{
  imports =
    [ # Include the results of the hardware scan.
    ./common.nix # Des configurations communes pratiques
    ./wordpress.nix
    ./vpsadminos.nix
    (import "${home-manager}/nixos")
    ];

  # Networking
  networking.hostName = "vpsfreecz003"; # Define your hostname.
#  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
#  networking.useDHCP = true;
#  networking.enableIPv6 = true;
#  networking.interfaces.eno1.ipv6.addresses = [
#    {
#      address = "2a01:4f8:241:4faa::";
#      prefixLength = 96;
#    }
#  ];
#  networking.defaultGateway6 = {
#    address = "fe80::1";
#    interface = "eno1";
#  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "fr_FR.UTF-8";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mannchri = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ mannchriRsaPublic ];
    extraGroups = [ "wheel" ];
  };
  users.users.hasaera = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ hasaeraRsaPublic ];
    extraGroups = [ "wheel" ];
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
  home-manager.users.hasaera = {pkgs, ...}: {
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
  services.openssh.settings.PermitRootLogin = "prohibit-password";
  # networking.firewall.enable = false;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 25 80 443 143 587 993 995 636 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  environment.sessionVariables = rec {
    EDITOR="vim";
    WAGTAIL_ENV = "production";
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "contact@lesgrandsvoisins.com";
    defaults.webroot = "/var/www";
  };
  ## Adding Linux Containers
  virtualisation.lxd.enable = true;
  virtualisation.lxc.enable = true;
  virtualisation.lxc.lxcfs.enable = true;
  ## Adding httpd
  services.httpd.enable = true;
  services.httpd.enablePHP = true;
  services.httpd.phpOptions = ''
    upload_max_filesize = 128M
    post_max_size = 256M
  '';
  services.httpd.virtualHosts."vpsfreecz003.lesgrandsvoisins.com" = {
    serverAliases = [
      "ghh.villagevoisin.com"
    ];
    enableACME = true;
    forceSSL = true;
    documentRoot = "/var/www/ghh";
    extraConfig = ''
      <Directory />
        DirectoryIndex index.php
        Require all granted
      </Directory>
      '';
  };
  services.mysql.package = pkgs.mariadb;
  services.mysql.enable = true;


}

