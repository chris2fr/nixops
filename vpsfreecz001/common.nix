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
    # home-manager # 2025-10-18
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
    python311
    python311Packages.pillow
    python311Packages.gunicorn
    python311Packages.pip
    libjpeg
    zlib
    libtiff
    freetype
    python311Packages.venvShellHook
    fossil
  ];
}