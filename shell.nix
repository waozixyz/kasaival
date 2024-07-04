{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    vlang
    raylib
    xorg.libX11
    xorg.libXrandr
    xorg.libXinerama
    xorg.libXcursor
    xorg.libXi
    mesa
    libGL
    gcc
    gnumake
    pkg-config
    git
    gdb
  ];

  shellHook = ''
    export LD_LIBRARY_PATH="${pkgs.raylib}/lib:$LD_LIBRARY_PATH"
    export PKG_CONFIG_PATH="${pkgs.raylib}/lib/pkgconfig:$PKG_CONFIG_PATH"
    export C_INCLUDE_PATH="${pkgs.raylib}/include:$C_INCLUDE_PATH"
    export CFLAGS="-D_POSIX_C_SOURCE=200809L $CFLAGS"
  '';
}