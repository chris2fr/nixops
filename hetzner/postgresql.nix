{ config, pkgs, lib, ... }:

let 
in
{
services.postgresql = {
    enable = true;
    enableTCPIP = true;
    package = pkgs.postgresql_14;
    ensureDatabases = [
      "wagtail"
      "previous"
      "fairemain"
      "crabfit"
      "lesgrandsvoinsinsfacile"
      "francemalifacile"
      "wwwcfran"
      "wagtailcfran"
      "djangocfran"
      "resdigitafastoche"
      "wwwfastoche"
      "village"
      "wagtailvillage"
      "resdigitaorg"
      "cantine"
      "ffdncoin"
      "lesgrandsvoisins"
      "key"
      "sftpgo"
    ];
        # ensureDBOwnership = true;
    ensureUsers = [
      {
        name = "wagtail";
        ensureDBOwnership = true;
        # ensurePermissions = {
        #   "DATABASE \"wagtail\"" = "ALL PRIVILEGES";
        #   "DATABASE \"previous\"" = "ALL PRIVILEGES";
        #   "DATABASE \"fairemain\"" = "ALL PRIVILEGES";
        #   "ALL TABLES IN SCHEMA public" = "ALL PRIVILEGES";
        # };
      }
      {
        name = "key";
        ensureDBOwnership = true;
      }
      {
        name = "sftpgo";
        ensureDBOwnership = true;
      }
      {
        name = "lesgrandsvoisins";
        ensureDBOwnership = true;
      }
      {
        name = "resdigitaorg";
        ensureDBOwnership = true;
      }
      {
        name = "cantine";
        ensureDBOwnership = true;
      }
      {
        name = "wagtailvillage";
        ensureDBOwnership = true;
      }
      {
        name = "village";
        ensureDBOwnership = true;
      }
      {
        name = "lesgrandsvoinsinsfacile";
        ensureDBOwnership = true;
      }
      {
        name = "resdigitafastoche";
        ensureDBOwnership = true;
      }
      {
        name = "wwwfastoche";
        ensureDBOwnership = true;
      }
      {
        name = "francemalifacile";
        ensureDBOwnership = true;
      }
      {
        name = "crabfit";
        ensureDBOwnership = true;
      }
      {
        name = "wwwcfran";
        ensureDBOwnership = true;
      }
      {
        name = "wagtailcfran";
        ensureDBOwnership = true;
      }
      {
        name = "djangocfran";
        ensureDBOwnership = true;
      }
      {
        name = "ffdncoin";
        ensureDBOwnership = true;
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
       system.stateVersion = "24.05";
     };
   };
}