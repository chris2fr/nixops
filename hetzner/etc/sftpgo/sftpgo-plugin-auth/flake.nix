{
  description = "SFTPGO Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }@inputs: let
    forAllSys = nixpkgs.lib.genAttrs nixpkgs.lib.platforms.all;
    # let pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };
    in {
      packages = forAllSys (system: let
        pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
        sftpgoWithPluginAuth =  (pkgs.callPackage ./sftpgoPluginAuth.nix { }  );
      in {
        # sftpgo = pkgs.sftpgo;
        default = sftpgoWithPluginAuth;
      });
      devShells = forAllSys (system: let
        pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
        sftpgoShell =  pkgs.mkShell { buildInputs = [ 
          pkgs.sftpgo
          (pkgs.callPackage ./sftpgoPluginAuth.nix { }  ) 
           ]; 
         };
      in {
        default = sftpgoShell;
      });
  };
}
