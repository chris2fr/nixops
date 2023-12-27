{ config, pkgs, lib, ... }:
let
  # seafilePassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.seafile));
  my-python-packages = ps: with ps; [
    bleach
    cffi
    chardet
    django
    django-formtools
    django-picklefield
    django-simple-captcha
    django-statici18n
    django-webpack-loader
    djangorestframework
    future
    gunicorn
    markdown
    mysqlclient
    mysqlclient
    openpyxl
    pillow
    pip
    pycryptodome
    pyjwt
    pysaml2
    python-dateutil
    python-ldap
    qrcode
    requests
    requests-oauthlib
    setuptools
    simplejson
    python3-gnutls
  ];
in
{
  networking.nat = {
    enable = true;
    internalInterfaces = ["ve-+"];
    externalInterface = "eno1";
    # Lazy IPv6 connectivity for the container
    enableIPv6 = true;
  };
  containers.seafile = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.101.10";
    localAddress = "192.168.101.11";
    hostAddress6 = "fd00::1";
    localAddress6 = "fd00::2";
    config = { config, pkgs, lib, ...  }: {
      environment.systemPackages = with pkgs; [
        ((vim_configurable.override {  }).customize{
          name = "vim";
          vimrcConfig.customRC = ''
            " your custom vimrc
            set mouse=a
            set nocompatible
            colo torte
            syntax on
            set tabstop     =2
            set softtabstop =2
            set shiftwidth  =2
            set expandtab
            set autoindent
            set smartindent
            " ...
          '';
          }
        )
        (python311.withPackages my-python-packages)
        # python311Packages.bleach 
        # python311Packages.captcha 
        # python311Packages.cffi 
        # python311Packages.chardet 
        # python311Packages.devtools
        # python311Packages.django
        # python311Packages.django_4
        # python311Packages.django-formtools
        # python311Packages.django-picklefield
        # python311Packages.django-simple-captcha
        # python311Packages.django-statici18n
        # python311Packages.django-webpack-loader
        # python311Packages.djangorestframework
        # python311Packages.future
        # python311Packages.gunicorn
        # python311Packages.ldap3
        # python311Packages.markdown 
        # python311Packages.mysqlclient
        # python311Packages.mysqlclient
        # python311Packages.openpyxl 
        # python311Packages.pillow 
        # python311Packages.pip
        # python311Packages.pycryptodome
        # python311Packages.pyjwt
        # python311Packages.pysaml2
        # python311Packages.python-dateutil
        # python311Packages.python-ldap
        # python311Packages.qrcode 
        # python311Packages.requests
        # python311Packages.requests-oauthlib
        #python311
        #python311Full
        autoconf
        automake 
        busybox
        ceph-client
        cmake
        curl
        cyrus_sasl
        docker
        docker-compose
        flex 
        fuse
        gcc
        git
        glib
        intltool
        jansson
        libarchive
        libevent
        libgcc
        libglibutil
        libmysqlclient
        libtool
        libuuid
        lynx
        mariadb
        mariadb-embedded
        openldap
        openssh
        openssl
        openssl
        re2c
        seafile-server
        sqlite
        stdenv
        util-linux
        vala
        vim
        wget
        libxml2
        netcat
        unzip
        libffi
        pcre
        libz
        xz
        nginx
        pkg-config
        poppler_utils
        libmemcached
        sudo
        libjwt
      ];
      virtualisation.docker.enable = true;
      system.stateVersion = "23.11";
      nix.settings.experimental-features = "nix-command flakes";
      networking = {
        firewall.enable = false;
        # firewall = {
        #   enable = true;
        #   allowedTCPPorts = [ 80 443 ];
        # };
        # Use systemd-resolved inside the container
        useHostResolvConf = lib.mkForce false;
      };
      users.users.seafile = {
        isNormalUser = true;
        extraGroups = ["docker"];
      };
      services = {
        resolved.enable = true;
        seafile = {
          enable = true;
          adminEmail = "chris@mann.fr";
          initialAdminPassword = "aes3xaiThe7Ungi0iDe0aehongideik";
          ccnetSettings.General.SERVICE_URL = "https://seafile.resdigita.com";
        };
        mysql = {
          enable = true;
          package = pkgs.mariadb;
        };
      };
    };
  };    

  # containers.filestash = {
  #   autoStart = true;
  #   privateNetwork = true;
  #   hostAddress = "192.168.101.10";
  #   localAddress = "192.168.101.11";
  #   hostAddress6 = "fd00::1";
  #   localAddress6 = "fd00::2";
  #   config = { config, pkgs, lib, ...  }: {
  #     environment.systemPackages = with pkgs; [
  #       ((vim_configurable.override {  }).customize{
  #         name = "vim";
  #         vimrcConfig.customRC = ''
  #           " your custom vimrc
  #           set mouse=a
  #           set nocompatible
  #           colo torte
  #           syntax on
  #           set tabstop     =2
  #           set softtabstop =2
  #           set shiftwidth  =2
  #           set expandtab
  #           set autoindent
  #           set smartindent
  #           " ...
  #         '';
  #         }
  #       )
  #       wget
  #       vim
  #       curl
  #       lynx
  #       docker-compose
  #       docker
  #       glib
  #       gotools
  #       libraw
  #       python311
  #       stdenv
  #       vips
  #       util-linux
  #     ];
  #     system.stateVersion = "23.11";
  #     nix.settings.experimental-features = "nix-command flakes";
  #     networking = {
  #       firewall = {
  #         enable = true;
  #         allowedTCPPorts = [ 80 443 8334 ];
  #       };
  #       # Use systemd-resolved inside the container
  #       useHostResolvConf = lib.mkForce false;
  #     };
  #     users.users.filestash = {
  #       isNormalUser = true;
  #       extraGroups = ["docker"];
  #     };
  #     services = {
  #       resolved.enable = true;
  #     };
  #   };
  # };
  containers.wagtail = {
    autoStart = true;
    # privateNetwork = true;
    # hostBridge = "br0";
    # hostAddress = "192.168.100.10";
    # localAddress = "192.168.100.11";
    # hostAddress6 = "fc00::1";
    # localAddress6 = "fc00::2";
    bindMounts = { 
      "/var/www/wagtail" = { 
        hostPath = "/var/www/wagtail";
        isReadOnly = false; 
       }; 
     };
    config = { config, pkgs, ... }: {
      networking.firewall.allowedTCPPorts = [ 22 25 80 443 143 587 993 995 636 8443 9443 ];
      users.users.wagtail.uid = 1003;
      # users.groups.users.gid = 1003;
      nix.settings.experimental-features = "nix-command flakes";
      time.timeZone = "Europe/Amsterdam";
      system.stateVersion = "23.11";
      environment.systemPackages = with pkgs; [
        ((vim_configurable.override {  }).customize{
          name = "vim";
          vimrcConfig.customRC = ''
            " your custom vimrc
            set mouse=a
            set nocompatible
            colo torte
            syntax on
            set tabstop     =2
            set softtabstop =2
            set shiftwidth  =2
            set expandtab
            set autoindent
            set smartindent
            " ...
          '';
          }
        )
        python311
        python311Packages.pillow
        python311Packages.gunicorn
        python311Packages.pip
        libjpeg
        zlib
        libtiff
        freetype
        python311Packages.venvShellHook
        curl
        wget
        lynx
        dig    
        python311Packages.pylibjpeg-libjpeg
        git
        tmux
        bat
        cowsay
        lzlib
        killall
        pwgen
        python311Packages.pypdf2
        python311Packages.python-ldap
        python311Packages.pq
        python311Packages.aiosasl
        python311Packages.psycopg2
        gettext
        sqlite
        postgresql_14
        ];

      # networking = {
      #   firewall = {
      #     enable = false;
      #     allowedTCPPorts = [ 80 443 ];
      #   };
        # Use systemd-resolved inside the container
        # useHostResolvConf = lib.mkForce false;
      #};
        
      # services.resolved.enable = true;

      # services.postgresql = {
      #   enable = true;
      #   enableTCPIP = true;
      #   ensureDatabases = [
      #     "wagtail"
      #     "previous"
      #     "fairemain"
      #   ];
          # # ensureDBOwnership = true;
      # };
      users.users.wagtail.isNormalUser = true;
      systemd.services.wagtail = {
        description = "Les Grands Voisins Wagtail Website";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          WorkingDirectory = "/home/wagtail/wagtail-lesgv/";
          # ExecStart = ''/home/wagtail/venv/bin/gunicorn --env WAGTAIL_ENV='production' --access-logfile access.log --chdir /home/wagtail/wagtail-lesgv --workers 3 --bind unix:/var/lib/wagtail/wagtail-lesgv.sock lesgv.wsgi:application'';
          ExecStart = ''/home/wagtail/venv/bin/gunicorn --env WAGTAIL_ENV='production' --access-logfile /var/log/wagtail/access.log --error-logfile /var/log/wagtail/error.log --chdir /home/wagtail/wagtail-lesgv --workers 12 --bind 127.0.0.1:8000 lesgv.wsgi:application'';
          Restart = "always";
          RestartSec = "10s";
          User = "wagtail";
          Group = "users";
        };
        unitConfig = {
          StartLimitInterval = "1min";
        };
      };
    };
  };
}

  # networking.nat = {
  #   enable = true;
  #   internalInterfaces = ["ve-+"];
  #   externalInterface = "ens3";
  #   # Lazy IPv6 connectivity for the container
  #   enableIPv6 = true;
  # };

  # networking.vlans."vlandav" = {
  #   id = 8;
  #   interface = "eno1";
  # };

  # To be able to ping containers from the host, it is necessary
  # to create a macvlan on the host on the VLAN 1 network.
  # networking.macvlans.mv-eno1-host = {
  #   interface = "eno1";
  #   mode = "bridge";
  # };
  # networking.interfaces.eno1.ipv4.addresses = lib.mkForce [];
  # networking.interfaces.eno1.ipv6.addresses = lib.mkForce [];
  # networking.interfaces.mv-eno1-host = {
  #   ipv4.addresses = [ { address = "192.168.8.1"; prefixLength = 24; } ];
  #   ipv6.addresses = [ { address = "fc00::8:8:1"; prefixLength = 96; } ];
  # };

  # networking.interfaces."vlandav" = {
  #   ipv4 = {
  #     addresses = [
  #       {
  #         address = "10.8.8.1";
  #         prefixLength = 24;
  #       }
  #     ];
  #   };
  #   ipv6 = {
  #     addresses = [
  #       {
  #         address = "fc00::8:8:1";
  #         prefixLength = 96;
  #       }
  #     ];
  #   };  
  # };

    # networking.firewall.trustedInterfaces = [
    #   "br0"
    # ];

    # networking.bridges = { br0 = { interfaces = [ "enp0s31f6" "ve-dav" ]; }; };
    # networking.interfaces.br0 = {
    #   ipv4.addresses = [ { address = "192.168.8.1"; prefixLength = 24; } ];
    #   ipv6.addresses = [ { address = "fc00::8:8:1"; prefixLength = 96; } ];
    # };

  # containers.dav = {
  #     # autoStart = true;


  #     #hostBridge = "mv-eno1-host";
  #     # privateNetwork = true;
  #     # forwardPorts = [{
  #     #   containerPort = 80;
  #     #   hostPort = 8080;
  #     #   protocol = "tcp";
  #     # }{
  #     #   containerPort = 443;
  #     #   hostPort = 8443;
  #     #   protocol = "tcp";
  #     # }];
  #     # interfaces = ["mv-eno1-host"];
  #     # localAddress6 = "fc00::8:8:8/96";
  #     # localAddress = "192.168.8.8/24";
  #     # # macvlans = ["eno1"];
  #     # hostAddress6 = "fc00::8:8:1";
  #     # hostAddress = "192.168.8.1";

  #     bindMounts = {
  #       "/usr/local/lib" = {hostPath="/usr/local/lib";};
  #     };


  #     config = { config, pkgs, ... }: {
  #       # nix.settings.experimental-features = "nix-command flakes";
  #       time.timeZone = "Europe/Amsterdam";
  #       system.stateVersion = "23.11";
  #       imports = [
  #         ./common.nix
  #       ];
  #       # networking.interfaces.mv-eno1-host = {
  #       #   ipv4.addresses = [ { address = "192.168.8.8"; prefixLength = 24; } ];
  #       #   ipv6.addresses = [ { address = "fc00::8:8:8"; prefixLength = 96; } ];
  #       # };
  #       # environment.systemPackages = with pkgs; [
  #       #   httpd
  #       # ];
  #       services.httpd = {
  #         enable = true;
  #         # enablePHP = false;
  #         # adminAddr = "chris@lesgrandsvoisins.com";
  #         extraModules = [ "proxy" "proxy_http" "dav"
  #           { name = "auth_openidc"; path = "/usr/local/lib/modules/mod_auth_openidc.so"; }
  #         ];
  #         # virtualHosts = {
  #         #   "localhost" = {
  #         #      *.listen = 88
  #         #   };
  #         # };
  #         virtualHosts."localhost" = {
  #           listen = [{
  #             ip = "*";
  #             port = 8080;
  #           }];
  #           documentRoot = "/var/dav/";
  #           extraConfig = ''
  #             DavLockDB /tmp/DavLock
  #             OIDCProviderMetadataURL https://authentik.lesgrandsvoisins.com/application/o/dav/.well-known/openid-configuration
  #             OIDCClientID V7p2o3hX6Im6crzdExLI1lb81zMJEjDO3mO3rNBk
  #             OIDCClientSecret Qgi9BFz7UOzwsJUAtN5Pa28sUL4oyrbkv2gvpsELMUgksPoLReS2eu9aHqJezyyoquJV02IX0UFPB8cvIB8uC9OW42MC4q8qswVeuM6aOUSvEXas1lQKnwAxad5sWrXc
  #             OIDCRedirectURI https://dav.desgv.com/chris/redirect_uri
  #             OIDCCryptoPassphrase JoWT5Mz1DIzsgI3MT2GH82aA6Xamp2ni
  #             OIDCXForwardedHeaders   X-Forwarded-Port X-Forwarded-Host X-Forwarded-Proto

  #             <Location "/chris/">
  #               AuthType openid-connect
  #               Require valid-user
  #             </Location>

  #           <Directory "/var/dav/">

  #             Dav On


  #             # AuthName DAV
  #             # AuthType oauth2
  #             # OAuth2TokenVerify introspect https://authentik.lesgrandsvoisins.com/application/o/introspect/ introspect.ssl_verify=false&introspect.auth=client_secret_post&client_id=V7p2o3hX6Im6crzdExLI1lb81zMJEjDO3mO3rNBk&client_secret=Qgi9BFz7UOzwsJUAtN5Pa28sUL4oyrbkv2gvpsELMUgksPoLReS2eu9aHqJezyyoquJV02IX0UFPB8cvIB8uC9OW42MC4q8qswVeuM6aOUSvEXas1lQKnwAxad5sWrXc

  #             # Require oauth2_claim .*chris@lesgrandsvoinsins.com.*
  #             # require valid-user 

  #             # AuthType Basic
  #             # 
  #             # AuthUserFile /var/www/.htpasswd
  #             # require valid-user 

  #             # <LimitExcept GET HEAD OPTIONS>
  #             #   require user admin
  #             # </LimitExcept>
  #           </Directory>
  #           '';
  #         };
  #       };
  #     };
  # };

  # containers.roundcube = {
  #   autoStart = true;
  #   privateNetwork = true;

  # };

  # containers.crabfit = {
  #   autoStart = true;
  #   privateNetwork = true;
  #   config = { config, pkgs, ... }: {
  #     users.users.crabfit = {
  #        isNormalUser = true;
  #        createHome = true;
  #        useDefaultShell = true;
  #        extraGroups = ["docker"];
  #     };
  #     virtualisation.docker = {
  #       enable = true;
  #       rootless = {
  #         enable = true;
  #         setSocketVariable = true;
  #       };
  #     };
  #     networking.firewall.allowedTCPPorts = [ 22 25 80 443 143 587 993 995 636 8443 9443 ];
  #     nix.settings.experimental-features = "nix-command flakes";
  #     time.timeZone = "Europe/Amsterdam";
  #     system.stateVersion = "23.11";
  #     environment.sessionVariables = rec {
  #       NEXT_PUBLIC_API_URL = "apicrabfit.resdigita.com";
  #       FRONTEND_URL =	"https: //crabfit.resdigita.com";
  #     };
  #     environment.systemPackages = with pkgs; [
  #       ((vim_configurable.override {  }).customize{
  #         name = "vim";
  #         vimrcConfig.customRC = ''
  #           " your custom vimrc
  #           set mouse=a
  #           set nocompatible
  #           colo torte
  #           syntax on
  #           set tabstop     =2
  #           set softtabstop =2
  #           set shiftwidth  =2
  #           set expandtab
  #           set autoindent
  #           set smartindent
  #           " ...
  #         '';
  #         }
  #       )
  #       curl
  #       wget
  #       lynx
  #       dig    
  #       tmux
  #       bat
  #       cowsay
  #       git
  #       lzlib
  #       killall
  #       pwgen
  #       gettext
  #       sqlite
  #       nodePackages.vercel
  #       flyctl
  #       docker
  #       busybox
  #     ];
  #   };
  # };
  # containers.seafile = {
  #   autoStart = true;
  #   privateNetwork = true;
  #   hostAddress = "192.168.100.10";
  #   localAddress = "192.168.100.11";
  #   hostAddress6 = "fc00::1";
  #   localAddress6 = "fc00::2";
  #   config = { config, pkgs, ... }: {
  #     environment.systemPackages = with pkgs; [
  #       ((vim_configurable.override {  }).customize{
  #         name = "vim";
  #         vimrcConfig.customRC = ''
  #           " your custom vimrc
  #           set mouse=a
  #           set nocompatible
  #           colo torte
  #           syntax on
  #           set tabstop     =2
  #           set softtabstop =2
  #           set shiftwidth  =2
  #           set expandtab
  #           set autoindent
  #           set smartindent
  #           " ...
  #         '';
  #         }
  #       )
  #       nginx
  #       lynx
  #       python311
  #       python311Packages.setuptools
  #       python311Packages.pip memcached libmemcached pwgen sqlite
  #       wget curl
  #       mariadb
  #       seafile-server
  #       seafile-shared
  #       python311Packages.seaserv
  #       seahub
  #       ];
  #     system.stateVersion = "23.11";
  #     nix.settings.experimental-features = "nix-command flakes";
  #     networking = {
  #       firewall = {
  #         enable = true;
  #         allowedTCPPorts = [ 8000 8082 ];
  #       };
  #       # Use systemd-resolved inside the container
  #       # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
  #       useHostResolvConf = lib.mkForce false;
  #     };
  #     users.users.seafile = {
  #       isNormalUser = true;
  #     };
  #     services = {
  #       resolved.enable = true;
  #       mysql = {
  #         enable = true;
  #         package = pkgs.mariadb;
  #         ensureUsers = [
  #           {
  #             name = "seafile";
  #             ensurePermissions = {
  #               "seafile.*" = "ALL PRIVILEGES";
  #             };
  #           }
  #         ];
  #         ensureDatabases = ["seafile"];
  #         initialDatabases = [{name = "seafile";}];
  #       };
  #       nginx = {
  #         enable = true;
  #         virtualHosts."192.168.100.11" = {
  #           locations."/media" = {
  #              root = "/opt/seafile/seafile-server-latest/seahub";
  #           };
  #           locations."/" = {
  #            proxyPass = "http://192.168.100.11:8000";
  #            extraConfig = ''
  #              proxy_set_header   Host $host;
  #              proxy_set_header   X-Real-IP $remote_addr;
  #              proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
  #              proxy_set_header   X-Forwarded-Host $server_name;
  #              proxy_read_timeout  1200s;

  #              # used for view/edit office file via Office Online Server
  #              client_max_body_size 0;

  #              access_log      /var/log/nginx/seahub.access.log; # seafileformat;
  #              error_log       /var/log/nginx/seahub.error.log;
  #            '';
  #           };
  #           locations."/seafhttp" = {
  #            proxyPass = "http://192.168.100.11:8082";
  #            extraConfig = ''
  #              rewrite ^/seafhttp(.*)$ $1 break;
  #               proxy_pass http://127.0.0.1:8082;
  #               client_max_body_size 0;
  #               proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;

  #               proxy_connect_timeout  36000s;
  #               proxy_read_timeout  36000s;
  #               proxy_send_timeout  36000s;

  #               send_timeout  36000s;

  #               access_log      /var/log/nginx/seafhttp.access.log; # seafileformat;
  #               error_log       /var/log/nginx/seafhttp.error.log;
  #            '';
  #           };
  #         };
  #       };
  #       # seafile = {
  #       #     enable = true;
  #       #     adminEmail = "chris@mann.fr";
  #       #     initialAdminPassword = "Ahs3sae1";
  #       #     seafileSettings = {
  #       #       # https://manual.seafile.com/config/seafile-conf/
  #       #       fileserver.port = 8082;
  #       #       fileserver.host = "192.168.100.11";
  #       #     };
  #       #     # seahubExtraConf = ''
  #       #     #   ENABLE_OAUTH = True

  #       #     #   # If create new user when he/she logs in Seafile for the first time, defalut `True`.
  #       #     #   OAUTH_CREATE_UNKNOWN_USER = True

  #       #     #   # If active new user when he/she logs in Seafile for the first time, defalut `True`.
  #       #     #   OAUTH_ACTIVATE_USER_AFTER_CREATION = True

  #       #     #   # Usually OAuth works through SSL layer. If your server is not parametrized to allow HTTPS, some method will raise an "oauthlib.oauth2.rfc6749.errors.InsecureTransportError". Set this to `True` to avoid this error.
  #       #     #   OAUTH_ENABLE_INSECURE_TRANSPORT = True

  #       #     #   # Client id/secret generated by authorization server when you register your client application.
  #       #     #   OAUTH_CLIENT_ID = "seafile"
  #       #     #   OAUTH_CLIENT_SECRET = "${seafilePassword}"

  #       #     #   # Callback url when user authentication succeeded. Note, the redirect url you input when you register your client application MUST be exactly the same as this value.
  #       #     #   OAUTH_REDIRECT_URL = 'https://seafile.resdigita.com/oauth/callback/'

  #       #     #   # The following should NOT be changed if you are using Github as OAuth provider.
  #       #     #   OAUTH_PROVIDER_DOMAIN = 'keycloak.resdigita.com:10443'
  #       #     #   OAUTH_AUTHORIZATION_URL = 'https://keycloak.resdigita.com:10443/realms/master/protocol/openid-connect/auth'
  #       #     #   OAUTH_TOKEN_URL = 'https://keycloak.resdigita.com:10443/realms/master/protocol/openid-connect/token'
  #       #     #   OAUTH_USER_INFO_URL = 'https://keycloak.resdigita.com:10443/realms/master/protocol/openid-connect/userinfo'
  #       #     #   OAUTH_SCOPE = ["profile","email']
  #       #     #   OAUTH_ATTRIBUTE_MAP = {
  #       #     #       "id": (True, "email"),  # Please keep the 'email' option unchanged to be compatible with the login of users of version 11.0 and earlier.
  #       #     #       "name": (False, "name"),
  #       #     #       "email": (False, "contact_email"),
  #       #     #       "uid": (True, "uid"),   # Since 11.0 version, Seafile use 'uid' as the external unique identifier of the user.
  #       #     #                               # Different OAuth systems have different attributes, which may be: 'uid' or 'username', etc.
  #       #     #                               # If there is no 'uid' attribute, do not configure this option and keep the 'email' option unchanged,
  #       #     #                               # to be compatible with the login of users of version 11.0 and earlier.
  #       #     #   }
  #       #     # '';
  #       #     ccnetSettings = {
  #       #       # https://manual.seafile.com/config/ccnet-conf/
  #       #       General.SERVICE_URL = "http://192.168.100.11:8082";
  #       #     };
  #       # };
  #     };
  #   };
  # };
