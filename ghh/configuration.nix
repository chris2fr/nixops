# 
# Server Nixos "ghh.gvoisins.com" 
# for test by @hovnhovi (HVKHYN)
# from 2023-07-30 to 2023-08-29
#
{ config, pkgs, ... }:
{
  nix.settings.experimental-features = "nix-command flakes";
  imports = [
    ./vpsadminos.nix # Sur vpsfree.cz, pour conformer au containeur
  ];
  environment.systemPackages = with pkgs; [
    vim
    unzip # UnZip requiert pour installation de thème ZIP
  ];
# Specific configuration for PHP goes here
services.phpfpm.phpOptions = ''
  upload_max_filesize = 128M
  post_max_size = 256M
'';
  # Open Firewall Ports
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  # Configure Let's Encrypt Certificates
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "hvkhyn@yahoo.com";
  # Configure the webserver
  services.httpd.enable = true;
  services.httpd.enablePHP = true;
  # These PHP Settings are global to the websrver and nos FPM
  services.httpd.phpOptions = ''
    upload_max_filesize = 128M
    post_max_size = 256M
  '';
  # This is the Wordpress program run from a live directory
  # Source is to be placed here, just placed here, and should work
  # You will need the directory contents to reproduce
  services.httpd.virtualHosts."ghh.gvoisins.com" = {
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
  # Set up a MariaDB database
  # Configured in config.php
  services.mysql.enable = true;
  services.mysql.package = pkgs.mariadb;
  # Not using environmental variables now
#      SetEnv MYSQL_HOST localhost
#      SetEnv MYSQL_DATABASE ${dbConfig.db}
#      SetEnv MYSQL_USER ${dbConfig.user}
#      SetEnv MYSQL_PASSWORD ${dbConfig.password}
  # Below is the stock Workpress configuration from Nixos
  # on ghh.village.voisin.com 
  # not quite satisfactory
  services.wordpress.sites."ghh.villagevoisin.com" = {
    virtualHost.enableACME = true;
    virtualHost.forceSSL = true;
    settings = {
      FS_METHOD = "direct";
    };
  };
  #services.wordpress.webserver = "httpd"; # Defaults to httpd
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";
  #users.extraUsers.root.openssh.authorizedKeys.keys =
  #  [ "..." ];
  time.timeZone = "Europe/Paris";
  # using the 23.05 version of Nixos
  system.stateVersion = "23.05";
}