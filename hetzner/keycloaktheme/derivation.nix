{ stdenv }:
stdenv.mkDerivation rec {
  name = "kctheme-${version}";
  version = "1.0";

  src = ./.;

  nativeBuildInputs = [ ];
  buildInputs = [ ];

  buildPhase = ''
  '';

  installPhase = ''
  for i in account admin email login welcome 
  do
  echo $i
  mkdir -p $out/$i
  cp -r $i/* $out/$i
  done
  '';
}