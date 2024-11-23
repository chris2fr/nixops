{ config, pkgs, lib, ... }:

let 
  mannchriRsaPublic = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/mailserver/vars/cert-public.nix));
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz";
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];
  ## Apostrophe CMS
  users.users.aaa = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ mannchriRsaPublic ];
  };
  home-manager.users.aaa = {pkgs, ...}: {
    # I'll use Mongo in a Docker Container
#    nixpkgs = {
#      config = {
#        allowUnfree = true;
#        allowUnfreePredicate = (_: true);
#      };
#    };
    home.stateVersion = "24.05";
    programs.home-manager.enable = true;
    home.packages = with pkgs; [ 
      nodejs_20
#      mongodb
    ];
  };
  ## GHOSTIO
  users.users.ghostio = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ mannchriRsaPublic ];
    extraGroups = ["wwwrun"];
  };
  ## ODOO FOR
  users.users.odoofor = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ mannchriRsaPublic ];
  };
  ## ODOO THREE
  users.users.odoothree = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ mannchriRsaPublic ];
  };
  ## ODOO TOO
  users.users.odootoo = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ mannchriRsaPublic ];
  };
  ## ODOO
  users.users.odoo = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ mannchriRsaPublic ];
  };
  # Docker
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
  users.extraGroups.docker.members = [ "mannchri" ];
  services.mysql.enable = true;
  services.mysql.package = pkgs.mysql80;

  systemd.services.ghostio = {
    enable = true;
    description = "Ghost systemd service for blog: localhost";
    environment = {
      NODE_ENV = "production";
    };
    documentation = [ "https://ghost.org/docs/" ];
    serviceConfig = {
      Type = "simple";
      WorkingDirectory = "/var/www/ghost";
      User = "ghost";
      ExecStart = "/home/ghost/.nix-profile/bin/node /home/ghost/node_modules/ghost-cli/bin/ghost run";
      Restart = "always";
    };
    wantedBy = [ "multi-user.target" ];
  };
  users.users.ghost = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ mannchriRsaPublic ];
    extraGroups = ["wwwrun"];
  };
  home-manager.users.ghost = {pkgs, ...}: {
    home.stateVersion = "24.05";
    programs.home-manager.enable = true;
    home.packages = with pkgs; [ 
      nodejs_18
    ];
  };
  virtualisation.lxd.enable = true;
  # virtualisation.lxc.enable = true;
  virtualisation.lxc.lxcfs.enable = true;
}