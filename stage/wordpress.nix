{ config, pkgs, lib, ... }:
let
in
{
  environment.systemPackages = with pkgs; [
    mariadb
    php82
    php82Extensions.imagick
  ];
   ## Adding httpd
  services.httpd.enable = true; 
  services.httpd.enablePHP = true;
  services.httpd.phpPackage = pkgs.php82;
  services.httpd.phpOptions = ''
    upload_max_filesize = 128M
    post_max_size = 256M
    extension=imagick.so
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