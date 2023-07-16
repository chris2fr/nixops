{ config, pkgs, lib, ... }:
let 
  mannchriRsaPublic = (builtins.readFile ./.secrets.mannchri-rsa.pub);
  bindPassword = (builtins.readFile ./.secrets.adminresdigitaorg);
  alicePassword = (builtins.readFile ./.secrets.mailserver.alice);
  bobPassword = (builtins.readFile ./.secrets.mailserver.bob);
  sogoPassword = (builtins.readFile ./.secrets.mailserver.sogo);
in
{
  nix.settings.experimental-features = "nix-command flakes";
  imports = [
    ./vpsadminos.nix
#    ./httpd.nix
#    ./openldap.nix
#    ./mailserver.nix
#    ./sogo.nix
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
  systemd.enableUnifiedCgroupHierarchy = false;
  systemd.enableCgroupAccounting = false;
  users.users = rec {
    wwwrun.extraGroups = [ "acme" "sogo" ];
#    memcached.extraGroups = [ "users" ];
#    sogo.extraGroups = [ "users" ];
    mannchri = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [ mannchriRsaPublic ];
      extraGroups = [ "wheel" "networkmanager" ];
    };
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "postmaster@resdigita.org";
    defaults.webroot = "/var/www";
  };
  systemd.extraConfig = ''
    LockPersonality=false
    MemoryDenyWriteExecute=false
    NoNewPrivileges=false
    PrivateDevices=false
    PrivateMounts=false
    PrivateTmp=false
    PrivateUsers=false
    ProtectControlGroups=false
    ProtectHome=false
    ProtectKernelModules=false
    ProtectKernelTunables=false
    ProtectSystem=strict
    RestrictAddressFamilies=AF_UNIX AF_INET AF_INET6
    RestrictRealtime=false
    '';

###################################################################################################################################
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
      ProxyPass /SOGo http://[::1]:20000/SOGo
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
###################################################################################################################################
  services.openldap = {
    enable=true;
    urlList = [ "ldap:///" ];
#    urlList = [ "ldap:///" "ldaps:///" ];
    settings = {
      attrs = {
        olcLogLevel = "conns config";
         /* settings for acme ssl */
#        olcTLSCACertificateFile = "/var/lib/acme/mailtest.resdigita.org/full.pem";
#        olcTLSCertificateFile = "/var/lib/acme/mailtest.resdigita.org/cert.pem";
#        olcTLSCertificateKeyFile = "/var/lib/acme/mailtest.resdigita.org/key.pem";
#        olcTLSCipherSuite = "HIGH:MEDIUM:+3DES:+RC4:+aNULL";
#        olcTLSCRLCheck = "none";
#        olcTLSVerifyClient = "never";
#        olcTLSProtocolMin = "3.1";
      };
      children = {
        "cn=schema".includes = [
          "${pkgs.openldap}/etc/schema/core.ldif"
          "${pkgs.openldap}/etc/schema/cosine.ldif"
          "${pkgs.openldap}/etc/schema/inetorgperson.ldif"
          "${pkgs.openldap}/etc/schema/nis.ldif"
        ];

        "olcDatabase={1}mdb".attrs = {
          objectClass = [ "olcDatabaseConfig" "olcMdbConfig" ];

          olcDatabase = "{1}mdb";
          olcDbDirectory = "/var/lib/openldap/data";

          olcSuffix = "dc=resdigita,dc=org";

          /* your admin account, do not use writeText on a production system */
          olcRootDN = "cn=admin,dc=resdigita,dc=org";
          olcRootPW = (builtins.readFile ./.secrets.adminresdigitaorg);

          olcAccess = [
            /* custom access rules for userPassword attributes */
            ''{0}to attrs=userPassword
                by self write
                by anonymous auth
                by * none''

            /* allow read on anything else */
            ''{1}to *
                by * read''
          ];
        };
      };
    };
    declarativeContents."dc=resdigita,dc=org" = ''
          dn: dc=resdigita,dc=org
          objectClass: domain
          dc: resdigita

          dn: ou=users,dc=resdigita,dc=org
          objectClass: organizationalUnit
          ou: users

          dn: mail=alice@resdigita.org,ou=users,dc=resdigita,dc=org
          objectClass: inetOrgPerson
          cn: alice
          givenName: alice
          sn: Foo
          uid: alice
          mail: alice@resdigita.org
          userPassword: ${alicePassword}

          dn: mail=bob@resdigita.org,ou=users,dc=resdigita,dc=org
          objectClass: inetOrgPerson
          cn: bob
          uid: bob
          givenName: bob
          sn: Bar
          mail: bob@resdigita.org
          userPassword: ${bobPassword}

          dn: mail=sogo@resdigita.org,ou=users,dc=resdigita,dc=org
          objectClass: inetOrgPerson
          cn: sogo
          givenName: sogo
          uid: sogo
          sn: Administrator
          mail: sogo@resdigita.org
          userPassword: ${sogoPassword}

        '';
  };
#  /* ensure openldap is launched after certificates are created */
#  systemd.services.openldap = {
#    wants = [ "acme-mailtest.resdigita.org.service" ];
#    after = [ "acme-mailtest.resdigita.org.service" ];
#  };
#  /* make acme certificates accessible by openldap */
#  security.acme.defaults.group = "certs";
#  users.groups.certs.members = [ "openldap" ];
#  /* trigger the actual certificate generation for your hostname */
#  security.acme.certs."mailtest.resdigita.org" = {
#    extraDomainNames = [];
#  };
###################################################################################################################################
#  services.openldap = {
#    enable=true;
##    urlList = [ "ldap:///" "ldaps:///" ];
#    urlList = [ "ldap:///" ];
#    settings = {
#      attrs = {
#        olcLogLevel = "conns config";
#         /* settings for acme ssl */
##        olcTLSCACertificateFile = "/var/lib/acme/mailtest.resdigita.org/full.pem";
##        olcTLSCertificateFile = "/var/lib/acme/mailtest.resdigita.org/cert.pem";
##        olcTLSCertificateKeyFile = "/var/lib/acme/mailtest.resdigita.org/key.pem";
##        olcTLSCipherSuite = "HIGH:MEDIUM:+3DES:+RC4:+aNULL";
##        olcTLSCRLCheck = "none";
##        olcTLSVerifyClient = "never";
##        olcTLSProtocolMin = "3.1";
#      };
#      children = {
#        "cn=schema".includes = [
#          "${pkgs.openldap}/etc/schema/core.ldif"
#          "${pkgs.openldap}/etc/schema/cosine.ldif"
#          "${pkgs.openldap}/etc/schema/inetorgperson.ldif"
#          "${pkgs.openldap}/etc/schema/nis.ldif"
#        ];
#
#        "olcDatabase={1}mdb".attrs = {
#          objectClass = [ "olcDatabaseConfig" "olcMdbConfig" ];
#
#          olcDatabase = "{1}mdb";
#          olcDbDirectory = "/var/lib/openldap/data";
#
#          olcSuffix = "dc=resdigita,dc=org";
#
#          /* your admin account, do not use writeText on a production system */
#          olcRootDN = "cn=admin,dc=resdigita,dc=org";
#          olcRootPW = (builtins.readFile ./.secrets.adminresdigitaorg);
#
#          olcAccess = [
#            /* custom access rules for userPassword attributes */
#            ''{0}to attrs=userPassword
#                by self write
#                by anonymous auth
#                by * none''
#
#            /* allow read on anything else */
#            ''{1}to *
#                by * read''
#          ];
#        };
#      };
#    };
#    declarativeContents."dc=resdigita,dc=org" = ''
#          dn: dc=org
#          objectClass: domain
#          dc: org
#
#          dn: dc=resdigita,dc=org
#          objectClass: domain
#          dc: resdigita
#
#          dn: cn=mail,dc=resdigita,dc=org
#          objectClass: organizationalRole
#          objectClass: simpleSecurityObject
#          objectClass: top
#          cn: mail
#          userPassword: ${bindPassword}
#
#          dn: ou=users,dc=resdigita,dc=org
#          objectClass: organizationalUnit
#          ou: users
#
#          dn: cn=alice,ou=users,dc=resdigita,dc=org
#          objectClass: inetOrgPerson
#          cn: alice
#          sn: Foo
#          mail: alice@resdigita.org
#          userPassword: ${alicePassword}
#
#          dn: cn=bob,ou=users,dc=resdigita,dc=org
#          objectClass: inetOrgPerson
#          cn: bob
#          sn: Bar
#          mail: bob@resdigita.org
#          userPassword: ${bobPassword}
#        '';
#  };
#  /* ensure openldap is launched after certificates are created */
#  systemd.services.openldap = {
#    wants = [ "acme-mailtest.resdigita.org.service" ];
#    after = [ "acme-mailtest.resdigita.org.service" ];
#  };
#  /* make acme certificates accessible by openldap */
#  security.acme.defaults.group = "certs";
#  users.groups.certs.members = [ "openldap" ];
#  /* trigger the actual certificate generation for your hostname */
#  security.acme.certs."mailtest.resdigita.org" = {
#    extraDomainNames = [];
#  };
#}
#in
#{
#  imports = [
#    ./vpsadminos.nix
#  ];
  mailserver = {
    enable = true;
    fqdn = "mailtest.resdigita.org";
    domains = [ "resdigita.org" ];

    # A list of all login accounts. To create the password hashes, use
    # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
#    loginAccounts.enable = false;
#    loginAccounts = {
#      "user1@resdigita.org" = {
#        hashedPasswordFile = "/etc/nixos/.secrets.user1";
#        aliases = ["postmaster@resdigita.org"];
#      };
#    };

    # Use Let's Encrypt certificates. Note that this needs to set up a stripped
    # down nginx and opens port 80.
    #certificateScheme = "acme-nginx";
#    ldap.enable = true;
#    ldap.bind.dn = "cn=admin,dc=resdigita,dc=org";
#    ldap.bind.passwordFile = "/etc/nixos/.secrets.adminresdigitaorg";
#    ldap.uris = [
#        "ldap:///"
#    ];
  };
###################################################################################################################################
#{ config, pkgs, lib, ... }:
#let 
#  mannchriRsaPublic = (builtins.readFile ./.secrets.mannchri-rsa.pub);
#in
#o{
  services.memcached = {
    enable = true;
    listen = "[::1]";
    enableUnixSocket = true;
    extraOptions = [];
  };

  services.sogo = {
    enable = true;
    language = "fr-fr";
    timezone = "europe/paris";
#      OCSStoreURL = "postgresql:///sogo/sogo_store";
#      OCSAclURL = "postgresql:///sogo/sogo_acl";
#      OCSCacheFolderURL = "postgresql:///sogo/sogo_cache_folder";
      # SOGoForceExternalLoginWithEmail = YES;
    extraConfig = ''
      OCSSessionsFolderURL = "postgresql:///sogo/sogo_sessions_folder";
      OCSEMailAlarmsFolderURL = "postgresql:///sogo/sogo_alarms_folder";
      SOGoProfileURL = "postgresql:///sogo/sogo_user_profile";
      OCSFolderInfoURL = "postgresql:///sogo/sogo_folder_info";
      WOPort = "[::1]:20000";
      WONoDetach = NO;
      WOLogFile = /var/log/sogo/sogo.log;
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
      SOGoMailingMechanism = smtp;
      SOGoSMTPServer = "smtp://localhost:587/?tls=YES&tlsVerifyMode=allowInsecureLocalhost";
      SOGoIMAPServer = "imap://mailtest.resdigita.org:993";
      SOGoTrustProxyAuthentication = YES;
      SOGoUserSources = (
          {
              type = ldap;
              CNFieldName = mail;
              IDFieldName = mail;
              UIDFieldName = mail;
              baseDN = "ou=users,dc=resdigita,dc=org";
              bindDN = "cn=admin,dc=resdigita,dc=org";
              bindPassword = "hUkrazS8Gp7qgxH7UsMr";
              canAuthenticate = YES;
              displayName = "Dir";
              hostname = "ldap:///";
              id = public;
              isAddressBook = YES;
          }
      );
      SOGoMemcachedHost = "[::1]:11211";
      '';
      #SOGoMemcachedHost = "unix:///run/memcached/memcached.sock";
  };
###################################################################################################################################
###################################################################################################################################
###################################################################################################################################
###################################################################################################################################
###################################################################################################################################
###################################################################################################################################
###################################################################################################################################
###################################################################################################################################
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    ensureDatabases = [
      "sogo"
    ];
    settings = {
      max_connections = 150;
      shared_buffers = "60MB";
    };
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
  #services.openssh.settings.PermitRootLogin = "yes";

#  services.roundcube = {
#     enable = true;
#     # this is the url of the vhost, not necessarily the same as the fqdn of
#     # the mailserver
#     hostName = "mailtest.resdigita.org";
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
  allowedTCPPorts = [ 80 443 20000 389 636 11211 ];
#  enable = true;
  enable = false;
  trustedInterfaces = [ "lo" ];
};

#  systemd.extraConfig = ''
#    DefaultTimeoutStartSec=900s
#  '';

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
