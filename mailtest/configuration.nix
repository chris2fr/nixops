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
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/ldap-support/nixos-mailserver-nixos-23.05.tar.gz";
      sha256 = "sha256:15v6b5z8gjspps5hyq16bffbwmq0rwfwmdhyz23frfcni3qkgzpc";
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
    # postgresql
    openldap
    killall
    inetutils
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
      Alias /.woa/WebServerResources/ /var/www/SOGo/WebServerResources/ 
      Alias /SOGo.woa/WebServerResources/  /var/www/SOGo/WebServerResources/ 
      Alias /SOGo/WebServerResources/  /var/www/SOGo/WebServerResources/ 
      Alias /WebServerResources/  /var/www/SOGo/WebServerResources/ 
      <Directory /var/www/SOGo/>
        AllowOverride none
        Require all granted
        <IfModule expires_module>
          ExpiresActive On
          ExpiresDefault "access plus 1 year"
        </IfModule>
      </Directory>
      ProxyPass /.well-known !
      ProxyPass /.woa/WebServerResources/ !
      ProxyPass /SOGo.woa/WebServerResources/  !
      ProxyPass /SOGo/WebServerResources/  !
      ProxyPass /WebServerResources/  !
    #  ProxyPass /principals http://[::1]:20000/SOGo/dav/ interpolate
    #  ProxyPass /SOGo http://[::1]:20000/SOGo interpolate
      ProxyPass /SOGo http://[::1]:20000/SOGo retry=0
      ProxyRequests Off
      SetEnv proxy-nokeepalive 1
      ProxyPreserveHost On
    #  ProxyPassInterpolateEnv On
      CacheDisable /
      <Proxy http://127.0.0.1:20000/SOGo >
        RequestHeader set "x-webobjects-server-port" "443"
        RequestHeader set "x-webobjects-server-name" "mailtest.resdigita.org"
        RequestHeader set "x-webobjects-server-url" "https://mailtest.resdigita.org"
        # When using proxy-side autentication, you need to uncomment and
        ## adjust the following line:
        RequestHeader unset "x-webobjects-remote-user"
        #  RequestHeader set "x-webobjects-remote-user" "%{REMOTE_USER}e" env=REMOTE_USER
        RequestHeader set "x-webobjects-server-protocol" "HTTP/1.0"
        AddDefaultCharset UTF-8
        Order allow,deny
        Allow from all
      </Proxy>
      '';
    };
  };
###################################################################################################################################
  services.openldap = {
    enable = true;
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
          olcRootPW = (builtins.readFile ./.secrets.bind);

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
    ldap.enable = true;
    ldap.bind.dn = "cn=admin,dc=resdigita,dc=org";
    ldap.bind.passwordFile = "/etc/nixos/.secrets.bind";
    ldap.uris = [
        "ldap:///"
    ];
    ldap.searchBase = "ou=users,dc=resdigita,dc=org";
  };
###################################################################################################################################
#{ config, pkgs, lib, ... }:
#let 
#  mannchriRsaPublic = (builtins.readFile ./.secrets.mannchri-rsa.pub);
#in
#o{
  services.memcached = {
    enable = true;
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
      OCSStoreURL = "postgresql:///sogo/sogo_store";
      OCSAclURL = "postgresql:///sogo/sogo_acl";
      OCSCacheFolderURL = "postgresql:///sogo/sogo_cache_folder";
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
      SOGoIMAPServer = "imap://localhost";
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
      SOGoSuperUsernames = ("sogo@resdigita.org");
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
  enable = true;
#  enable = false;
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
