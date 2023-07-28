{ config, pkgs, lib, ... }:

let 
  bindPassword = (lib.removeSuffix "\n" (builtins.readFile ../.secrets.adminresdigitaorg));
  alicePassword = (lib.removeSuffix "\n" (builtins.readFile ../.secrets.mailserver.alice));
  bobPassword = (lib.removeSuffix "\n" (builtins.readFile ../.secrets.mailserver.bob));
  sogoPassword = (lib.removeSuffix "\n" (builtins.readFile ../.secrets.mailserver.sogo));
in
{
    services.openldap = {
    enable = true;
    # urlList = [ "ldap:///" ];
    urlList = [ "ldap:///" "ldaps:///" ];
    settings = {
      attrs.threads = 16;
      attrs = {
        olcLogLevel = "conns config";
         /* settings for acme ssl */
          olcTLSCACertificateFile = "/var/lib/acme/mail.resdigita.com/full.pem";
          olcTLSCertificateFile = "/var/lib/acme/mail.resdigita.com/cert.pem";
          olcTLSCertificateKeyFile = "/var/lib/acme/mail.resdigita.com/key.pem";
        olcTLSCipherSuite = "HIGH:MEDIUM:+3DES:+RC4:+aNULL";
        olcTLSCRLCheck = "none";
        olcTLSVerifyClient = "never";
        olcTLSProtocolMin = "3.1";
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

          olcDatabase = "{1}mdb";
          olcDbDirectory = "/var/lib/openldap/data";

          olcSuffix = "dc=resdigita,dc=org";
          index = "cn,sn,givenname,mail eq";

          /* your admin account, do not use writeText on a production system */
          olcRootDN = "cn=admin,dc=resdigita,dc=org";
          olcRootPW = (builtins.readFile /etc/nixos/.secrets.adminresdigitaorg);

          olcAccess = [
            /* custom access rules for userPassword attributes */
            /* allow read on anything else */
            ''{0}to dn.subtree="ou=newusers,dc=resdigita,dc=org"
                by dn.exact="cn=newuser@lesgv.com,ou=users,dc=resdigita,dc=org" write
                by group.exact="cn=administration,ou=groups,dc=resdigita,dc=org" write
                by self write
                by anonymous auth
                by * read''
            ''{1}to dn.subtree="ou=invitations,dc=resdigita,dc=org"
                by dn.exact="cn=newuser@lesgv.com,ou=users,dc=resdigita,dc=org" write
                by group.exact="cn=administration,ou=groups,dc=resdigita,dc=org" write
                by self write
                by anonymous auth
                by * read''
            ''{2}to dn.subtree="ou=users,dc=resdigita,dc=org"
                by dn.exact="cn=newuser@lesgv.com,ou=users,dc=resdigita,dc=org" write
                by group.exact="cn=administration,ou=groups,dc=resdigita,dc=org" write
                by self write
                by anonymous auth
                by * read''
            ''{3}to attrs=userPassword
                by self write
                by anonymous auth
                by * none''
            ''{4}to *
                by dn.exact="cn=sogo@resdigita.org,ou=users,dc=resdigita,dc=org" manage
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
#    declarativeContents."dc=resdigita,dc=org" = ''
#          dn: dc=resdigita,dc=org
#          objectClass: domain
#          dc: resdigita
#
#          dn: ou=users,dc=resdigita,dc=org
#          objectClass: organizationalUnit
#          ou: users
#
#          dn: ou=mailings,dc=resdigita,dc=org
#          objectClass: organizationalUnit
#          ou: mailings
#
#          dn: ou=groups,dc=resdigita,dc=org
#          objectClass: organizationalUnit
#          ou: groups
#
#          dn: ou=invitations,dc=resdigita,dc=org
#          objectClass: organizationalUnit
#          ou: invitations
#
#          dn: cn=alice@resdigita.org,ou=users,dc=resdigita,dc=org
#          objectClass: inetOrgPerson
#          cn: alice@resdigita.org
#          givenName: alice
#          sn: Foo
#          uid: alice
#          mail: alice@resdigita.org
#          userPassword: ${alicePassword}
#
#          dn: cn=bob@resdigita.org,ou=users,dc=resdigita,dc=org
#          objectClass: inetOrgPerson
#          cn: bob@resdigita.org
#          uid: bob
#          givenName: bob
#          sn: Bar
#          mail: bob@resdigita.org
#          userPassword: ${bobPassword}
#
#          dn: cn=sogo@resdigita.org,ou=users,dc=resdigita,dc=org
#          objectClass: inetOrgPerson
#          cn: sogo@resdigita.org
#          givenName: sogo
#          uid: sogo
#          sn: Administrator
#          mail: sogo@resdigita.org
#          userPassword: ${sogoPassword}
#
#        '';
  };
#  /* ensure openldap is launched after certificates are created */
#  systemd.services.openldap = {
#    wants = [ "acme-mailtest.resdigita.org.service" ];
#    after = [ "acme-mailtest.resdigita.org.service" ];
#  };
#  /* make acme certificates accessible by openldap */
#  security.acme.defaults.group = "certs";
#  users.groups.certs.members = [ "openldap" ];
#  /* trigger the actual certificate generation for your hostname */
#  security.acme.certs."mailtest.resdigita.org" = {
#    extraDomainNames = [];
#  };
#############################
  systemd.services.openldap = {
    wants = [ "acme-mail.resdigita.com.service" ];
    after = [ "acme-mail.resdigita.com.service" ];
  };
  users.groups.wwwrun.members = [ "openldap" ];
}