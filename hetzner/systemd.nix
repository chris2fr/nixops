{ config, pkgs, lib, ... }:
let 
  mannchriRsaPublic = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAuBWybYSoR6wyd1EG5YnHPaMKE3RQufrK7ycej7avw3Ug8w8Ppx2BgRGNR6EamJUPnHEHfN7ZZCKbrAnuP3ar8mKD7wqB2MxVqhSWvElkwwurlijgKiegYcdDXP0JjypzC7M73Cus3sZT+LgiUp97d6p3fYYOIG7cx19TEKfNzr1zHPeTYPAt5a1Kkb663gCWEfSNuRjD2OKwueeNebbNN/OzFSZMzjT7wBbxLb33QnpW05nXlLhwpfmZ/CVDNCsjVD1+NXWWmQtpRCzETL6uOgirhbXYW8UyihsnvNX8acMSYTT9AA3jpJRrUEMum2VizCkKh7bz87x7gsdA4wF0/w== rsa-key-20220407";
  newuserPW = import "/etc/nixos/.secrets.newuser"
in
{
  systemd.services = {
    sftpgo = {
      enable = true;
      wantedBy = ["default.target"];
      script = "${pkgs.sftpgo}/bin/sftpgo serve --config-file sftpgo.json";
      description = "SFTPGo for drive features of Les Grands Voisins";
      environment = {
        NOT_SFTPGO_PLUGIN_AUTH_CONFIG_FILE="/home/sftpgo/sftpgo/nix/sftpgo-plugin-auth.json";
        SFTPGO_PLUGIN_AUTH_LDAP_PASSWORD = newuserPW;
        SFTPGO_PLUGIN_AUTH_LDAP_URL="ldaps://ldap.lesgrandsvoisins.com:14636";
        SFTPGO_PLUGIN_AUTH_STARTTLS="0";
        SFTPGO_PLUGIN_AUTH_LDAP_BASE_DN="dc=lesgrandsvoisins,dc=com";
        SFTPGO_PLUGIN_AUTH_LDAP_BIND_DN="cn=newuser,ou=users,dc=lesgrandsvoisins,dc=com";
        SFTPGO_PLUGIN_AUTH_USERS_BASE_DIR="/var/www/dav/data";
        SFTPGO_PLUGIN_AUTH_LDAP_SEARCH_QUERY="(cn=%username%)";
        SFTPGO_PLUGINS__0__AUTO_MTLS="1";
        SFTPGO_PLUGINS__0__TYPE="auth";
        SFTPGO_PLUGINS__0__AUTH_OPTIONS__SCOPE="5";
        SFTPGO_PLUGINS__0__CMD="/usr/local/bin/sftpgo-plugin-auth";
        SFTPGO_PLUGINS__0__ARGS="serve";
      };
      serviceConfig = {
        WorkingDirectory = "/home/sftpgo/sftpgo/nix/";
        User = "sftpgo";
        Group = "users";
      };
    };
    "filebrowser@" = {
      enable = true;
      wantedBy = ["default.target"];
      scriptArgs = "filebrowser %i";
      # preStart = "mkdir -p /opt/filebrowser/dbs/%u/%i; touch /opt/filebrowser/dbs/%u/%i/temoin.txt";
      script = "/opt/filebrowser/dbs/filebrowser.sh $filebrowser_user $filebrowser_database";
      description = "File Browser, un interface web à un système de fichiers pour %u on %i";
      environment = {
        filebrowser_user = "filebrowser";
        filebrowser_database = "%i";
        FB_BASEURL="";
      };
      serviceConfig = {
        WorkingDirectory = "/var/www/dav/data/%i";
        User = "filebrowser";
        Group = "wwwrun";
        UMask = "0002";
      };
    };
    crabfitfront = {
      enable = true;
      wantedBy = ["default.target"];
      script = "${pkgs.yarn}/bin/yarn run start -p 3080";
      description = "Crab.fit front-end NextJS";
      serviceConfig = {
        WorkingDirectory = "/home/crabfit/crab.fit/frontend/";
        User = "crabfit";
        Group = "users";
      };
    };
    crabfitback = {
      enable = true;
      wantedBy = ["default.target"];
      script = "/home/crabfit/crab.fit/api/launch-crabfit-api.sh";
      description = "Crab.fit back in Rust avec Postgres";
      serviceConfig = {
        WorkingDirectory = "/home/crabfit/crab.fit/api/target/release/";
        User = "crabfit";
        Group = "users";
      };
    };
    # haproxy-config = {
    #   enable = true;
    #   description = "HA Proxy Service";
    #   documentation = "https://www.resdigita.com";
    #   wantedBy = [ "multi-user.target" ];
    #   requires = [ "network-online.target" ];
    #   after = [ "network-online.target" "nginx.service"  "httpd.service" ];
    #   path = [
    #     pkgs.coreutils
    #     pkgs.cacert
    #   ];
    # };
  };
}