#
# Configures Fail2Ban on the mailserver
#
{ config, pkgs, lib, ... }:
let 
  domainName = import /etc/nixos/mailserver/vars/domain-name-mail.nix;
  # Whitelisting some subnets:
  whitelistSubnets =  [ 
      "10.0.0.0/8" 
      "172.16.0.0/12" 
      "192.168.0.0/16"
      "8.8.8.8" # Resolves the IP via DNS
      domainName 
      ];
  
in
{
  services.fail2ban = {
    enable = true;
    maxretry = 5; # Observe 5 violations before banning an IP
    ignoreIP = whitelistSubnets;
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
}