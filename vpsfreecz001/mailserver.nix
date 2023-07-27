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
    documentRoot =  "/var/www/SOGo";
    globalRedirect = "https://mail.lesgrandsvoisins.com/";
  };
  services.httpd.virtualHosts."mail.lesgrandsvoisins.com" = {
    enableACME = true;
    forceSSL = true;
    documentRoot =  "/var/www/SOGo";
    extraConfig = ''
    Alias /SOGo.woa/WebServerResources/js/theme.js /var/www/SOGo/WebServerResources/theme.js
    Alias /.woa/WebServerResources/ /var/www/SOGo/WebServerResources/
    Alias /SOGo.woa/WebServerResources/ /var/www/SOGo/WebServerResources/
    Alias /SOGo/WebServerResources/ /var/www/SOGo/WebServerResources/
    Alias /WebServerResources/ /var/www/SOGo/WebServerResources/
    Redirect "/" "/SOGo/"
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
    # ProxyPass /SOGo/ http://[::1]:20000/SOGo/ retry=0

    ProxyRequests Off
    SetEnv proxy-nokeepalive 1
    ProxyPreserveHost On
    CacheDisable /
    <Proxy http://[::1]:20000/ >
      SetEnvIf Host (.*) custom_host=$1
      RequestHeader set "x-webobjects-server-name" "%{custom_host}e"
      RequestHeader set "x-webobjects-server-url" "https://%{custom_host}e/SOGo/"
      RequestHeader set "x-webobjects-server-port" "443"
      # When using proxy-side autentication, you need to uncomment and
      ## adjust the following line:
      RequestHeader unset "x-webobjects-remote-user"
      #  RequestHeader set "x-webobjects-remote-user" "%{REMOTE_USER}e" env=REMOTE_USER
      RequestHeader set "x-webobjects-server-protocol" "HTTP/1.0"
      AddDefaultCharset UTF-8
      Order allow,deny
      Allow from all
      # RewriteEngine On
      # RewriteRule SOGo/(.*)$ $1 [P]
      # Header edit Location ^https://%{custom_host}e/SOGo/(.*) http://%{custom_host}e/$1
    </Proxy>
    '';
  };
  services.httpd.virtualHosts."mail.resdigita.com" = {
    serverAliases = ["gvoisin.com" "www.gvoisin.com" "mail.gvoisin.com" "gvoisin.org" "www.gvoisin.org" "gvoisins.org" "www.gvoisins.org" "gvoisins.com" "www.gvoisins.com" "app.lesgrandsvoisins.com"];
    enableACME = true;
    forceSSL = true;
    documentRoot =  "/var/www/SOGo";
    extraConfig = ''
    Alias /SOGo.woa/WebServerResources/js/theme.js /var/www/SOGo/WebServerResources/theme.js
    Alias /.woa/WebServerResources/ /var/www/SOGo/WebServerResources/
    Alias /SOGo.woa/WebServerResources/ /var/www/SOGo/WebServerResources/
    Alias /SOGo/WebServerResources/ /var/www/SOGo/WebServerResources/
    Alias /WebServerResources/ /var/www/SOGo/WebServerResources/
 
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
    <Proxy http://127.0.0.1:20000/SOGo/ >
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
                by self write
                by anonymous auth
                by * read''
            ''{1}to dn.subtree="ou=invitations,dc=resdigita,dc=org"
                by dn.exact="cn=newuser@lesgv.com,ou=users,dc=resdigita,dc=org" write
                by group.exact="cn=administration,ou=groups,dc=resdigita,dc=org" write
                by self write
                by anonymous auth
                by * read''
            ''{2}to dn.subtree="ou=users,dc=resdigita,dc=org"
                by dn.exact="cn=newuser@lesgv.com,ou=users,dc=resdigita,dc=org" write
                by group.exact="cn=administration,ou=groups,dc=resdigita,dc=org" write
                by self write
                by anonymous auth
                by * read''
            ''{3}to attrs=userPassword
                by self write
                by anonymous auth
                by * none''
            ''{4}to *
                by dn.exact="cn=sogo@resdigita.org,ou=users,dc=resdigita,dc=org" manage
                by dn.exact="cn=chris@lesgrandsvoisins.com,ou=users,dc=resdigita,dc=org" manage
                by self write
                by anonymous auth''
            /* custom access rules for userPassword attributes */
            ''{5}to attrs=cn,sn,givenName,displayName,member,memberof
                by self write
                by * read''
            ''{6}to *
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
    domains = [ "resdigita.org" "resdigita.com" "lesgrandsvoisins.com" "lesgv.com" "lesgv.org" "gvoisin.com" "gvoisin.org" "gvoisins.org" "gvoisins.com"];

    # Use Let's Encrypt certificates. Note that this needs to set up a stripped
    # down nginx and opens port 80.
    #certificateScheme = "acme-nginx";
    # certificateDomains = ("mail.resdigita.com" "gvoisin.com" );
    certificateFile = "/var/certs/cert-mail.resdigita.com.pem";
    certificateScheme = "acme";
    certificateDirectory = "/var/certs/";
    keyFile = "/var/certs/key-mail.resdigita.com.pem";
    ldap.enable = true;
    ldap.bind.dn = "cn=admin,dc=resdigita,dc=org";
    ldap.bind.passwordFile = "/etc/nixos/.secrets.adminresdigitaorg";
    ldap.uris = [
        "ldap:///"
    ];
    ldap.searchBase = "ou=users,dc=resdigita,dc=org";
    #ldap.startTls = true;
    ldap.tlsCAFile = "/var/certs/cert-mail.resdigita.com.pem";
    # ldap.dovecot.passFilter = "(&(objectClass=inetOrgPerson)(cn=%u))";
    # ldap.dovecot.userFilter = "(&(objectClass=inetOrgPerson)(cn=%u))";
    # ldap.postfix.filter = "(&(objectClass=inetOrgPerson)(cn=%u))";
    ldap.postfix.mailAttribute = "mail";
    ldap.postfix.uidAttribute = "mail";
    # ldap.postfix.filter = "";
    # ldap.dovecot.userAttrs = ''
    #   =mail=%{ldap:cn}
    # '';
    # ldap.dovecot.userAttrs = ''
    #   =home=%{ldap:homeDirectory}, \
    #        =uid=%{ldap:uidNumber}, \
    #        =gid=%{ldap:gidNumber}
    # '';
    fullTextSearch = {
      enable = false;
      # index new email as they arrive
      autoIndex = true;
      # this only applies to plain text attachments, binary attachments are never indexed
      indexAttachments = false;
      enforced = "body";
    };
  };
#############################################
  services.postfix.config.maillog_file = "/var/log/postfix.log";
  # /run/current-system/sw/bin/postlog
  services.postfix.masterConfig.postlog = {
    command = "postlogd";
    type = "unix-dgram";
    privileged = true;
    private = false;
    chroot = false;
    maxproc = 1;
  };
###################################################################################################################################
  services.memcached = {
    enable = true;
  };

  services.sogo = {
    enable = true;
    language = "fr-fr";
    timezone = "europe/paris";

    #       SOGoEnableDomainBasedUID = YES;
      # SOGoLoginDomains = ("lesgv.com", "lesgrandsvoisins.com", "gvoisin.com", "resdigita.org");
      # SOGoDomainsVisibility = ("lesgv.com", "lesgrandsvoisins.com");
    # 
    #       SOGoUIxDebugEnabled 
    # 
    extraConfig = ''
      SOGoUIxDebugEnabled = NO;
      SOGoHelpURL = "https://www.lesgrandsvoisins.com";
      SOGoForceExternalLoginWithEmail = YES;
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
      SOGoMailDomain = "resdigita.org";
      SOGoLanguage = French;
      SOGoAppointmentSendEMailNotifications = YES;
      SOGoEnablePublicAccess = YES;
      SOGoSMTPAuthenticationType = PLAIN;
      SOGoIMAPAclConformsToIMAPExt = YES;
      SOGoTimeZone = "Europe/Paris";
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
      SOGoPageTitle = "gvoisin.com";
      SOGoLoginModule = Mail;
      SOGoMailAddOutgoingAddresses = YES;
      SOGoSelectedAddressBook = autobook;
      SOGoMailAuxiliaryUserAccountsEnabled = YES;
      SOGoCalendarEventsDefaultClassification = PRIVATE;
      SOGoMailReplyPlacement = above;
      SOGoMailSignaturePlacement = above;
      SOGoMailComposeMessageType = html;
      SOGoMailingMechanism = smtp;
      SOGoSMTPServer = "smtps://mail.resdigita.com/";
      SOGoIMAPServer = "imaps://mail.resdigita.com/";
      SOGoTrustProxyAuthentication = YES;
      SOGoUserSources = (
        {
          id = public;
          type = ldap;
          CNFieldName = displayName;
          IDFieldName = cn;
          UIDFieldName = cn;
          baseDN = "ou=users,dc=resdigita,dc=org";
          bindDN = "cn=admin,dc=resdigita,dc=org";
          bindPassword = "${bindPassword}";
          canAuthenticate = YES;
          displayName = "Dir";
          hostname = "mail.resdigita.com";
          isAddressBook = YES;
          MailFieldNames = ("mail");
          IMAPLoginFieldName = mail;
          mapping = {
            mozillasecondemail = ("carLicense");
            mozillaworkurl = ("labeldURI");
            givenName = ("givenName");
            sn = ("sn");
            displayName = ("displayName");
            mail = ("mail");
            telephoneNumber = ("telephoneNumber");
            mobile = ("mobile");
            homephone = ("homephone");
            title = ("title");
            ou = ("ou");
            o = ("o");
            street = ("street");
            l = ("l");
            st = ("st");
            postalCode = ("postalCode");
            c = ("c");
            description = ("description");
            photo = ("photo");
          }
        }
      );
      SOGoSuperUsernames = ("sogo@resdigita.org", "chris@lesgrandsvoisins.com", "chris");
      '';
      #SOGoMemcachedHost = "unix:///run/memcached/memcached.sock";
                    # MailFieldNames = ("mail");
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
    allowedTCPPorts = [ 80 443 20000 389 636 993 11211 ];
    enable = true;
    trustedInterfaces = [ "lo" ];
  };

  systemd.extraConfig = ''
    DefaultTimeoutStartSec=900s
  '';

###################################################################################################################################

services.fail2ban = {
    enable = true;
    maxretry = 5; # Observe 5 violations before banning an IP
    ignoreIP = [
      # Whitelisting some subnets:
      "10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16"
      "8.8.8.8" # Whitelists a specific IP
      "mail.resdigita.com" # Resolves the IP via DNS
    ];
    bantime = "24h"; # Set bantime to one day
    bantime-increment = {
      enable = true; # Enable increment of bantime after each violation
      formula = "ban.Time * math.exp(float(ban.Count+1)*banFactor)/math.exp(1*banFactor)";
      # multipliers = "1 2 4 8 16 32 64";
      maxtime = "168h"; # Do not ban for more than 1 week
      overalljails = true; # Calculate the bantime based on all the violations
    };
    jails = {
      apache-nohome-iptables = ''
        # Block an IP address if it accesses a non-existent
        # home directory more than 5 times in 10 minutes,
        # since that indicates that it's scanning.
        filter = apache-nohome
        action = iptables-multiport[name=HTTP, port="http,https"]
        logpath = /var/log/httpd/error_log*
        backend = auto
        findtime = 600
        bantime  = 600
        maxretry = 5
      '';
      postfix = ''
        port     = smtp,465,submission,imap,imaps,pop3,pop3s
        action = iptables-multiport[name=HTTP, port="smtp,465,submission,imap,imaps,pop3,pop3s"]
        logpath  = /var/log/postfix.log
        backend  = auto
        enabled  = true
        filter   = postfix[mode=auth]
        mode     = more
      '';
      # dovecot = ''
      #   port     = smtp,465,submission
      #   logpath  = /var/log/fail2ban.log
      #   backend  = auto
      #   enabled  = true
      #   mode     = more
      # '';
      # postfix-sasl = ''
      #   filter   = postfix[mode=auth]
      #   port     = smtp,465,submission,imap,imaps,pop3,pop3s
      #   logpath  = /var/log/fail2ban.log
      #   backend  = auto
      #   enabled  = true
      #   mode     = more
      # '';
    };
  };

###################################################################################################################################
}