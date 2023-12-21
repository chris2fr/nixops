{ config, pkgs, lib, ... }:
let 
  bindPassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.bind));
  alicePassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.alice));
  bobPassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.bob));
  sogoPassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.sogo));
  domainName = import ./vars/domain-name-mail.nix;
  ldapBaseDCDN = import ./vars/ldap-base-dc-dn.nix;
in
{
  services.openldap.declarativeContents."dc=resdigita,dc=org" = ''
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
          cn: alice
          givenName: alice
          uid=alice@resdigita.org
          sn: Foo
          uid: alice
          mail: alice@resdigita.org
          userPassword: ${alicePassword}

          dn: cn=bob@resdigita.org,ou=users,dc=resdigita,dc=org
          objectClass: inetOrgPerson
          cn: bob@resdigita.org
          uid: bob
          givenName: bob
          sn: Bar
          mail: bob@resdigita.org
          userPassword: ${bobPassword}

          dn: cn=sogo@resdigita.org,ou=users,dc=resdigita,dc=org
          objectClass: inetOrgPerson
          cn: sogo@resdigita.org
          givenName: sogo
          uid: sogo
          sn: Administrator
          mail: sogo@resdigita.org
          userPassword: ${sogoPassword}
        '';
}