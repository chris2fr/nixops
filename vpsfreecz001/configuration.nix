{ config, pkgs, lib, ... }:
let 
  mannchriRsaPublic = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAuBWybYSoR6wyd1EG5YnHPaMKE3RQufrK7ycej7avw3Ug8w8Ppx2BgRGNR6EamJUPnHEHfN7ZZCKbrAnuP3ar8mKD7wqB2MxVqhSWvElkwwurlijgKiegYcdDXP0JjypzC7M73Cus3sZT+LgiUp97d6p3fYYOIG7cx19TEKfNzr1zHPeTYPAt5a1Kkb663gCWEfSNuRjD2OKwueeNebbNN/OzFSZMzjT7wBbxLb33QnpW05nXlLhwpfmZ/CVDNCsjVD1+NXWWmQtpRCzETL6uOgirhbXYW8UyihsnvNX8acMSYTT9AA3jpJRrUEMum2VizCkKh7bz87x7gsdA4wF0/w== rsa-key-20220407";
in
{
  nix.settings.experimental-features = "nix-command flakes";
  imports = [
    ./vpsadminos.nix
    ./mailserver.nix
    ./guichet.nix
    <home-manager/nixos>
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
  ];

#  virtualisation.docker.enable = true;
#  users.extraGroups.docker.members = [ "mannchri" ];
#  pkgs.dockerTools.pullImage = {
#    imageName = "dnknth/ldap-ui";
#    finalImageTag = "latest";
#    imageDigest = "sha256:c34a8feb5978888ebe5ff86884524b30759469c91761a560cdfe968f6637f051";
#    sha256 = "";
#  };


  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "no";
  #users.extraUsers.root.openssh.authorizedKeys.keys =
  #  [ "..." ];
  services.httpd.enable = true;
  services.httpd.enablePHP = false;
  services.httpd.adminAddr = "contact@lesgrandsvoisins.com";
  services.httpd.extraModules = [ "proxy" "proxy_http" ];
  users.users.wwwrun.extraGroups = [ "acme" "wagtail" ];
  services.httpd.virtualHosts."lesgrandsvoisins.com" = {
    enableACME = true;
    forceSSL = true;
    serverAliases = [ 
      "gvois.in"
      "www.gvois.in" 
      "gvcoop.org"
      "www.gvcoop.org"
      "gvcoop.com"
      "www.gvcoop.com"
      "coopgv.org"
      "www.coopgv.org"
      "coopgv.com"
      "www.coopgv.com"
      "wagtail.l-g-v.com"
    ];
    globalRedirect = "https://www.lesgrandsvoisins.com/";
  };
  services.httpd.virtualHosts."resdigita.com" = {
    enableACME = true;
    forceSSL = true;
    globalRedirect = "https://www.resdigita.com";
  };
  services.httpd.virtualHosts."resdigita.org" = {
    enableACME = true;
    forceSSL = true;
    globalRedirect = "https://www.resdigita.org";
  };
  services.httpd.virtualHosts."www.lesgrandsvoisins.com" = {
    enableACME = true;
    forceSSL = true;
    documentRoot =  "/var/www/wagtail/";
    extraConfig = ''
    <Location />
    Require all granted
    </Location>

    ProxyPass /.well-known !
    ProxyPass /static !
    ProxyPass /media !
    ProxyPass /favicon.ico !
    ProxyPass / unix:/var/lib/wagtail/wagtail-lesgv.sock|http://127.0.0.1/
    ProxyPassReverse / unix:/var/lib/wagtail/wagtail-lesgv.sock|http://127.0.0.1/
    ProxyPreserveHost On
    CacheDisable /
    '';
  };
  services.httpd.virtualHosts."www.resdigita.com" = {
    enableACME = true;
    forceSSL = true;
    documentRoot =  "/var/www/wagtail/";
    extraConfig = ''
    <Location />
    Require all granted
    </Location>

    ProxyPass /.well-known !
    ProxyPass /static !
    ProxyPass /media !
    ProxyPass /favicon.ico !
    ProxyPass / unix:/var/lib/wagtail/wagtail-lesgv.sock|http://127.0.0.1/
    ProxyPassReverse / unix:/var/lib/wagtail/wagtail-lesgv.sock|http://127.0.0.1/
    ProxyPreserveHost On
    CacheDisable /
    '';

  };
  services.httpd.virtualHosts."www.resdigita.org" = {
    enableACME = true;
    forceSSL = true;
    documentRoot =  "/var/www/wagtail/";
    extraConfig = ''
    <Location />
    Require all granted
    </Location>

    ProxyPass /.well-known !
    ProxyPass /static !
    ProxyPass /media !
    ProxyPass /favicon.ico !
    ProxyPass / unix:/var/lib/wagtail/wagtail-lesgv.sock|http://127.0.0.1/
    ProxyPassReverse / unix:/var/lib/wagtail/wagtail-lesgv.sock|http://127.0.0.1/
    ProxyPreserveHost On
    CacheDisable /
    '';

  };
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    ensureDatabases = [
      "wagtail"
      "previous"
      "fairemain"
    ];
    ensureUsers = [
      {
        name = "wagtail";
        ensurePermissions = {
          "DATABASE \"wagtail\"" = "ALL PRIVILEGES";
          "DATABASE \"previous\"" = "ALL PRIVILEGES";
          "DATABASE \"fairemain\"" = "ALL PRIVILEGES";
          "ALL TABLES IN SCHEMA public" = "ALL PRIVILEGES";
        };
      }
    ]; 
#    authentication = ''
#      local all all trust
#      host all all 127.0.0.1/32 trust
#      host all all ::1/128 trust
#    '';
#    initialScript = ''
#      CREATE ROLE wagtail WITH LOGIN PASSWORD 'wagtail' CREATEDB;
#      CREATE DATABASE wagtail;
#      GRANT ALL PRIVILEGES ON DATABASE wagtail TO wagtail;
#    '';
  };

  networking.firewall.allowedTCPPorts = [ 80 443 8000 ];

  systemd.extraConfig = ''
    DefaultTimeoutStartSec=900s
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

#  user.users = {
#    mannchri.isNormalUser = true;
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
    wagtail = {
      isNormalUser = true;
    };
  };
  home-manager.users.fossil = {pkgs, ...}: {
    home.packages = with pkgs; [ 
      fossil
    ];
    home.stateVersion = "23.05";
    programs.home-manager.enable = true;
  };
  home-manager.users.wagtail = {pkgs, ...}: {
    home.packages = with pkgs; [ 
      python311
      python311Packages.pillow
      python311Packages.gunicorn
      python311Packages.pip
      libjpeg
      zlib
      libtiff
      freetype
      python311Packages.venvShellHook
    ];
    home.stateVersion = "23.05";
    programs.home-manager.enable = true;
  };

    systemd.services.wagtail = {
      description = "Les Grands Voisins Wagtail Website";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        WorkingDirectory = "/home/wagtail/wagtail-lesgv/";
        ExecStart = ''/home/wagtail/venv/bin/gunicorn --env WAGTAIL_ENV='production' --access-logfile access.log --chdir /home/wagtail/wagtail-lesgv --workers 3 --bind unix:/var/lib/wagtail/wagtail-lesgv.sock lesgv.wsgi:application'';
        Restart = "always";
        RestartSec = "10s";
        User = "wagtail";
        Group = "users";
      };
      unitConfig = {
        StartLimitInterval = "1min";
      };
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


   containers.postgresql =
   { 
      privateNetwork = true;
      hostAddress = "192.168.100.10";
      localAddress = "192.168.100.11";
      config = { config, pkgs, ... }: { 
#      nix.settings.experimental-features = "nix-command flakes";
#      imports = [
#        ./vpsadminos.nix
#      ];
#      environment.systemPackages = with pkgs; [
#        vim
#      ];
        services.postgresql.enable = true;
        services.postgresql.package = pkgs.postgresql_14;
       time.timeZone = "Europe/Amsterdam";
       system.stateVersion = "23.05";
     };
   };
}


