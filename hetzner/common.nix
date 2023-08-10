{ config, pkgs, lib, ... }:

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
    # inetutils
    pwgen
    openldap
    mysql80
    wkhtmltopdf
    python311Packages.pypdf2
    python311Packages.python-ldap
    python311Packages.pq
    python311Packages.aiosasl
  ];
  
  {
    nixpkgs.config.permittedInsecurePackages = [
      "qtwebkit-5.212.0-alpha4"
    ];
  }

}