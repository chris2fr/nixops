{ config, pkgs, lib, ... }:
let
in
{
  environment.systemPackages = with pkgs; [
    mariadb
    (pkgs.php82.buildEnv {
      extensions = ({ enabled, all }: enabled ++ (with all; [
        imagick
      ]));
      extraConfig = ''
      '';
    })
    php82Extensions.imagick
  ];
   ## Adding httpd
  services.httpd.enable = true; 
  services.httpd.enablePHP = true;
  services.httpd.phpPackage = pkgs.php.buildEnv {
      extensions = ({ enabled, all }: enabled ++ (with all; [
          imagick
      ]));
      extraConfig = ''
          upload_max_filesize = 128M
          post_max_size = 256M
      '';
  };

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