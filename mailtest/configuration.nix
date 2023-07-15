{ config, pkgs, lib, ... }:
let 
  mannchriRsaPublic = (builtins.readFile ./.sercrets.mannchri-rsa.pub);
in
{
  nix.settings.experimental-features = "nix-command flakes";
  imports = [
    ./vpsadminos.nix
    (builtins.fetchTarball {
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/nixos-23.05/nixos-mailserver-nixos-23.05.tar.gz";
      sha256 = "sha256:1ngil2shzkf61qxiqw11awyl81cr7ks2kv3r3k243zz7v2xakm5c";
    })
  ];

  mailserver = {
    enable = true;
    fqdn = "mailtest.resdigita.org";
    domains = [ "resdigita.org" ];

    # A list of all login accounts. To create the password hashes, use
    # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
    loginAccounts = {
      "user1@resdigita.org" = {
        hashedPasswordFile = "/etc/nixos/.secrets.user1";
        aliases = ["postmaster@resdigita.org"];
      };
    };

    # Use Let's Encrypt certificates. Note that this needs to set up a stripped
    # down nginx and opens port 80.
    certificateScheme = "acme-nginx";
  };
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "postmaster@resdigita.org";

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
    curl
    wget
    lynx
    git
    tmux
    bat
    zlib
    dig
    lzlib
  ];

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";

  services.roundcube = {
     enable = true;
     # this is the url of the vhost, not necessarily the same as the fqdn of
     # the mailserver
     hostName = "mailtest.resdigita.org";
     extraConfig = ''
       # starttls needed for authentication, so the fqdn required to match
       # the certificate
       $config['smtp_server'] = "tls://${config.mailserver.fqdn}";
       $config['smtp_user'] = "%u";
       $config['smtp_pass'] = "%p";
     '';
  };

  services.nginx.enable = true;

  networking.firewall.allowedTCPPorts = [ 80 443 ];


  systemd.extraConfig = ''
    DefaultTimeoutStartSec=900s
  '';

  time.timeZone = "Europe/Amsterdam";

  system.stateVersion = "23.05";

  environment.sessionVariables = rec {
    EDITOR="vim";
  };
#  security.acme = {
#    acceptTerms = true;
#    defaults.email = "contact@lesgrandsvoisins.com";
#  };
}
