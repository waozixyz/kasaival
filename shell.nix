{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    nim
    raylib
    nimble
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXinerama
    xorg.libXi
    xorg.libXxf86vm
    gcc
  ];

  shellHook = ''
    # Install naylib and perlin using nimble
    nimble install -y naylib perlin

    # Point Nim and the C compiler to the right locations for raylib
    export NIMFLAGS="-d:raylibHeaderPath=${pkgs.raylib}/include -d:raylibLibPath=${pkgs.raylib}/lib"
    export PKG_CONFIG_PATH="${pkgs.raylib}/lib/pkgconfig:$PKG_CONFIG_PATH"
    export LD_LIBRARY_PATH="${pkgs.raylib}/lib:$LD_LIBRARY_PATH"
    export CFLAGS="-I${pkgs.raylib}/include $CFLAGS"
    export LDFLAGS="-L${pkgs.raylib}/lib $LDFLAGS"
    echo "Raylib path: ${pkgs.raylib}"
    echo "Development environment loaded!"
  '';
}