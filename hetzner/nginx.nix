{ config, pkgs, lib, ... }:
let 
in
{ 
  services.nginx = {
    enable = true;
    defaultListenPort = 8443;
    defaultHTTPListenPort = 8888;
    defaultListen = [{ addr = "0.0.0.0"; } { addr = "[::0]"; }];
    
  }

}