{ config, pkgs, lib, ... }:

let 
  bindPassword = (lib.removeSuffix "\n" (builtins.readFile ./.secrets.adminresdigitaorg));
  alicePassword = (lib.removeSuffix "\n" (builtins.readFile ./.secrets.mailserver.alice));
  bobPassword = (lib.removeSuffix "\n" (builtins.readFile ./.secrets.mailserver.bob));
  sogoPassword = (lib.removeSuffix "\n" (builtins.readFile ./.secrets.mailserver.sogo));
in
{
  imports = [
    (builtins.fetchTarball {
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/ldap-support/nixos-mailserver-nixos-23.05.tar.gz";
      sha256 = "sha256:15v6b5z8gjspps5hyq16bffbwmq0rwfwmdhyz23frfcni3qkgzpc";
    })
  ];
  environment.systemPackages = with pkgs; [
    sogo
    postgresql
    openldap
  ];
  systemd.enableUnifiedCgroupHierarchy = false;
  systemd.enableCgroupAccounting = false;
  users.users."web2ldap" = {
    isNormalUser = true;

  };
################################################################################################################
  services.httpd.virtualHosts."lesgv.com" = {
    serverAliases = ["mail.resdigita.org" "www.lesgv.com" "lesgv.org" "resdigita.org" "www.resdigita.org" "resdigita.com" "www.lesgv.org" "www.resdigita.com"];
      enableACME = true;
      forceSSL = true;
      # documentRoot =  "/var/www/SOGo";
      globalRedirect = "https://mail.resdigita.com";
  };
  services.httpd.virtualHosts."mail.resdigita.com" = {
      enableACME = true;
      forceSSL = true;
      documentRoot =  "/var/www/SOGo";
      extraConfig = ''
      Alias /SOGo.woa/WebServerResources/js/theme.js /var/www/SOGo/WebServerResources/theme.js
      Alias /.woa/WebServerResources/ /var/www/SOGo/WebServerResources/
      Alias /SOGo.woa/WebServerResources/ /var/www/SOGo/WebServerResources/
      Alias /SOGo/WebServerResources/ /var/www/SOGo/WebServerResources/
      Alias /WebServerResources/ /var/www/SOGo/WebServerResources/
#      Alias /.woa/WebServerResources/ /run/current-system/sw/lib/GNUstep/SOGo/WebServerResources/
#      Alias /SOGo.woa/WebServerResources/ /run/current-system/sw/lib/GNUstep/SOGo/WebServerResources/
#      Alias /SOGo/WebServerResources/ /run/current-system/sw/lib/GNUstep/SOGo/WebServerResources/
#      Alias /WebServerResources/ /run/current-system/sw/lib/GNUstep/SOGo/WebServerResources/
#      <Directory /run/current-system/sw/lib/GNUstep/SOGo/WebServerResources/>
      <Directory /var/www/SOGo/WebServerResources/>
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
      ProxyPass /SOGo/ http://[::1]:20000/SOGo/ retry=0
      ProxyPass /SOGo http://[::1]:20000/SOGo retry=0
      ProxyPass / http://localhost:9991/ retry=0
      ProxyRequests Off
      SetEnv proxy-nokeepalive 1
      ProxyPreserveHost On
      CacheDisable /
      <Proxy http://127.0.0.1:20000/SOGo >
        SetEnvIf Host (.*) custom_host=$1
        RequestHeader set "x-webobjects-server-name" "%{custom_host}e"
        RequestHeader set "x-webobjects-server-url" "https://%{custom_host}e"
        RequestHeader set "x-webobjects-server-port" "443"
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
###################################################################################################################################
  services.openldap = {
    enable = true;
    # urlList = [ "ldap:///" ];
    urlList = [ "ldap:///" "ldaps:///" ];
    settings = {
      attrs = {
        olcLogLevel = "conns config";
         /* settings for acme ssl */
          olcTLSCACertificateFile = "/var/lib/acme/mail.resdigita.com/full.pem";
          olcTLSCertificateFile = "/var/lib/acme/mail.resdigita.com/cert.pem";
          olcTLSCertificateKeyFile = "/var/lib/acme/mail.resdigita.com/key.pem";
        olcTLSCipherSuite = "HIGH:MEDIUM:+3DES:+RC4:+aNULL";
        olcTLSCRLCheck = "none";
        olcTLSVerifyClient = "never";
        olcTLSProtocolMin = "3.1";
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
          olcRootPW = (builtins.readFile /etc/nixos/.secrets.adminresdigitaorg);

          olcAccess = [
            /* custom access rules for userPassword attributes */
            /* allow read on anything else */
            ''{0}to dn.subtree="ou=newusers,dc=resdigita,dc=org"
                by dn.exact="cn=newuser@lesgv.com,ou=users,dc=resdigita,dc=org" write
                by group.exact="cn=administration,ou=groups,dc=resdigita,dc=org" write
                by self write''
            ''{1}to attrs=userPassword
                by self write
                by anonymous auth
                by * none''
            ''{2}to *
                by dn.exact="cn=sogo@resdigita.org,ou=users,dc=resdigita,dc=org" manage
                by dn.exact="cn=chris@lesgrandsvoisins.com,ou=users,dc=resdigita,dc=org" manage
                by self write''
            /* custom access rules for userPassword attributes */
            ''{3}to attrs=cn,sn,givenName,displayName,member,memberof
                by self write
                by * read''
            ''{4}to *
                by * read''
          ];
        };
      };
    };
#    declarativeContents."dc=resdigita,dc=org" = ''
#          dn: dc=resdigita,dc=org
#          objectClass: domain
#          dc: resdigita
#
#          dn: ou=users,dc=resdigita,dc=org
#          objectClass: organizationalUnit
#          ou: users
#
#          dn: ou=mailings,dc=resdigita,dc=org
#          objectClass: organizationalUnit
#          ou: mailings
#
#          dn: ou=groups,dc=resdigita,dc=org
#          objectClass: organizationalUnit
#          ou: groups
#
#          dn: ou=invitations,dc=resdigita,dc=org
#          objectClass: organizationalUnit
#          ou: invitations
#
#          dn: cn=alice@resdigita.org,ou=users,dc=resdigita,dc=org
#          objectClass: inetOrgPerson
#          cn: alice@resdigita.org
#          givenName: alice
#          sn: Foo
#          uid: alice
#          mail: alice@resdigita.org
#          userPassword: ${alicePassword}
#
#          dn: cn=bob@resdigita.org,ou=users,dc=resdigita,dc=org
#          objectClass: inetOrgPerson
#          cn: bob@resdigita.org
#          uid: bob
#          givenName: bob
#          sn: Bar
#          mail: bob@resdigita.org
#          userPassword: ${bobPassword}
#
#          dn: cn=sogo@resdigita.org,ou=users,dc=resdigita,dc=org
#          objectClass: inetOrgPerson
#          cn: sogo@resdigita.org
#          givenName: sogo
#          uid: sogo
#          sn: Administrator
#          mail: sogo@resdigita.org
#          userPassword: ${sogoPassword}
#
#        '';
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
#############################
systemd.services.openldap = {
  wants = [ "acme-mail.resdigita.com.service" ];
  after = [ "acme-mail.resdigita.com.service" ];
};
users.groups.wwwrun.members = [ "openldap" ];
###################################################################################################################################
  mailserver = {
    enable = true;
    fqdn = "mail.resdigita.com";
    domains = [ "resdigita.org" "resdigita.com" "lesgrandsvoisins.com" ];

    # Use Let's Encrypt certificates. Note that this needs to set up a stripped
    # down nginx and opens port 80.
    #certificateScheme = "acme-nginx";
    ldap.enable = true;
    ldap.bind.dn = "cn=admin,dc=resdigita,dc=org";
    ldap.bind.passwordFile = "/etc/nixos/.secrets.adminresdigitaorg";
    ldap.uris = [
        "ldap://mail.resdigita.com/"
    ];
    ldap.searchBase = "ou=users,dc=resdigita,dc=org";
    # ldap.dovecot.passFilter = "(&(objectClass=inetOrgPerson)(cn=%u))";
    # ldap.dovecot.userFilter = "(&(objectClass=inetOrgPerson)(cn=%u))";
    # ldap.postfix.filter = "(&(objectClass=inetOrgPerson)(cn=%u))";
    ldap.postfix.mailAttribute = "cn";
    ldap.postfix.uidAttribute = "cn";
    # ldap.postfix.filter = "";
    # ldap.dovecot.userAttrs = ''
    #   =mail=%{ldap:cn}
    # '';
    # ldap.dovecot.userAttrs = ''
    #   =home=%{ldap:homeDirectory}, \
    #        =uid=%{ldap:uidNumber}, \
    #        =gid=%{ldap:gidNumber}
    # '';
  };
###################################################################################################################################
  services.memcached = {
    enable = true;
  };

  services.sogo = {
    enable = true;
    language = "fr-fr";
    timezone = "europe/paris";
    # SOGoForceExternalLoginWithEmail = YES;
    extraConfig = ''
      SOGoUIAdditionalJSFiles = ("js/theme.js", "lesgv.js");
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
      SOGoMailDomain = "lesgv.com";
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
      SOGoPageTitle = "resdigita.com";
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
              CNFieldName = displayName;
              IDFieldName = uid;
              UIDFieldName = uid;
              MailFieldNames = ("mail");
              baseDN = "ou=users,dc=resdigita,dc=org";
              bindDN = "cn=admin,dc=resdigita,dc=org";
              bindPassword = "${bindPassword}";
              canAuthenticate = YES;
              displayName = "Dir";
              hostname = "ldaps://mail.resdigita.com/";
              id = public;
              isAddressBook = YES;
          }
      );
      SOGoSuperUsernames = ("sogo@resdigita.org","chris@lesgrandsvoisins.com");
      '';
      #SOGoMemcachedHost = "unix:///run/memcached/memcached.sock";
  };
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
###################################################################################################################################
  networking.firewall = {
    allowedTCPPorts = [ 80 443 20000 389 636 11211 ];
    enable = true;
    trustedInterfaces = [ "lo" ];
  };

  systemd.extraConfig = ''
    DefaultTimeoutStartSec=900s
  '';
}
