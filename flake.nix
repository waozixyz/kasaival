{
  description = "A development environment for raylib and nim";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";

  outputs = { self, nixpkgs }: {

    devShell.x86_64-linux = with nixpkgs.legacyPackages.x86_64-linux; mkShell {
      buildInputs = [
        nim
        raylib
      ];

      shellHook = ''
        echo "Development environment loaded!"
      '';
    };
  };
}
