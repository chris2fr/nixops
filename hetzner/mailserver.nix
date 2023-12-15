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
    "mail.lesgrandsvoisins.com"

  ];









in
{
  imports = [
    (builtins.fetchTarball {
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/ldap-support/nixos-mailserver-nixos-23.11.tar.gz";
      sha256 = "sha256:15v6b5z8gjspps5hyq16bffbwmq0rwfwmdhyz23frfcni3qkgzpc";
    })
    ./mailserver/sogo.nix
    ./mailserver/ldap.nix
    ./mailserver/httpd.nix
    ./mailserver/fail2ban.nix
  ];
  environment.systemPackages = with pkgs; [
    sogo
    postgresql_14
    openldap
    pwgen
  ];

  # users.users."web2ldap" = {
  #   isNormalUser = true;
  # };

  
  services.memcached = {
    enable = true;
    # maxMemory = 256;
    # enableUnixSocket = true;
    # port = 11211;
    # listen = "[::1]";
    # user = "sogo";
  };

  # services.roundcube = {
  #   hostName = "${domainName}";
  #   enable = true;
  #   dicts = with pkgs.aspellDicts; [ en fr de ];
  # }

# SOGoMemcachedHost = "/var/run/memcached.sock";
###################################################################################################################################
  mailserver = {
    enable = true;
    fqdn = domainName;
    domains = mailServerDomainAliases;

    # Use Let's Encrypt certificates. Note that this needs to set up a stripped
    # down nginx and opens port 80.
    # certificateScheme = "acme-nginx";
    # certificateDomains = ("mail.resdigita.com" "gvoisin.com" );
    # certificateFile = "/var/certs/cert-mail.resdigita.com.pem";
    # certificateScheme = "acme";
    # certificateDirectory = "/var/certs/";
    # keyFile = "/var/certs/key-mail.resdigita.com.pem";
    certificateScheme = "acme";
    certificateFile = "/var/lib/acme/${domainName}/cert.pem";
    certificateDirectory = "/var/lib/acme/${domainName}/";
    keyFile =  "/var/lib/acme/${domainName}/key.pem";    
    ldap = {
      enable = true;
      bind = {
        dn = "cn=admin,${ldapBaseDCDN}";
        passwordFile = "/etc/nixos/.secrets.bind";
      };
      uris = [
        "ldap:///"
      ];
      searchBase = "ou=users,${ldapBaseDCDN}";
      searchScope = "sub";
      tlsCAFile = "/var/lib/acme/${domainName}/cert.pem";
      postfix = {
        mailAttribute = "mail";
        uidAttribute = "cn";
      #  filter = "(cn=%s)";
      };
      startTls = false;
#      dovecot = {
#         userFilter = "(cn=%s)";
#         passFilter = "(cn=%s)";
#      };
    };
    # ldap.postfix.filter = "(&(objectClass=inetOrgPerson)(cn=%u))";
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
      enable = true;
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
    # # ensureDBOwnership = true;
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
    DefaultTimeoutStartSec=600s
  '';

  services.roundcube = {
     enable = true;

     # this is the url of the vhost, not necessarily the same as the fqdn of
     # the mailserver
     hostName = "hetzner005.lesgrandsvoisins.com";

     extraConfig = ''
        # starttls needed for authentication, so the fqdn required to match
        # the certificate
        $config['smtp_server'] = "tls://${config.mailserver.fqdn}";
        $config['smtp_user'] = "%u";
        $config['smtp_pass'] = "%p";
        $config['oauth_provider'] = 'generic';
        $config['oauth_provider_name'] = 'authentik';
        $config['oauth_client_id'] = 'q3nTVQdV2ctY8GeNKvPuHokNa5RxT0VhZbVFCyY3';
        $config['oauth_client_secret'] = '${oauthPassword}';
        $config['oauth_auth_uri'] = 'https://auth.lesgrandsvoisins.com/application/o/authorize/';
        $config['oauth_token_uri'] = 'https://auth.lesgrandsvoisins.com/application/o/token/';
        $config['oauth_identity_uri'] = 'https://auth.lesgrandsvoisins.com/application/o/userinfo/';
        $config['oauth_scope'] = "openid dovecotprofile";
        $config['oauth_auth_parameters'] = [];
        $config['oauth_identity_fields'] = ['email'];
     '';
  };
  services.nginx.virtualHosts."hetzner005.lesgrandsvoisins.com" = {
    forceSSL = false;
    enableACME = false;
    locations."/".extraConfig = ''
        # proxy_pass http://authentik;
        proxy_http_version 1.1;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade_keepalive;
        proxy_redirect unix:/run/phpfpm/roundcube.sock https://hetzner005.lesgrandsvoisins.com;
        chunked_transfer_encoding off;
      '';
  };

  # services.httpd.enablePHP = true;

  services.phpfpm.pools."roundcubedesgv" = {
    user = "roundcube";
    settings = {
      "listen.owner" = config.services.httpd.user;
      "pm" = "dynamic";
      "pm.max_children" = 32;
      "pm.max_requests" = 500;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 2;
      "pm.max_spare_servers" = 5;
      "php_admin_value[error_log]" = "stderr";
      "php_admin_flag[log_errors]" = true;
      "catch_workers_output" = true;
      "session_samesite" = "Lax";
      "support_url" = "https://auth.lesgrandsvoisins.com";
    };
     phpEnv."PATH" = lib.makeBinPath [ pkgs.php ];
  };

  services.httpd.virtualHosts."hetzner005.lesgrandsvoisins.com" = {
    enableACME = true;
    forceSSL = true;
    extraConfig = ''
        # ProxyPreserveHost On
        # ProxyVia On
        # ProxyAddHeaders On
        # RequestHeader set X-Original-URL "expr=%{THE_REQUEST}"
        # RequestHeader edit* X-Original-URL ^[A-Z]+\s|\sHTTP/1\.\d$ ""
        # RequestHeader set X-Forwarded-Proto "https"
        # RequestHeader set X-Forwarded-Port "443"
        DirectoryIndex /index.php index.php
        <Directory />
            Options FollowSymLinks
            AllowOverride None
        </Directory>
        <Directory ${pkgs.roundcube}>
            Options -Indexes +FollowSymLinks +MultiViews
            AllowOverride None
            Order allow,deny
            allow from all
            DirectoryIndex /index.php index.php
        </Directory>
        CacheDisable /
        DocumentRoot ${pkgs.roundcube}
        ProxyPassMatch ^/(.*\.php(/.*)?)$  unix:/run/phpfpm/roundcubedesgv.sock|fcgi://hetzner005.lesgrandsvoisins.com${pkgs.roundcube}
      '';
  };

  services.dovecot2.extraConfig = ''
    auth_mechanisms = $auth_mechanisms oauthbearer xoauth2

    passdb {
      driver = oauth2
      mechanisms = xoauth2 oauthbearer
      args = /usr/local/config/dovecot-oauth2.conf.ext
    }
    '';

}