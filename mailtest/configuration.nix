{ config, pkgs, lib, ... }:
let 
  mannchriRsaPublic = (builtins.readFile ./.secrets.mannchri-rsa.pub);
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
    sogo
    postgresql
    openldap
    dig
    killall
  ];

  services.httpd = {
    enable = true;
    enablePHP = false;
    adminAddr = "contact@lesgrandsvoisins.com";
    extraModules = [ "proxy" "proxy_http" ];
    virtualHosts."mailtest.resdigita.org" = {
      enableACME = true;
      forceSSL = true;
      documentRoot =  "/var/www/SOGo";
      extraConfig = ''
      Alias /.woa/ /var/www/SOGo/
      Alias /SOGo.woa/ /var/www/SOGo/
#      <Location />
#      Order allow,deny
#      Allow from all
#      </Location>
      ProxyPass /.well-known !
    #  ProxyPass /principals http://[::1]:20000/SOGo/dav/ interpolate
    #  ProxyPass /SOGo http://[::1]:20000/SOGo interpolate
      ProxyPass /SOGo http://[::1]:20000
      ProxyPreserveHost On
    #  ProxyPassInterpolateEnv On
      CacheDisable /
#      <Proxy http://127.0.0.1:20000>
#    RequestHeader set "x-webobjects-server-port" "8800"
#    RequestHeader set "x-webobjects-server-name" "mailtest.resdigita.org:8800"
#    RequestHeader set "x-webobjects-server-url" "https://mailtest.resdigita.org:8800"
#    RequestHeader set "x-webobjects-server-protocol" "HTTP/1.0"
#    RequestHeader set "x-webobjects-remote-host" "127.0.0.1"
#    AddDefaultCharset UTF-8
#      </Proxy>
      '';
    };
  };
  users.users = rec {
    wwwrun.extraGroups = [ "acme" "sogo" ];
    mannchri = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [ mannchriRsaPublic ];
      extraGroups = [ "wheel" "networkmanager" ];
    };
  };

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
    #certificateScheme = "acme-nginx";
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "postmaster@resdigita.org";
    defaults.webroot = "/var/www";
  };


  services.openldap = {
    enable=true;
  };

  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    ensureDatabases = [
      "sogo"
    ];
    ensureUsers = [
      {
        name = "sogo";
        ensurePermissions = {
          "DATABASE \"sogo\"" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";


  services.sogo = {
    enable = true;
    language = "fr-fr";
    timezone = "europe/paris";
#      OCSStoreURL = "postgresql:///sogo/sogo_store";
#      OCSAclURL = "postgresql:///sogo/sogo_acl";
#      OCSCacheFolderURL = "postgresql:///sogo/sogo_cache_folder";
    extraConfig = ''
      OCSSessionsFolderURL = "postgresql:///sogo/sogo_sessions_folder";
      OCSEMailAlarmsFolderURL = "postgresql:///sogo/sogo_alarms_folder";
      SOGoProfileURL = "postgresql:///sogo/sogo_user_profile";
      OCSFolderInfoURL = "postgresql:///sogo/sogo_folder_info";
      WOPort = "[::1]:20000";
      WONoDetach = NO;
      WOWorkersCount = 3;
      SxVMemLimit = 300;
      SOGoMailDomain = "resdigita.org";
      SOGoLanguage = French;
      SOGoAppointmentSendEMailNotifications = YES;
      SOGoEnablePublicAccess = YES;
      SOGoSMTPAuthenticationType = PLAIN;
      SOGoForceExternalLoginWithEmail = YES;
      SOGoIMAPAclConformsToIMAPExt = YES;
      SOGoTimeZone = UTC;
      SOGoSentFolderName = Sent;
      SOGoTrashFolderName = Trash;
      SOGoDraftsFolderName = Drafts;
      SOGoVacationEnabled = NO;
      SOGoForwardEnabled = NO;
      SOGoSieveScriptsEnabled = NO;
      SOGoFirstDayOfWeek = 1;
      SOGoRefreshViewCheck = every_5_minutes;
      SOGoMailAuxiliaryUserAccountsEnabled = NO;
      SOGoPasswordChangeEnabled = YES;
      SOGoPageTitle = "resdigita.org";
      SOGoLoginModule = Mail;
      SOGoMailAddOutgoingAddresses = YES;
      SOGoSelectedAddressBook = autobook;
      SOGoMailAuxiliaryUserAccountsEnabled = YES;
      SOGoCalendarEventsDefaultClassification = PRIVATE;
      SOGoMailReplyPlacement = above;
      SOGoMailSignaturePlacement = above;
      SOGoMailComposeMessageType = html;
'';
  };

#  services.roundcube = {
#     enable = true;
#     # this is the url of the vhost, not necessarily the same as the fqdn of
#     # the mailserver
#     hostName = "mailtest38.resdigita.org";
#     extraConfig = ''
#       # starttls needed for authentication, so the fqdn required to match
#       # the certificate
#       $config['smtp_server'] = "tls://${config.mailserver.fqdn}";
#       $config['smtp_user'] = "%u";
#       $config['smtp_pass'] = "%p";
#     '';
#  };
#
#  services.nginx.enable = false;
#
networking.firewall = {
  allowedTCPPorts = [ 80 443 20000 ];
  enable = true;
  trustedInterfaces = [ "lo" ];
};

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
