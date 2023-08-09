{ config, pkgs, lib, ... }:
let 
  mannchriRsaPublic = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/mailserver/vars/cert-public.nix));
in
{
  imports = [
    <home-manager/nixos>
  ];
  users.users.aaa = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ mannchriRsaPublic ];
  }
  home-manager.users.mannchri = {pkgs, ...}: {
    home.stateVersion = "23.05";
    programs.home-manager.enable = true;
    home.packages = with pkgs; [ 
      nodejs_20
      mongodb
    ];
}