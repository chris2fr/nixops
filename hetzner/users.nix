{ config, pkgs, lib, ... }:
let 
  mannchriRsaPublic = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAuBWybYSoR6wyd1EG5YnHPaMKE3RQufrK7ycej7avw3Ug8w8Ppx2BgRGNR6EamJUPnHEHfN7ZZCKbrAnuP3ar8mKD7wqB2MxVqhSWvElkwwurlijgKiegYcdDXP0JjypzC7M73Cus3sZT+LgiUp97d6p3fYYOIG7cx19TEKfNzr1zHPeTYPAt5a1Kkb663gCWEfSNuRjD2OKwueeNebbNN/OzFSZMzjT7wBbxLb33QnpW05nXlLhwpfmZ/CVDNCsjVD1+NXWWmQtpRCzETL6uOgirhbXYW8UyihsnvNX8acMSYTT9AA3jpJRrUEMum2VizCkKh7bz87x7gsdA4wF0/w== rsa-key-20220407";
in
{
  users.users = {
    appflowycloud = {
      isNormalUser = true;
    };
    filebrowser = {
      isNormalUser = true;
      group = "wwwrun";
    };
    sftpgo = {
      isNormalUser = true;
      extraGroups = ["wwwrun" "acme"];
      # group = lib.mkDefault  "wwwrun";
    };
    haproxy = {
      extraGroups = ["wwwrun" "acme"];
    };
    mannchri = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [ mannchriRsaPublic ];
      extraGroups = [ "wheel" "syncthing" "libvirtd" "wwwrun" "acme"];
    };
    crabfit = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [ mannchriRsaPublic ];
      extraGroups = [ "docker" ];
    };
    fossil = {
        isNormalUser = true;
        openssh.authorizedKeys.keys = [ mannchriRsaPublic ];
    };
    wagtail = {
      isNormalUser = true;
    };
    # radicale = {
    #   isNormalUser = true;
    #   openssh.authorizedKeys.keys = [ mannchriRsaPublic ];
    # };
  };

}