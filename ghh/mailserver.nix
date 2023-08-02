{ config, pkgs, lib, ... }:

let 
  bindPassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.bind));
  alicePassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.alice));
  bobPassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.bob));
  sogoPassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.sogo));
  domainName = "test.gvoisins.com";
in
{
  imports = [
    (builtins.fetchTarball {
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/ldap-support/nixos-mailserver-nixos-23.05.tar.gz";
      sha256 = "sha256:15v6b5z8gjspps5hyq16bffbwmq0rwfwmdhyz23frfcni3qkgzpc";
    })
    ./mailserver/sogo.nix
    ./mailserver/ldap.nix
    ./mailserver/httpd.nix
    ./mailserver/fail2ban.nix
  ];
  environment.systemPackages = with pkgs; [
    sogo
    postgresql
    openldap
    pwgen-secure
  ];
  ## Needed for the contaiiner system of vpsfree.cz
  systemd.enableUnifiedCgroupHierarchy = false;
  systemd.enableCgroupAccounting = false;
  users.users."web2ldap" = {
    isNormalUser = true;
  };
  services.memcached = {
    enable = true;
    # maxMemory = 256;
    # enableUnixSocket = true;
    # port = 11211;
    # listen = "[::1]";
    # user = "sogo";
  };

  # services.roundcube = {
  #   hostName = "mail.lesgrandsvoisins.com";
  #   enable = true;
  #   dicts = with pkgs.aspellDicts; [ en fr de ];
  # }

# SOGoMemcachedHost = "/var/run/memcached.sock";
###################################################################################################################################
  mailserver = {
    enable = true;
    fqdn = domainName;

    # Use Let's Encrypt certificates. Note that this needs to set up a stripped
    # down nginx and opens port 80.
    #certificateScheme = "acme-nginx";
    # certificateDomains = (domainName "gvoisin.com" );
    certificateFile = "/var/certs/cert-${domainName}.pem";
    certificateScheme = "acme";
    certificateDirectory = "/var/certs/";
    keyFile = "/var/certs/key-${domainName}.pem";
    ldap = {
      enable = true;
      bind = {
        dn = "cn=admin,dc=resdigita,dc=org";
        passwordFile = "/etc/nixos/.secrets.bind";
      };
      dovecot = {
#        passAttrs = ''
#        userPassword=password
#        mail=mail
#        '';
        userFilter = "uid=$u";
        passFilter = "uid=$u";
      };
      uris = [
        "ldap:///"
      ];
      searchBase = "ou=users,dc=resdigita,dc=org";
      searchScope = "sub";
      startTls = true;
      tlsCAFile = "/var/lib/acme/${domainName}/full.pem";
      postfix = {
        mailAttribute = "mail";
        uidAttribute = "uid";
        # filter = "uid=%n";
      };
     
#      dovecot = {
#         userFilter = "uid=%n";
#         passFilter = "uid=%n";
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
#  domainName
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
    DefaultTimeoutStartSec=600s
  '';

}