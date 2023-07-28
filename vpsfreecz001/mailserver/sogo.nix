{ config, pkgs, lib, ... }:

let 
  bindPassword = (lib.removeSuffix "\n" (builtins.readFile ./.secrets.adminresdigitaorg));
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
          id = voisins;
          type = ldap;
          CNFieldName = displayName;
          IDFieldName = cn;
          UIDFieldName = cn;
          baseDN = "ou=users,dc=resdigita,dc=org";
          bindDN = "cn=admin,dc=resdigita,dc=org";
          bindPassword = "${bindPassword}";
          canAuthenticate = YES;
          displayName = "Voisins";
          hostname = "mail.resdigita.com";
          isAddressBook = NO;
          MailFieldNames = ("mail");
          IMAPLoginFieldName = mail;
          # mapping = {
          #   mozillasecondemail = ("carLicense");
          #   mozillaworkurl = ("labeldURI");
          #   givenName = ("givenName");
          #   sn = ("sn");
          #   displayName = ("displayName");
          #   mail = ("mail");
          #   telephoneNumber = ("telephoneNumber");
          #   mobile = ("mobile");
          #   homephone = ("homephone");
          #   title = ("title");
          #   ou = ("ou");
          #   o = ("o");
          #   street = ("street");
          #   l = ("l");
          #   st = ("st");
          #   postalCode = ("postalCode");
          #   c = ("c");
          #   description = ("description");
          #   photo = ("photo");
          # }
        }
      );
      SOGoSuperUsernames = ("sogo@resdigita.org", "chris@lesgrandsvoisins.com", "chris");
      '';
      SOGoMemcachedHost = "unix:///run/memcached/memcached.sock";
                    # MailFieldNames = ("mail");
  };
}