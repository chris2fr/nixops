{ config, pkgs, lib, ... }:

let 
  # bindPassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.bind));
  alicePassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.alice));
  bobPassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.bob));
  sogoPassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.sogo));
  domainName = import ./vars/domain-name-mail.nix;
  ldapBaseDCDN = import ./vars/ldap-base-dc-dn.nix;
in
{
  services.openldap = {
    enable = true;
    urlList = [ "ldap:/// ldaps:///" ];
    settings = {
      attrs = {
        # olcTLSReqCert = "allow" ;
        # TLS_CACERTDIR /home/myuser/cacertss
        # LDAPTLS_CACERT /home/myuser/cacertss
        olcLogLevel = "conns config";
        /* settings for acme ssl */
        olcTLSCACertificateFile = "/var/lib/acme/${domainName}/full.pem";
        olcTLSCertificateFile = "/var/lib/acme/${domainName}/full.pem";
        # olcTLSCertificateFile = "/var/lib/acme/${domainName}/cert.pem";
        olcTLSCertificateKeyFile = "/var/lib/acme/${domainName}/key.pem";
        olcTLSCipherSuite = "HIGH:MEDIUM:+3DES:+RC4:+aNULL";
        olcTLSCRLCheck = "none";
        olcTLSVerifyClient = "never";
        olcTLSProtocolMin = "3.1";
        olcThreads = "16";
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
          olcDbIndex = [
            "displayName,description eq,sub"
            "uid,ou,c eq"
            "carLicense,labeledURI,telephoneNumber,mobile,homePhone,title,street,l,st,postalCode eq"
            "objectClass,cn,sn,givenName,mail eq"
          ];
          olcDatabase = "{1}mdb";
          olcDbDirectory = "/var/lib/openldap/data";
          olcSuffix = "${ldapBaseDCDN}";
          /* your admin account, do not use writeText on a production system */
          olcRootDN = "cn=admin,${ldapBaseDCDN}";
          olcRootPW = (builtins.readFile /etc/nixos/.secrets.bind);
          olcAccess = [
            /* custom access rules for userPassword attributes */
            /* allow read on anything else */
            ''{0}to dn.subtree="ou=newusers,${ldapBaseDCDN}"
                by dn.exact="cn=newuser@lesgv.com,ou=users,${ldapBaseDCDN}" write
                by group.exact="cn=administration,ou=groups,${ldapBaseDCDN}" write
                by self write
                by anonymous auth
                by * read''
            ''{1}to dn.subtree="ou=invitations,${ldapBaseDCDN}"
                by dn.exact="cn=newuser@lesgv.com,ou=users,${ldapBaseDCDN}" write
                by group.exact="cn=administration,ou=groups,${ldapBaseDCDN}" write
                by self write
                by anonymous auth
                by * read''
            ''{2}to dn.subtree="ou=users,${ldapBaseDCDN}"
                by dn.exact="cn=newuser@lesgv.com,ou=users,${ldapBaseDCDN}" write
                by group.exact="cn=administration,ou=groups,${ldapBaseDCDN}" write
                by self write
                by anonymous auth
                by * read''
            ''{3}to attrs=userPassword
                by self write
                by anonymous auth
                by * none''
            ''{4}to *
                by dn.exact="cn=sogo@resdigita.org,ou=users,${ldapBaseDCDN}" manage
                by dn.exact="cn=chris@lesgrandsvoisins.com,ou=users,${ldapBaseDCDN}" manage
                by dn.exact="cn=chris@mann.fr,ou=users,${ldapBaseDCDN}" manage
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
  };
#  /* ensure openldap is launched after certificates are created */
#  systemd.services.openldap = {
#    wants = [ "acme-${domainName}.service" ];
#    after = [ "acme-${domainName}.service" ];
#  };
#  /* make acme certificates accessible by openldap */
#  security.acme.defaults.group = "certs";
#  users.groups.certs.members = [ "openldap" ];
#  /* trigger the actual certificate generation for your hostname */
#  security.acme.certs."${domainName}" = {
#    extraDomainNames = [];
#  };
#############################
  systemd.services.openldap = {
    wants = [ "acme-${domainName}.service" ];
    after = [ "acme-${domainName}.service" ];
    serviceConfig = {
      RemainAfterExit = false;
    };
  };
  users.groups.wwwrun.members = [ "openldap" ];
}