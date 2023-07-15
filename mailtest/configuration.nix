{ config, pkgs, lib, ... }:
let 
  mannchriRsaPublic = (builtins.readFile ./.sercrets.mannchri-rsa.pub);
in
{
  nix.settings.experimental-features = "nix-command flakes";
  imports = [
    ./vpsadminos.nix
    #<home-manager/nixos>
  ];

  environment.systemPackages = with pkgs; [
    ((vim_configurable.override {  }).customize{
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
      }
    )
    curl
    wget
    lynx
    git
    tmux
    bat
    zlib
    dig
    lzlib
  ];

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";

  systemd.extraConfig = ''
    DefaultTimeoutStartSec=900s
  '';

  time.timeZone = "Europe/Amsterdam";

  system.stateVersion = "23.05";

  environment.sessionVariables = rec {
    EDITOR="vim";
  };
#  security.acme = {
#    acceptTerms = true;
#    defaults.email = "contact@lesgrandsvoisins.com";
#  };
}
