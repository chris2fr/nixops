{ config, pkgs, lib, ... }:
let
in
{
  containers.keycloak = {
    # bindMounts = {
    #   "/var/lib/acme/keycloak.gv.coop/" = {
    #     hostPath = "/var/lib/acme/keycloak.gv.coop/";
    #     isReadOnly = true;
    #   }; 
    # };
    autoStart = true;
    # privateNetwork = true;
    # hostAddress = "192.168.105.10";
    # localAddress = "192.168.105.11";
    # hostAddress6 = "fa01::1";
    # localAddress6 = "fa01::2";
    config = { config, pkgs, lib, ...  }: {
      environment.systemPackages = with pkgs; [
        ((vim_configurable.override {  }).customize{
          name = "vim";
          vimrcConfig.customRC = ''
            " your custom vimrc
            set mouse=a
            set nocompatible
            colo torte
            syntax on
            set tabstop     =2
            set softtabstop =2
            set shiftwidth  =2
            set expandtab
            set autoindent
            set smartindent
            " ...
          '';
          }
        )
        git
        lynx
        openldap
      ];
      # virtualisation.docker.enable = true;
      system.stateVersion = "24.05";
      nix.settings.experimental-features = "nix-command flakes";
      # networking = {
      #   firewall = {
      #     enable = false;
      #     allowedTCPPorts = [  443 587 12443 ]; 
      #   };
      #   useHostResolvConf = lib.mkForce false;
      # };
      systemd.tmpfiles.rules = [
       "f /etc/.secret.keycloakdata 0660 root root"
      ];
      # security.acme.acceptTerms = true;
      # users = {
      #   groups = {
      #     "acme" = {
      #       gid = 993;
      #       members = ["acme"];
      #     };
      #     "wwwrun" = {
      #       gid = 54;
      #       members = ["acme" "wwwrun"];
      #     };
      #   };
      #   users = {
      #     "acme" = {
      #       uid = 994;
      #       group = "acme";
      #     };
      #     "wwwrun" = {
      #       uid = 54;
      #       group = "wwwrun";
      #     };
      #   };
      # };
      services = {
        # resolved.enable = true;
        keycloak = {
          enable = true;
          database = {
            passwordFile = "/etc/.secrets.keycloak";
            # useSSL = false;
          };
          settings = {
            https-port = 12443;
            http-port = 12080;
            # proxy = "passthrough";
            proxy = "reencrypt";
            hostname = "keycloak.gv.coop";
          };
          # sslCertificate = "/var/lib/acme/keycloak.gv.coop/fullchain.pem";
          # sslCertificateKey = "/var/lib/acme/keycloak.gv.coop/key.pem";
          # themes = {lesgv = (pkgs.callPackage "/etc/nixos/keycloaktheme/derivation.nix" {});};
        };
      };
    };
  };
}