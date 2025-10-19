{ config, pkgs, lib, ... }:
let
in
{
  containers.docker = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br0";
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.11";
    hostAddress6 = "fc00::1";
    localAddress6 = "fc00::2";
    # bindMounts = {};
    config = { config, pkgs, ... }: {
      nix.settings.experimental-features = "nix-command flakes";
      time.timeZone = "Europe/Paris";
      system.stateVersion = "25.05";
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
      ];
      # systemd.tmpfiles.rules = [];
      virtualisation.docker.enable = true;
      virtualisation.podman.enable = true;
    };
  };
}