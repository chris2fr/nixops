{ config, pkgs, lib, ... }:

let 
  bindPassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.bind));
  alicePassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.alice));
  bobPassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.bob));
  sogoPassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.sogo));
  oauthPassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.oauthpassword));
  domainName = import mailserver/vars/domain-name-mx.nix;
  ldapBaseDCDN = import /etc/nixos/mailserver/vars/ldap-base-dc-dn.nix;
  mailServerDomainAliases = [ 
    "lesgrandsvoisins.com"
    #"mail.lesgrandsvoisins.com"
    #"mail.resdigita.com"
    "resdigita.com"
    "francemali.org"
    #"desgrandsvoisins.com"
    #"mail.desgrandsvoisins.com"
    #"mail.resdigita.org"
    "gv.coop"
    #"mail.gv.coop"
    "lesgrandsvoisins.fr"
    "hopgv.com"
    "hopgv.org"
    "gvois.com"
    "gvois.org"
    "resdigita.org"
    "cfran.org"
    "gvpublic.org"
    "gvpublic.com"
    "fastoche.org"
    "village.ngo"
    "village.ong"
    "villageparis.org"
  ];
in
{
  imports = [
    (builtins.fetchTarball {
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/nixos-24.05/nixos-mailserver-nixos-24.05.tar.gz";
      sha256 = "sha256:0clvw4622mqzk1aqw1qn6shl9pai097q62mq1ibzscnjayhp278b";
      # url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/ldap-support/nixos-mailserver-nixos-24.05.tar.gz";
      # sha256 = "sha256:15v6b5z8gjspps5hyq16bffbwmq0rwfwmdhyz23frfcni3qkgzpc";
    })
    ./mailserver/sogo.nix
    ./mailserver/ldap.nix
    ./mailserver/httpd.nix
    ./mailserver/fail2ban.nix
  ];
  environment.systemPackages = with pkgs; [
    sogo
    # postgresql_14
    openldap
    pwgen
  ];
  users.users.nginx.extraGroups = ["wwwrun"];
    services.phpfpm.pools."roundcube" = {
    settings = {
      "listen.owner" = lib.mkForce "wwwrun";
      "listen.group" = lib.mkForce "wwwrun";
    };
    #  phpEnv."PATH" = lib.makeBinPath [ pkgs.php ];
  };
  services.dovecot2.sieve.scripts = {};
  services.dovecot2.sieve.extensions = [
      "notify"
      "imapflags"
      "vnd.dovecot.filter"
      "fileinto"
    ];
  services = {
    postfix.virtual = ''
        axel.leroux@resdigita.com axel.leroux@lesgrandsvoisins.com
        alex.leroux@resdigita.com axel.leroux@lesgrandsvoisins.com
        alex.quatorzien@resdigita.com axel.leroux@lesgrandsvoisins.com
        axel.quatorzien@resdigita.com axel.leroux@lesgrandsvoisins.com
        alex.desmoulins@resdigita.com axel.leroux@lesgrandsvoisins.com
        axel.desmoulins@resdigita.com axel.leroux@lesgrandsvoisins.com
        testalias@resdigita.com chris@lesgrandsvoisins.com
        bienvenue@lesgrandsvoisins.com chris@lesgrandsvoisins.com
        chris@lesgrandsvoisins.fr chris@lesgrandsvoisins.com
        chris@fastoche.org chris@lesgrandsvoisins.com
        lesgdvoisins@lesgrandsvoisins.com chris@lesgrandsvoisins.com
        quiquoietc@lesgrandsvoisins.com chris@lesgrandsvoisins.com
        whowhatetc@lesgrandsvoisins.com chris@lesgrandsvoisins.com
        gdvoisins@lesgrandsvoisins.com chris@lesgrandsvoisins.com
        grandvoisinage@lesgrandsvoisins.com chris@lesgrandsvoisins.com
        lesgrandsvoisins@lesgrandsvoisins.com chris@lesgrandsvoisins.com
        lex.larue.fcbk@lesgrandsvoisins.com axel.leroux@lesgrandsvoisins.com
        lex.larue.zytho@lesgrandsvoisins.com axel.leroux@lesgrandsvoisins.com
        alex.larue.kcbk@lesgrandsvoisins.com axel.leroux@lesgrandsvoisins.com
        blex.larue.rock@lesgrandsvoisins.com axel.leroux@lesgrandsvoisins.com
        lex.larue.gml@lesgrandsvoisins.com axel.leroux@lesgrandsvoisins.com
        lex.larue.fcbk@resdigita.com axel.leroux@lesgrandsvoisins.com
        lex.larue.zytho@resdigita.com axel.leroux@lesgrandsvoisins.com
        alex.larue.kcbk@resdigita.com axel.leroux@lesgrandsvoisins.com
        blex.larue.rock@resdigita.com axel.leroux@lesgrandsvoisins.com
        lex.larue.gml@resdigita.com axel.leroux@lesgrandsvoisins.com
    '';
    
    memcached = {
      enable = true;
      # maxMemory = 256;
      # enableUnixSocket = true;
      # port = 11211;
      # listen = "[::1]";
      # user = "sogo";
    };
  };

# SOGoMemcachedHost = "/var/run/memcached.sock";
###################################################################################################################################
  mailserver = {
    enable = true;
    fqdn = domainName;
    domains = mailServerDomainAliases;
    certificateScheme = "acme";
    certificateFile = "/var/lib/acme/${domainName}/fullchain.pem";
    certificateDirectory = "/var/lib/acme/${domainName}/";
    keyFile =  "/var/lib/acme/${domainName}/key.pem"; 
    messageSizeLimit = 209715200;
    # loginAccounts = {
    #   "chris@lesgrandsvoisins.com" = {
    #       aliases = [ "testalias@resdigita.com" ];
    #   };
    # };   
      indexDir = "/var/lib/dovecot/indices";
      # loginAccounts."chris@lesgrandsvoisins.com".catchAll = [
      #   "lesgrandsvoisins.com"
      #   "lesgrandsvoisins.fr"
      #   "resdigita.com"
      # ];
    ldap = {
      enable = true;
      bind = {
        dn = "cn=admin,${ldapBaseDCDN}";
        passwordFile = "/etc/nixos/.secrets.bind";
      };
      uris = [
        "ldap://ldap.lesgrandsvoisins.com:14389/"
        # "ldap:///"
        # "ldaps://ldap.gv.coop:10636/"
        # "ldap://ldap.gv.coop:10389/"
      ];
      searchBase = "ou=users,${ldapBaseDCDN}";
      searchScope = "sub";
      # tlsCAFile = "/var/lib/acme/${domainName}/fullchain.pem";
      # tlsCAFile = "/var/lib/acme/ldap.gv.coop/fullchain.pem";
      startTls = true;
      # startTls = false;
      postfix = {
        mailAttribute = "mail";
        uidAttribute = "cn";
        #  filter = "(cn=%s)";
      };
      # postfix.filter = "(&(objectClass=inetOrgPerson)(cn=%u))";
      # postfix.filter = "";
      # dovecot.userAttrs = ''
      #   =mail=%{ldap:cn}
      # '';
      # dovecot.userAttrs = ''
      #   =home=%{ldap:homeDirectory}, \
      #        =uid=%{ldap:uidNumber}, \
      #        =gid=%{ldap:gidNumber}
      # '';
      # dovecot = {
      #   userFilter = "(mail=%u)";
      #   passFilter = "(|(cn=%u)(uid=%u)(mail=%u))";
      # };
    };
    # extraVirtualAliases = {
    #   "axel.leroux@lesgrandsvoisins.com" = [
    #     "axel.leroux@resdigita.com  "
    #     "alex.leroux@resdigita.com "
    #     "alex.quatorzien@resdigita.com"
    #     "axel.quatorzien@resdigita.com"
    #     "alex.desmoulins@resdigita.com"
    #     "axel.desmoulins@resdigita.com"
    #   ];
    #   "chris@lesgrandsvoisins.com" = [
    #     "testalias@resdigita.com"
    #     "bienvenue@lesgrandsvoisins.com"
    #     "chris@lesgrandsvoisins.fr"
    #     "chris@fastoche.org"
    #     "lesgdvoisins@lesgrandsvoisins.com"
    #     "quiquoietc@lesgrandsvoisins.com"
    #     "whowhatetc@lesgrandsvoisins.com"
    #     "gdvoisins@lesgrandsvoisins.com"
    #     "grandvoisinage@lesgrandsvoisins.com"
    #     "lesgrandsvoisins@lesgrandsvoisins.com"
    #     "@resdigita.com"
    #     "@resdigita.org"
    #     "@cfran.org"
    #     "@hopgv.com"
    #     "@hopgv.org"
    #     "@gvois.com"
    #   ];
    # };
    # forwards = {
    #     "axel.leroux@resdigita.com" = "axel.leroux@lesgrandsvoisins.com";
    #     "alex.leroux@resdigita.com" = "axel.leroux@lesgrandsvoisins.com";
    #     "alex.quatorzien@resdigita.com" = "axel.leroux@lesgrandsvoisins.com";
    #     "axel.quatorzien@resdigita.com" = "axel.leroux@lesgrandsvoisins.com";
    #     "alex.desmoulins@resdigita.com" = "axel.leroux@lesgrandsvoisins.com";
    #     "axel.desmoulins@resdigita.com" = "axel.leroux@lesgrandsvoisins.com";
    #     "testalias@resdigita.com" = "chris@lesgrandsvoisins.com";
    #     "bienvenue@lesgrandsvoisins.com" = "chris@lesgrandsvoisins.com";
    #     "chris@lesgrandsvoisins.fr" = "chris@lesgrandsvoisins.com";
    #     "chris@fastoche.org" = "chris@lesgrandsvoisins.com";
    #     "lesgdvoisins@lesgrandsvoisins.com" = "chris@lesgrandsvoisins.com";
    #     "quiquoietc@lesgrandsvoisins.com" = "chris@lesgrandsvoisins.com";
    #     "whowhatetc@lesgrandsvoisins.com" = "chris@lesgrandsvoisins.com";
    #     "gdvoisins@lesgrandsvoisins.com" = "chris@lesgrandsvoisins.com";
    #     "grandvoisinage@lesgrandsvoisins.com" = "chris@lesgrandsvoisins.com";
    #     "lesgrandsvoisins@lesgrandsvoisins.com" = "chris@lesgrandsvoisins.com";
    #     "@gvois.org" = "chris@lesgrandsvoisins.com";
    #     "@resdigita.com" = "chris@lesgrandsvoisins.com";
    #     "@resdigita.org" = "chris@lesgrandsvoisins.com";
    #     "@cfran.org" = "chris@lesgrandsvoisins.com";
    #     "@hopgv.com" = "chris@lesgrandsvoisins.com";
    #     "@hopgv.org" = "chris@lesgrandsvoisins.com";
    #     "@gvois.com" = "chris@lesgrandsvoisins.com";
    # };
    fullTextSearch = {
      enable = true;
      # index new email as they arrive
      autoIndex = true;
      # this only applies to plain text attachments, binary attachments are never indexed
      indexAttachments = false;
      enforced = "yes";
      memoryLimit = 2000;
    };
    # forwards = {
    #   "postmaster@lesgrandsvoisins.com" = "chris@lesgrandsvoisins.com";
    #   "dmarc@lesgrandsvoisins.com" = "chris@lesgrandsvoisins.com";
    # };

    # Use Let's Encrypt certificates. Note that this needs to set up a stripped
    # down nginx and opens port 80.
    # certificateScheme = "acme-nginx";
    # certificateDomains = ("mail.resdigita.com" "gvoisin.com" );
    # certificateFile = "/var/certs/cert-mail.resdigita.com.pem";
    # certificateScheme = "acme";
    # certificateDirectory = "/var/certs/";
    # keyFile = "/var/certs/key-mail.resdigita.com.pem";
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
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    ensureDatabases = [
      "sogo"
      "odoo"
      "odootoo"
      "odoothree"
      "odoofor"
    ];
    settings = {
      max_connections = 150;
      shared_buffers = "60MB";
    };
    ensureUsers = [
      {
        name = "sogo";
        ensureDBOwnership = true;
      }
    ];
  };
###################################################################################################################################
  networking.firewall = {
    allowedTCPPorts = [ 80 443 20000 389 636 993 11211 14389 14636 ];
    enable = true;
    trustedInterfaces = [ "lo" ];
  };

  systemd.extraConfig = ''
    DefaultTimeoutStartSec=600s
  '';

  services.roundcube = {
     enable = true;
     # this is the url of the vhost, not necessarily the same as the fqdn of
     # the mailserver
     hostName = "mail.lesgrandsvoisins.com";
    #  dicts =  [ en fr de ];
     extraConfig = ''
        # starttls needed for authentication, so the fqdn required to match
        # the certificate
        $config['smtp_server'] = "tls://mail.lesgrandsvoisins.com";
        $config['smtp_user'] = "%u";
        $config['smtp_pass'] = "%p";
        # $config['oauth_provider'] = 'generic';
        # $config['oauth_provider_name'] = 'authentik';
        # $config['oauth_client_id'] = 'q3nTVQdV2ctY8GeNKvPuHokNa5RxT0VhZbVFCyY3';
        # $config['oauth_client_secret'] = '${oauthPassword}';
        # $config['oauth_auth_uri'] = 'https://authentik.resdigita.com/application/o/authorize/';
        # $config['oauth_token_uri'] = 'https://authentik.resdigita.com/application/o/token/';
        # $config['oauth_identity_uri'] = 'https://authentik.resdigita.com/application/o/userinfo/';
        # $config['oauth_scope'] = "openid dovecotprofile email";
        # $config['oauth_auth_parameters'] = [];
        # $config['oauth_identity_fields'] = ['email'];
        $config['generic_message_footer_html'] = '<a href="https://www.lesgrandsvoisins.com">Les Grands Voisins .com comme communautés</a>';
        $config['session_samesite'] = "Lax";
        $config['support_url'] = 'https://www.lesgrandsvoisins.com';
        $config['product_name'] = 'Roundcube Webmail des GV';
        $config['session_debug'] = true;
        $config['session_domain'] = 'mail.lesgrandsvoisins.com';
        $config['login_password_maxlen'] = 4096;
     '';
     dicts = [ pkgs.aspellDicts.fr pkgs.aspellDicts.en ];
     maxAttachmentSize = 75;
  };
  users.users.dovecot2.extraGroups = ["wwwrun"];
  # services.postfix.config = {
  #   "smtpd_relay_restrictions" = lib.mkForce "permit_sasl_authenticated, reject";
  #   "smtpd_sasl_type" = lib.mkForce "dovecot";
  #   "smtpd_sasl_path" = lib.mkForce "private/auth";
  #   "smtpd_sasl_auth_enable" = lib.mkForce "yes";
  # };

  #services.postfix.networks = [
  #  "localhost"
  #  "127.0.0.1"
  #  "[::1]"
  #  "mail.resdigita.com"
  #  "mail.lesgrandsvoisins.com"
  #  "ooo.lesgrandsvoisins.com"
  #  "51.159.223.7"
  #  "2001:bc8:1201:900:46a8:42ff:fe22:e5b6"
  #  ];
  # services.nginx.virtualHosts."hetzner005.lesgrandsvoisins.com" = {
  #   listen = [{ addr = "[::]"; port=8443; ssl=true; }  { addr = "0.0.0.0"; port=8443; ssl=true; } ];
  #   sslCertificateKey = "/var/lib/acme/hetzner005.lesgrandsvoisins.com/key.pem";
  #   sslCertificate = "/var/lib/acme/hetzner005.lesgrandsvoisins.com/fullchain.pem";
  #   http2 = true;
  #   addSSL = true;
  #   locations."/".extraConfig = ''
  #       grpc_pass grpc://localhost:8080;
  #       grpc_set_header Host $host:$server_port;
  #       grpc_set_header X-Forwarded-Proto "https";
  #       grpc_set_header X-Forwarded-Port "443";
  #   '';
  # };
  # services.nginx.virtualHosts."mail.lesgrandsvoisins.com" = {
  #   # listen = [{ addr = "0.0.0.0"; port=8888; } { addr = "[::]"; port=8888; } { addr = "[::]"; port=8443; ssl=true; }  { addr = "0.0.0.0"; port=8443; ssl=true; } ];
  #   forceSSL = true;
  #   # addSSL = true;
  #   enableACME = true;
  #   # sslCertificateKey = "/var/lib/acme/mail.lesgrandsvoisins.com/key.pem";
  #   # sslCertificate = "/var/lib/acme/mail.lesgrandsvoisins.com/fullchain.pem";
  #   locations."/SOGo/" = {
  #     proxyPass = "https://mail.lesgrandsvoisins.com:8443";
  #   };
  #   locations."/" = {
  #     proxyPass = "https://mail.lesgrandsvoisins.com:8443";
  #   };
  #   # locations."/".extraConfig = ''
  #   #     # proxy_pass http://authentik;
  #   #     proxy_http_version 1.1;
  #   #     proxy_set_header X-Forwarded-Proto $scheme;
  #   #     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  #   #     proxy_set_header Host $host;
  #   #     proxy_set_header Upgrade $http_upgrade;
  #   #     proxy_set_header Connection $connection_upgrade_keepalive;
  #   #     proxy_redirect unix:/run/phpfpm/roundcube.sock https://hetzner005.lesgrandsvoisins.com;
  #   #     chunked_transfer_encoding off;
  #   #   '';
  # };
  # services.httpd.enablePHP = true;
  # services.dovecot2 = {
  #   sslServerCert = "/var/lib/acme/mail.lesgrandsvoisins.com/fullchain.pem";
  #   sslServerKey = "/var/lib/acme/mail.lesgrandsvoisins.com/key.pem";
  #   extraConfig = ''
  #   auth_mechanisms = $auth_mechanisms oauthbearer xoauth2
  #   auth_policy_server_timeout_msecs = 5000
  #   ssl_ca = </etc/ssl/certs/ca-certificates.crt
  #   ssl_client_cert = </var/lib/acme/mail.lesgrandsvoisins.com/fullchain.pem
  #   ssl_client_key = </var/lib/acme/mail.lesgrandsvoisins.com/key.pem
  #   passdb {
  #     driver = oauth2
  #     mechanisms = oauthbearer xoauth2
  #     args = /usr/local/config/dovecot-oauth2.conf.ext
  #   }
  #   '';
  # };
  #     ssl_client_ca = </etc/ssl/certs/ca-certificates.crt
  # security.acme.certs."mail.lesgrandsvoisins.com".group = lib.mkForce "wwwrun";
  # users.users."web2ldap" = {
  #   isNormalUser = true;
  # };
}


