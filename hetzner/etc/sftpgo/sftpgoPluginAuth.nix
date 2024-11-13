{
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation {
  pname = "sftpgo-plugin-auth";
  version = "1.0.9";

  src = fetchurl {
    url = "https://github.com/sftpgo/sftpgo-plugin-auth/releases/download/v1.0.9/sftpgo-plugin-auth-linux-amd64";
    sha256 = "sha256-xLmFTH6PcNMF73zmhCHalIv6zF+OmwH9GAKEXOXfGdM=";
  };

  phases = [ "installPhase" ];  

  installPhase = ''
    install -D $src $out/bin/sftpgo-plugin-auth
    chmod a+x $out/bin/sftpgo-plugin-auth 
  '';
}