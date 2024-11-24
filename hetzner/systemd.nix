{ config, pkgs, lib, ... }:
let 
  mannchriRsaPublic = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAuBWybYSoR6wyd1EG5YnHPaMKE3RQufrK7ycej7avw3Ug8w8Ppx2BgRGNR6EamJUPnHEHfN7ZZCKbrAnuP3ar8mKD7wqB2MxVqhSWvElkwwurlijgKiegYcdDXP0JjypzC7M73Cus3sZT+LgiUp97d6p3fYYOIG7cx19TEKfNzr1zHPeTYPAt5a1Kkb663gCWEfSNuRjD2OKwueeNebbNN/OzFSZMzjT7wBbxLb33QnpW05nXlLhwpfmZ/CVDNCsjVD1+NXWWmQtpRCzETL6uOgirhbXYW8UyihsnvNX8acMSYTT9AA3jpJRrUEMum2VizCkKh7bz87x7gsdA4wF0/w== rsa-key-20220407";
  # newuserPW = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.bind));
  pwSftpgoPostgres =  (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.newuser));
in
{
  systemd.services = {
    linkding = {
      enable = true;
      description = "Bookmarking system Linkding on linkding.lesgrandsvoisins.com";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      # requires = [ "linkding.socket" ];
      serviceConfig = {
        WorkingDirectory = "/home/python/live/linkding/";
        ExecStart = ''/home/python/live/linkding/venv/bin/gunicorn --access-logfile /var/log/linkding/linkding-access.log --error-logfile /var/log/linkding/linkding-error.log --chdir /home/python/live/linkding/ --workers 12 --bind localhost:8901 siteroot.wsgi:application'';
        # ExecStart = ''/home/wagtail/venv/bin/gunicorn --env WAGTAIL_ENV='production' --access-logfile /var/log/wagtail/access.log --error-logfile /var/log/wagtail/error.log --chdir /home/wagtail/wagtail-lesgv --workers 12 --bind unix:/run/wagtail-sockets/wagtail.sock lesgv.wsgi:application'';
        Restart = "always";
        RestartSec = "10s";
        User = "python";
        Group = "users";
      };
      unitConfig = {
        StartLimitInterval = "1min";
      };
    };
    # sftpgo = {
    #   enable = true;
    #   wantedBy = ["default.target"];
    #   script = "${pkgs.sftpgo}/bin/sftpgo serve";
    #   description = "SFTPGo for drive features of Les Grands Voisins";
    #   environment = {
    #     SFTPGO_PLUGIN_AUTH_LDAP_PASSWORD=newuserPW;
    #     SFTPGO_PLUGIN_AUTH_LDAP_URL="ldaps://ldap.lesgrandsvoisins.com:14636";
    #     SFTPGO_PLUGIN_AUTH_STARTTLS="0";
    #     SFTPGO_PLUGIN_AUTH_LDAP_BASE_DN="ou=users,dc=lesgrandsvoisins,dc=com";
    #     SFTPGO_PLUGIN_AUTH_LDAP_BIND_DN="cn=admin,dc=lesgrandsvoisins,dc=com";
    #     SFTPGO_PLUGIN_AUTH_USERS_BASE_DIR="/var/www/dav/data";
    #     SFTPGO_PLUGIN_AUTH_LDAP_SEARCH_QUERY="(cn=%username%)";
    #     SFTPGO_PLUGINS__0__AUTO_MTLS="1";
    #     SFTPGO_PLUGINS__0__TYPE="auth";
    #     SFTPGO_PLUGINS__0__AUTH_OPTIONS__SCOPE="5";
    #     SFTPGO_PLUGINS__0__CMD="/run/current-system/sw/bin/sftpgo-plugin-auth";
    #     SFTPGO_PLUGINS__0__ARGS="serve";
    #     SFTPGO_HTTPD__BINDINGS__0__PORT="8088";
    #     SFTPGO_HTTPD__BINDINGS__0__ADDRESS="116.202.236.241";
    #     SFTPGO_HTTPD__BINDINGS__0__ENABLE_HTTPS="true";
    #     SFTPGO_HTTPD__BINDINGS__0__CERTIFICATE_FILE="/var/lib/acme/sftpgo.lesgrandsvoisins.com/fullchain.pem";
    #     SFTPGO_HTTPD__BINDINGS__0__CERTIFICATE_KEY_FILE="/var/lib/acme/sftpgo.lesgrandsvoisins.com/key.pem";
    #     SFTPGO_COMMON__PROXY_PROTOCOL="2";
    #     SFTPGO_HTTPD__BINDINGS__0__TEMPLATES_PATH=${pkgs.sftpgo}/share/sftpgo/templates;
    #     SFTPGO_HTTPD__BINDINGS__0__STATIC_FILES_PATH=${pkgs.sftpgo}/share/sftpgo/static;
    #     SFTPGO_DATA_PROVIDER__DRIVER="postgresql";
    #     SFTPGO_DATA_PROVIDER__NAME="sftpgo";
    #     SFTPGO_DATA_PROVIDER__USERNAME="sftpgo";
    #     SFTPGO_DATA_PROVIDER__PASSWORD=pwSftpgoPostgres;
    #     SFTPGO_DATA_PROVIDER__HOST="localhost";
    #     SFTPGO_DATA_PROVIDER__PORT="5432";
    #     SFTPGO_DATA_PROVIDER__USERS_BASE_DIR="/var/www/dav/data";
    #   };
    #   serviceConfig = {
    #     WorkingDirectory = "/home/sftpgo/sftpgo/nix/";
    #     User = "sftpgo";
    #     Group = "wwwrun";
    #   };
    # };
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