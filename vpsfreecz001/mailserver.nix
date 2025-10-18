{ config, pkgs, lib, ... }:

let 
  bindPassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.bind));
  alicePassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.alice));
  bobPassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.bob));
  sogoPassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.sogo));
  domainName = import mailserver/vars/domain-name-mx.nix;
  ldapBaseDCDN = import /etc/nixos/mailserver/vars/ldap-base-dc-dn.nix;
  mailServerDomainAliases = [ 
    "gvois.in"
    "mail.gvois.in"
    "lesgrandsvoisins.com"
    "mail.resdigita.com"
    "resdigita.org"
    "resdigita.com"
    "lesgv.com"
    "lesgv.org"
    "gvoisin.com"
    "gvoisin.org"
    "lesgrandsvoisins.fr"
    ];
in
{
  imports = [
    (builtins.fetchTarball {
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/nixos-25.05/nixos-mailserver-nixos-25.05.tar.gz";
      sha256 = "sha256:1qn5fg0h62r82q7xw54ib9wcpflakix2db2mahbicx540562la1y";
    })
    ./mailserver/sogo.nix
    ./mailserver/ldap.nix
    ./mailserver/httpd.nix
    ./mailserver/fail2ban.nix
  ];
  environment.systemPackages = with pkgs; [
    sogo
    # postgresql
    openldap
    pwgen
  ];
  ## Needed for the contaiiner system of vpsfree.cz
  # systemd.enableUnifiedCgroupHierarchy = false;
  systemd.enableCgroupAccounting = false;
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
    #  TODO - REFAIRE
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
    ];
    settings = {
      max_connections = 150;
      shared_buffers = "60MB";
    };
    ensureUsers = [
      {
        name = "sogo";
        # ensurePermissions = {
        #   "DATABASE \"sogo\"" = "ALL PRIVILEGES";
        # };
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