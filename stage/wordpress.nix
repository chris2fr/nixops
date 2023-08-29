{ config, pkgs, lib, ... }:
let
in
{
  environment.systemPackages = with pkgs; [
    mariadb
    php81Extensions.imagick

  ];
}