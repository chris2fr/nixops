# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, lib, ... }:
let
  mannchriRsaPublic = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/mailserver/vars/cert-public.nix));
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz";
in
{
  nix.settings.experimental-features = "nix-command flakes";
  imports =
    [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./httpd.nix
    ./mailserver.nix
    ./guichet.nix
    ./postgresql.nix
#    ./users.nix
    ./wagtail.nix
    ./common.nix # Des configurations communes pratiques
    ./servers.nix # I am migrating other services here
    ./containers.nix
    ./nginx.nix
    (import "${home-manager}/nixos")
    ];
  #  environment.systemPackages = with pkgs; [
  #   gcc 
  #   pkg-config
  #   openssl
  #  ];
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "hetzner005"; # Define your hostname.
  #networking.hostName = "mail.lesgrandsvoisins.com"; # Define your hostname
#  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
#  networking.useDHCP = true;
  networking.enableIPv6 = true;
  networking.interfaces.eno1.ipv6.addresses = [
    {
      address = "2a01:4f8:241:4faa::";
      prefixLength = 96;
    }
  ];
  networking.defaultGateway6 = {
    address = "fe80::1";
    interface = "eno1";
  };





  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "fr_FR.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mannchri = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ mannchriRsaPublic ];
    extraGroups = [ "wheel" ];
  };
  users.users.fossil = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [ mannchriRsaPublic ];
  };

  home-manager.users.fossil = {pkgs, ...}: {
    home.packages = with pkgs; [ 
      fossil
    ];
    home.stateVersion = "23.11";
    programs.home-manager.enable = true;
  };
  home-manager.users.guichet = {pkgs, ...}: {
    home.packages = with pkgs; [ 
      go
      gnumake
      python311
    ];
    home.stateVersion = "23.11";
    programs.home-manager.enable = true;
  };

  home-manager.users.mannchri = {pkgs, ...}: {
    home.packages = [ pkgs.atool pkgs.httpie ];
    home.stateVersion = "23.11";
    programs.home-manager.enable = true;
    programs.vim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [ vim-airline ];
      settings = { ignorecase = true; tabstop = 2; };
      extraConfig = ''
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
      '';
    };
  };

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "prohibit-password";
  # networking.firewall.enable = false;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  networking = {
    firewall.trustedInterfaces = [ "docker0" "lxdbr1" "lxdbr0" ];
    firewall.allowedTCPPorts = [ 22 25 80 443 143 587 993 995 636 8443 9443 10080 10443 ];
    # interfaces."eno1".ipv6 = {

    # }
  };
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

  environment.sessionVariables = rec {
    EDITOR="vim";
    WAGTAIL_ENV = "production";
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "contact@lesgrandsvoisins.com";
    defaults.webroot = "/var/www";
  };

  # nixpkgs.config.allowUnfree = true;
  # services.cockroachdb = {
  #    enable = true;
  #    http.port = 9090;
  #    locality = "country=fr";
  #    insecure = true;
  # };


  # services.zitadel = {
  #   enable = true;
  #   masterKeyFile = "/etc/nixos/.secrets.zitadel";
  #   settings = {
  #     TLS.KeyPath = "/var/lib/acme/hetzner005.lesgrandsvoisins.com/key.pem";
  #     TLS.CertPath = "/var/lib/acme/hetzner005.lesgrandsvoisins.com/fullchain.pem";
  #     ExternalDomain = "hetzner005.lesgrandsvosins.com";
  #     ExternalSecure = true;
  #     ExternalPort = 8443;
  #   };
  # };
  # users.users.zitadel.extraGroups = ["wwwrun"];
  
  services.traefik = {
    enable = true;
    staticConfigOptions = {
      entrypoints = {
        http.address = ":10080";
        # websecure = {
        #   address = 10443;
        #   http.tls = {
        #      certResolver = "leresolver";
        #      domains = [{main = "hetzner005.lesgrandsvoisins.com"}];
        #   };
        # };
        http.redirections.entrypoint = {
            to = "websecure";
            scheme = "https";
          };
        };
        websecure.address = ":10443";
        electrs.address = ":50002";
      };
    dynamicConfigOptions = {
      # routes = [{
      #   match = "(PathPrefix(`/dashboard`)";
      #   kind = "Rule";
      #   services = [{name="api@internal";kind="TraefikService";}];
      # }];
      http.middlewares.prefix-strip.stripprefixregex.regex = "/[^/]+";
      http = {
        # services = {
        #   rtl.loadBalancer.servers = [ { url = "http://169.254.1.29:3000/"; } ];
        #   spark.loadBalancer.servers = [ { url = "http://169.254.1.17:9737/"; } ];
        # };
        services = {
          dav = [ { url = "https://dav.lesgrandsvoisins.com/"; } ];
        };
        routers = {
          rtl = {
            rule = "PathPrefix(``,`/`)";
            entryPoints = [ "websecure" ];
            service = "dav";
            tls = true;
          };
        };
      };
      tls = {
        certificates = [{
          certFile = "/var/lib/acme/hetzner005.lesgrandsvoisins.com/fullchain.pem";
          keyFile = "/var/lib/acme/hetzner005.lesgrandsvoisins.com/key.pem";
        }];
      };
    };
  };
}

