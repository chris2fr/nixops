# 
# Server Nixos "ghh.gvoisins.com" 
# for test by @hovnhovi (HVKHYN)
# from 2023-07-30 to 2023-08-29
#
{ config, pkgs, ... }:
let
  # myPhp = php.withExtensions ({ all, ... }: with all; [ imagick opcache ]);
in
{
  nix.settings.experimental-features = "nix-command flakes";
  imports = [
    ./vpsadminos.nix # Sur vpsfree.cz, pour conformer au containeur
    ./common.nix # Des configurations communes pratiques sur mes installations
    # ./mailserver.nix
  ];
  environment.systemPackages = with pkgs; [
    vim
    unzip # UnZip requiert pour installation de thème ZIP
    git
    php81Extensions.imagick
    imagemagick
    (pkgs.php.withExtensions
      ({ all, ... }: with all; [
        imagick
#        opcache
#        pdo
#        pdo_mysql
      ])
    )
  ];
# Networking
  networking.hostName = "vpsfreecz002"; # Define your hostname.
# Specific configuration for PHP goes here
#services.phpfpm.pools."wordpress" = {
#  user = "wwwrun";
#  group = "users";
#  # phpPackage = myPhp;
#  settings = {
#    "extension" = "${pkgs.php81Extensions.imagick}/lib/php/extensions/imagick.so";
#    "max_execution_time" = "450";
#  };
# };
# services.phpfpm.phpOptions = ''
#  upload_max_filesize = 128M
#  post_max_size = 256M
#  extension=${pkgs.php81Extensions.imagick}/lib/php/extensions/imagick.so
#  max_execution_time=450
#'';
  #php.withExtensions ({ enabled, all }: enabled ++ [ all.imagick ]);
  #php.buildEnv {
  #extensions = { all, ... }: with all; [ imagick opcache ];
  #extraConfig = "memory_limit=256M";
  #};
  # Open Firewall Ports
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  # Configure Let's Encrypt Certificates
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "hvkhyn@yahoo.com";
  # Configure the webserver
  services.httpd.enable = true;
  services.httpd.enablePHP = true;
  # These PHP Settings are global to the webserver and nos FPM
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
  # SetEnv MYSQL_HOST localhost
  # SetEnv MYSQL_DATABASE ${dbConfig.db}
  # SetEnv MYSQL_USER ${dbConfig.user}
  # SetEnv MYSQL_PASSWORD ${dbConfig.password}
  # Below is the stock Workpress configuration from Nixos
  # on ghh.village.voisin.com 
  # not quite satisfactory
  services.wordpress.sites."ghh.villagevoisin.com" = {
    virtualHost.enableACME = true;
    virtualHost.forceSSL = true;
    documentRoot = "/var/www/ghh";
    settings = {
      FS_METHOD = "direct";
    };
    poolConfig = {
       "extension" = "imagick.so";
       "max_execution_time" = "450";
    };
    extraConfig = ''
      <Directory />
        DirectoryIndex index.php
        Require all granted
        Options Indexes FollowSymLinks
        AllowOverride All
      </Directory>
      '';
  };
  #services.wordpress.webserver = "httpd"; # Defaults to httpd
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "prohibit-password";
  #users.extraUsers.root.openssh.authorizedKeys.keys =
  #  [ "..." ];
  time.timeZone = "Europe/Paris";
  # using the 23.05 version of Nixos
  system.stateVersion = "23.05";
}