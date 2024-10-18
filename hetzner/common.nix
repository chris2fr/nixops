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
#    wkhtmltopdf
    python311Full
    python311Packages.pip
    python311Packages.pypdf2
    python311Packages.python-ldap
    python311Packages.pq
    python311Packages.aiosasl
    python311Packages.psycopg2
#    gccgo
#    gnumake
#    python311Packages.ldappool
#    python311Packages.ldap3
#   python311Packages.bonsai
#    python311Packages.python-ldap-test
#    ldapvi
#    shelldap
#    python311Packages.devtools
#    python311Packages.ldaptor
#    python311Packages.setuptools
#    python311Packages.libsass
#    libsass
#    sass
#    sassc
#    python311Packages.cython
#    python311Packages.pip
#    python311Packages.pyproject-api
#    python311Packages.pyproject-hooks
     busybox
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "qtwebkit-5.212.0-alpha4"
  ];

}