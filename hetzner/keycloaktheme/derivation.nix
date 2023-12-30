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
  for i in account admin email login welcome static static/css static/js static/images static/fonts static/fonts/fengardoneue static/fonts/lack
  do
  echo $i
  mkdir -p $out/$i
  cp -r $i/* $out/$i
  done
  '';
}