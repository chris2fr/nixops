{ config, pkgs, lib, ... }:

let 
  mannchriRsaPublic = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/mailserver/vars/cert-public.nix));
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz";
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];
  nixpkgs.config.allowUnfree = true;
  users.users.aaa = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ mannchriRsaPublic ];
  };
  home-manager.users.mannchri = {pkgs, ...}: {
    home.stateVersion = "23.05";
    programs.home-manager.enable = true;
    home.packages = with pkgs; [ 
      nodejs_20
      mongodb
    ];
  };
}