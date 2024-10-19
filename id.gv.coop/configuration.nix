# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./mailserver.nix
      ./keycloak.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  security.acme = {
    defaults.email = "chris@mann.fr";
    acceptTerms = true;
    # certs."id.gv.coop".listenHTTP = ":8888";
  };

  networking = {
    hostName = "id"; # Define your hostname.
    # Pick only one of the below networking options.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    networkmanager.enable = true;  # Easiest to use and most distros use this by default.
    hosts = {
      "127.0.0.1" = [ "localhost" "lemonldap.internal" "manager.lemonldap.internal" "handler.lemonldap.internal"  "test.lemonldap.internal"  "test2.lemonldap.internal"  "api.lemonldap.internal" "wa.lemonldap.internal" "sa.lemonldap.internal"];
      "127.0.0.2" = [ "id"];
      "::1" = [ "id""localhost"];
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;


  

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.ac
  # hardware.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mannchri = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ for the user.
    initialPassword = "reverse";
    packages = with pkgs; [
  #     firefox
  #     tree
        # vim
        # wget
        # dig
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
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
    wget
    git
    dig
    curl
    lynx
    tmux
    pwgen
    python311Full
    python311Packages.pip
    python311Packages.python-ldap
    openldap
    unzip
    # jre17_minimal
    docker
    docker-compose
    nodejs_22
    gnumake
    go
    corepack_22
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  virtualisation.docker = {
    enable = true;

  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services = {
    # tomcat = {
    #   enable = true;

    # };
    openssh = {
      enable = true;
    };
    nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "ldapui.gv.coop" = {
          enableACME = true; 
          forceSSL = true; 
          locations."/.well-known" = { proxyPass = null; };
          locations."/" = {
            proxyPass = "http://localhost:5000";
            extraConfig = ''
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_redirect off;
              auth_basic "Administrator’s Area";
              auth_basic_user_file /var/lib/.htpasswd;
            '';
          };
        };
      };
      virtualHosts = {
        "lemonldap.gv.coop" = {
          enableACME = true; 
          forceSSL = true; 
          locations."/.well-known" = { proxyPass = null; };
          locations."/" = {
            proxyPass = "http://lemonldap.internal:8080";
            extraConfig = ''
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_redirect off;
            '';
          };
        };
        "manager.lemonldap.gv.coop" = {
          enableACME = true; 
          forceSSL = true; 
          locations."/.well-known" = { proxyPass = null; };
          locations."/" = {
            proxyPass = "http://manager.lemonldap.internal:8080";
            extraConfig = ''
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_redirect off;
            '';
          };
        };
        "handler.lemonldap.gv.coop" = {
          enableACME = true; 
          forceSSL = true; 
          locations."/.well-known" = { proxyPass = null; };
          locations."/" = {
            proxyPass = "http://handler.lemonldap.internal:8080";
            extraConfig = ''
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_redirect off;
            '';
          };
        };
        "api.lemonldap.gv.coop" = {
          enableACME = true; 
          forceSSL = true; 
          locations."/.well-known" = { proxyPass = null; };
          locations."/" = {
            proxyPass = "http://api.lemonldap.internal:8080";
            extraConfig = ''
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_redirect off;
            '';
          };
        };
      };
    };
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 8888 80 443 25 587 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?

}

