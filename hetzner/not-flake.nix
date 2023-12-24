{
  inputs.filestash-nix.url = "github:matthewcroughan/filestash-nix";

  outputs = { self, nixpkgs, filestash-nix }: {
    nixosConfigurations.my-machine = nixpkgs.lib.nixosSystem {
      modules = [
        filestash-nix.nixosModule
        {
          services.filestash.enable = true;
        }
      ];
    };
  };
}