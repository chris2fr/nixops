{ config, pkgs, lib, ... }:
let
in
{
  containers.erdock = {
    autoStart = true;
    privateNetwork = true;
    # hostBridge = "br0";
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.11";
    hostAddress6 = "fc00::1";
    localAddress6 = "fc00::2";
    # bindMounts = {};
    config = { config, pkgs, ... }: {
      nix.settings.experimental-features = "nix-command flakes";
      time.timeZone = "Europe/Paris";
      system.stateVersion = "25.05";
      networking = {
        firewall.enable = false;
        # firewall = {
        #   enable = true;
        #   allowedTCPPorts = [ 80 443 ];
        # };
        # Use systemd-resolved inside the container
        useHostResolvConf = lib.mkForce false;
      };
      environment.systemPackages = with pkgs; [
        ((vim_configurable.override { }).customize {
          name = "vim";
          vimrcConfig.customRC = ''
            " your custom vimrc
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
            " ...
          '';
        })
        docker-compose
        git
        wget
        perl
        podman

      ];
      # systemd.tmpfiles.rules = [];
      virtualisation.docker.enable = true;
      virtualisation.podman.enable = true;
      services = {
        resolved.enable = true;
      };
      users.users.filestash = {
        isNormalUser = true;
        extraGroups = ["docker"];
      }
      users.extraGroups.docker.members = [ "filestash" ];
    };
  };
}