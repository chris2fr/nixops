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
      '';
  };

  services.httpd.phpOptions = ''
    upload_max_filesize = 128M
    post_max_size = 256M
    max_execution_time = 300
  '';
  services.httpd.virtualHosts."vpsfreecz003.lesgrandsvoisins.com" = {
    serverAliases = [
      "ghh.villagevoisin.com"
    ];
    enableACME = true;
    forceSSL = true;
    documentRoot = "/var/www/ghh";
    extraConfig = ''
      <Directory /var/www/ghh>
        DirectoryIndex index.php
        Require all granted
        AllowOverride FileInfo
        FallbackResource /index.php
      </Directory>
      '';
  };
  services.mysql.package = pkgs.mariadb;
  services.mysql.enable = true;

}