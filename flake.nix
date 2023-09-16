{
  description = "A development environment for raylib and nim";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  

  outputs = { self, nixpkgs, }: {

    devShell.x86_64-linux = with nixpkgs.legacyPackages.x86_64-linux; let
      naylibSrc = builtins.fetchGit {
        url = "https://github.com/planetis-m/naylib.git";
        ref = "main";
        rev = "e89a1aca68c4f32e97ceda3283e0638177c5428d";
      };

    in mkShell {
      buildInputs = [
        nim2
        raylib
        nimble-unwrapped
        xorg.libXcursor
        xorg.libXrandr
        xorg.libXinerama
        xorg.libXi
        xorg.libXxf86vm
        gcc
      ];

      shellHook = ''
        # Point Nim and the C compiler to the right locations for raylib
        export NIMFLAGS="-d:raylibHeaderPath=${raylib}/include -d:raylibLibPath=${raylib}/lib"
        export CFLAGS="-I${raylib}/include"
        export LDFLAGS="-L${raylib}/lib"

        echo ${raylib}

        echo "Development environment loaded!"
      '';
    };
  };
}
