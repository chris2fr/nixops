{
  interetpublic = { ... }: {
    deployment.targetHost = "localhost";
    deployment.keys.httpd-radicale-oidcclientsecret.text = "7qd4nt7OgylV9eDtNtvoixeNI1YYEJJZ";
    imports = [./hardware-configuration.nix ./configuration.nix];
  };
}
