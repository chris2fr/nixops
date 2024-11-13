{ 
  pkgs ? import <nixpkgs> { }
}:

pkgs.stdenv.mkDerivation (finalAttrs: {
  pname = "sftpgo";
  name = "sftpgo";
  version = "1.0github.com/sftpgo/sftpgo/releases/download/v1.0.9/sftpgo-linux-amd64";
  src = pkgs.fetchurl {
    url = "https://github.com/sftpgo/sftpgo/releases/download/v1.0.9/sftpgo-linux-amd64";
    sha256 = "sha256-xLmFTH6PcNMF73zmhCHalIv6zF+OmwH9GAKEXOXfGdM=";
  };
  nativeBuildInputs = [ ];
  buildInputs = [ ];

  phases = [ "installPhase" ];  

  installPhase = ''
    install -D $src $out/bin/sftpgo
    chmod a+x $out/bin/sftpgo 
  '';
  meta = with pkgs.lib; {
    homepage = "https://github.com/sftpgo/sftpgo";
    changelog = "https://github.com/sftpgo/sftpgo/releases/tag/v${version}";
    description = "This plugin enables LDAP/Active Directory authentication for SFTPGo.";
    longDescription = ''
        The plugin can be configured within the plugins section of the SFTPGo configuration file or (recommended) using environment variables. To start the plugin you have to use the serve subcommand.
      '';
    mainProgram = "sftpgo";
  };
})  