{ config, pkgs, ... }:

let
in
{
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
    #vim
    #django-redis
    cowsay
    home-manager
    curl
    wget
    lynx
    git
    tmux
    bat
    python311Packages.pillow
    python311Packages.pylibjpeg-libjpeg
    zlib
    lzlib
    dig
    killall
    inetutils
    pwgen
    openldap
    nftables
  ];
}