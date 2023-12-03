{ config, pkgs, lib, ... }:
let
in
{
  networking.nat = {
    enable = true;
    internalInterfaces = ["ve-+"];
    externalInterface = "ens3";
    # Lazy IPv6 connectivity for the container
    enableIPv6 = true;
  };

  containers.wagtail = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.11";
    hostAddress6 = "fc00::1";
    localAddress6 = "fc00::2";

    config = { config, pkgs, ... }: {
      time.timeZone = "Europe/Amsterdam";
      system.stateVersion = "23.05";

      networking = {
        firewall = {
          enable = true;
          allowedTCPPorts = [ 80 443 ];
        };
        # Use systemd-resolved inside the container
        useHostResolvConf = lib.mkForce false;
      };
      
      services.resolved.enable = true;

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
      }; 
    };
  };
}