{ config, pkgs, lib, ... }:

let 
  bindPassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.bind));
  domainNameForEmail = import ./vars/domain-name-for-email.nix;
  ldapBaseDCDN = import ./vars/ldap-base-dc-dn.nix;
  domainName = import ./vars/domain-name-mail.nix;
in
{
  environment.systemPackages = with pkgs; [
    sogo
  ];
    services.memcached = {
    enable = true;
  };

  services.sogo = {
    enable = true;
    language = "fr-fr";
    timezone = "Europe/Paris";

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
      SOGoMailDomain = domainNameForEmail;
      SOGoLanguage = French;
      SOGoAppointmentSendEMailNotifications = YES;
      SOGoEnablePublicAccess = YES;
      SOGoSMTPAuthenticationType = PLAIN;
      SOGoIMAPAclConformsToIMAPExt = YES;
      SOGoTimeZone = "Europe/Paris";
      SOGoSentFolderName = Sent;
      SOGoTrashFolderName = Trash;
      SOGoDraftsFolderName = Drafts;
      SOGoVacationEnabled = YES;
      SOGoForwardEnabled = YES;
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
      SOGoSMTPServer = "smtps://${domainName}/";
      SOGoIMAPServer = "imap://${domainName}:143/?tls=YES";
      SOGoTrustProxyAuthentication = YES;
      SOGoUserSources = (
        {
          id = cn;
          type = ldap;
          CNFieldName = cn;
          IDFieldName = cn;
          UIDFieldName = cn;
          baseDN = "ou=users,${ldapBaseDCDN}";
          canAuthenticate = YES;
          displayName = "Voisins";
          hostname = "ldaps://${domainName}";
          isAddressBook = NO;
          MailFieldNames = ("mail");
          IMAPLoginFieldName = mail;
          bindAsCurrentUser = YES;
          mapping = {
            mozillasecondemail = ("carLicense");
            mozillaworkurl = ("labeldURI");
            givenName = ("givenName");
            sn = ("sn");
            cn = ("cn");
            uid = ("cn");
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
      SOGoSuperUsernames = ("sogo@resdigita.org", "chris@lesgrandsvoisins.com", "chris", "sogo", "tt", "tt@lesgrandsvoisins.com");
      '';
          #       bindDN = "cn=admin,${ldapBaseDCDN}";
          # bindPassword = "${bindPassword}";
            # SOGoMemcachedHost = "/var/run/memcached.sock";
      # SOGoMemcachedHost = "unix:///var/run/memcached/memcached.sock";
      # SOGoIMAPServer = "imaps://${domainName}/";

  # SOGoUserSources =
  #     (
  #       {
  #         type = sql;
  #         id = BaseVoisins;
  #         viewURL = "postgresql:///sogo/sogo_users";
  #         canAuthenticate = YES;
  #         isAddressBook = NO;
  #         userPasswordAlgorithm = md5;
  #       }
  #     );



          #### From SOGoUserSources = ( {  id = voisins;      
          # MailFieldNames = ("mail");
          # SOGoMemcachedHost = "unix:///run/memcached/memcached.sock";

  };
  users.groups.memcached.members = [ "sogo" ];
}