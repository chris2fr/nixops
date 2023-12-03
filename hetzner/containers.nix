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


      system.stateVersion = "23.05";

      networking = {
        firewall = {
          enable = true;
          allowedTCPPorts = [ 80 443 ];
        };
        # Use systemd-resolved inside the container
        useHostResolvConf = mkForce false;
      };
      
      services.resolved.enable = true;

    };
  };
}