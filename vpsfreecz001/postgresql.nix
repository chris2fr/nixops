{ config, pkgs, lib, ... }:

let 
in
{
services.postgresql = {
    enable = true;
    enableTCPIP = true;
    ensureDatabases = [
      "wagtail"
      "previous"
      "fairemain"
    ];
    ensureUsers = [
      {
        name = "wagtail";
        ensurePermissions = {
          "DATABASE \"wagtail\"" = "ALL PRIVILEGES";
          "DATABASE \"previous\"" = "ALL PRIVILEGES";
          "DATABASE \"fairemain\"" = "ALL PRIVILEGES";
          "ALL TABLES IN SCHEMA public" = "ALL PRIVILEGES";
        };
      }
    ]; 
#    authentication = ''
#      local all all trust
#      host all all 127.0.0.1/32 trust
#      host all all ::1/128 trust
#    '';
#    initialScript = ''
#      CREATE ROLE wagtail WITH LOGIN PASSWORD 'wagtail' CREATEDB;
#      CREATE DATABASE wagtail;
#      GRANT ALL PRIVILEGES ON DATABASE wagtail TO wagtail;
#    '';
  };
  containers.postgresql =
   { 
      privateNetwork = true;
      hostAddress = "192.168.100.10";
      localAddress = "192.168.100.11";
      config = { config, pkgs, ... }: { 
#      nix.settings.experimental-features = "nix-command flakes";
#      imports = [
#        ./vpsadminos.nix
#      ];
#      environment.systemPackages = with pkgs; [
#        vim
#      ];
        services.postgresql.enable = true;
        services.postgresql.package = pkgs.postgresql_14;
       time.timeZone = "Europe/Amsterdam";
       system.stateVersion = "23.05";
     };
   };
}