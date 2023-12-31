{ config, pkgs, lib, ... }:

let 
  bindPassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.bind));
  alicePassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.alice));
  bobPassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.bob));
  sogoPassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.sogo));
  domainName = "test.gvoisins.com";
in
{
    services.openldap = {
    enable = true;
    # urlList = [ "ldap:///" ];
    urlList = [ "ldap:/// ldaps:///" ];
    settings = {
      attrs = {
        olcLogLevel = "conns config";
         /* settings for acme ssl */
          olcTLSCACertificateFile = "/var/lib/acme/${domainName}/full.pem";
          olcTLSCertificateFile = "/var/lib/acme/${domainName}/cert.pem";
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
            "objectClass,cn,sn,givenname,mail eq"
          ];



          olcDatabase = "{1}mdb";
          olcDbDirectory = "/var/lib/openldap/data";
          olcSuffix = "dc=resdigita,dc=org";

          /* your admin account, do not use writeText on a production system */
          olcRootDN = "cn=admin,dc=resdigita,dc=org";
          olcRootPW = (builtins.readFile /etc/nixos/.secrets.bind);

          olcAccess = [
            /* custom access rules for userPassword attributes */
            /* allow read on anything else */
            ''{0}to dn.subtree="ou=newusers,dc=resdigita,dc=org"
                by dn.exact="cn=newuser,ou=users,dc=resdigita,dc=org" write
                by group.exact="cn=administration,ou=groups,dc=resdigita,dc=org" write
                by self write
                by anonymous auth
                by * read''
            ''{1}to dn.subtree="ou=invitations,dc=resdigita,dc=org"
                by dn.exact="cn=newuser,ou=users,dc=resdigita,dc=org" write
                by group.exact="cn=administration,ou=groups,dc=resdigita,dc=org" write
                by self write
                by anonymous auth
                by * read''
            ''{2}to dn.subtree="ou=users,dc=resdigita,dc=org"
                by dn.exact="cn=newuser,ou=users,dc=resdigita,dc=org" write
                by group.exact="cn=administration,ou=groups,dc=resdigita,dc=org" write
                by self write
                by anonymous auth
                by * read''
            ''{3}to attrs=userPassword
                by self write
                by anonymous auth
                by * none''
            ''{4}to *
                by dn.exact="cn=sogo@${domainName},ou=users,dc=resdigita,dc=org" manage
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



          # olcDbIndex = [
          #   "objectClass eq"
          #   "cn eq"
          #   "mail eq,subany"
          #   "uid eq"
          #   "carLicense eq"
          # ];
       


#             "member pres,eq"


    declarativeContents."dc=resdigita,dc=org" = ''
          dn: dc=resdigita,dc=org
          objectClass: domain
          dc: resdigita

          dn: ou=users,dc=resdigita,dc=org
          objectClass: organizationalUnit
          ou: users

          dn: ou=mailings,dc=resdigita,dc=org
          objectClass: organizationalUnit
          ou: mailings

          dn: ou=groups,dc=resdigita,dc=org
          objectClass: organizationalUnit
          ou: groups

          dn: ou=invitations,dc=resdigita,dc=org
          objectClass: organizationalUnit
          ou: invitations

          dn: cn=alice,ou=users,dc=resdigita,dc=org
          objectClass: inetOrgPerson
          cn: alice@${domainName}
          givenName: alice
          displayName: Alice
          sn: Foo
          mail: alice@${domainName}
          userPassword: ${alicePassword}

          dn: cn=bob,ou=users,dc=resdigita,dc=org
          objectClass: inetOrgPerson
          cn: bob
          givenName: bob
          sn: Bar
          mail: bob@${domainName}
          userPassword: ${bobPassword}

          dn: cn=sogo,ou=users,dc=resdigita,dc=org
          objectClass: inetOrgPerson
          cn: sogo
          givenName: sogo
          sn: Administrator
          mail: sogo@${domainName}
          userPassword: ${sogoPassword}
        '';
  };
#  /* ensure openldap is launched after certificates are created */
#  systemd.services.openldap = {
#    wants = [ "acme-mailtest.${domainName}.service" ];
#    after = [ "acme-mailtest.${domainName}.service" ];
#  };
#  /* make acme certificates accessible by openldap */
#  security.acme.defaults.group = "certs";
#  users.groups.certs.members = [ "openldap" ];
#  /* trigger the actual certificate generation for your hostname */
#  security.acme.certs."mailtest.${domainName}" = {
#    extraDomainNames = [];
#  };
#############################
  systemd.services.openldap = {
    wants = [ "acme-${domainName}.service" ];
    after = [ "acme-${domainName}.service" ];
  };
  users.groups.wwwrun.members = [ "openldap" ];
}