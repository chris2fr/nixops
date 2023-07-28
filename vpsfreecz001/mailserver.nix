{ config, pkgs, lib, ... }:

let 
  bindPassword = (lib.removeSuffix "\n" (builtins.readFile ../.secrets.adminresdigitaorg));
  alicePassword = (lib.removeSuffix "\n" (builtins.readFile ../.secrets.mailserver.alice));
  bobPassword = (lib.removeSuffix "\n" (builtins.readFile ../.secrets.mailserver.bob));
  sogoPassword = (lib.removeSuffix "\n" (builtins.readFile ../.secrets.mailserver.sogo));
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
  services.memcached = {
    enable = true;
    maxMemory = 256;
    enableUnixSocket = true;
    user = "sogo";
  };

  # services.roundcube = {
  #   hostName = "mail.lesgrandsvoisins.com";
  #   enable = true;
  #   dicts = with pkgs.aspellDicts; [ en fr de ];

  # }




################################################################################################################
################################################################################################################
###################################################################################################################################
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