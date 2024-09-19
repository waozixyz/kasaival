{
  description = "Development environment for Raylib project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            git
            clang
            llvmPackages.libclang
            customRaylib
            libjpeg
            pkg-config
          ];

          shellHook = ''
            echo "hello from devenv"
            git --version
          '';

          CC = "${pkgs.clang}/bin/clang";
        };

        packages.default = pkgs.writeShellScriptBin "build-and-run" ''
          clang -o Kasaival main.c $(pkg-config --cflags --libs raylib) -lm
          ./Kasaival
        '';
      }
    );

  overlays.default = final: prev: {
    customRaylib = prev.raylib.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or []) ++ [
        (final.writeText "enable-jpeg.patch" ''
          diff --git a/src/config.h b/src/config.h
          index xxxxxxx..yyyyyyy 100644
          --- a/src/config.h
          +++ b/src/config.h
          @@ -44,7 +44,7 @@
           #define SUPPORT_FILEFORMAT_PNG      1
           //#define SUPPORT_FILEFORMAT_BMP      1
           //#define SUPPORT_FILEFORMAT_TGA      1
          -//#define SUPPORT_FILEFORMAT_JPG      1
          +#define SUPPORT_FILEFORMAT_JPG      1
           #define SUPPORT_FILEFORMAT_GIF      1
           #define SUPPORT_FILEFORMAT_QOI      1
           //#define SUPPORT_FILEFORMAT_PSD      1
        '')
      ];
      buildInputs = oldAttrs.buildInputs ++ [ final.libjpeg ];
      cmakeFlags = oldAttrs.cmakeFlags ++ [
        "-DUSE_EXTERNAL_GLFW=ON"
        "-DBUILD_EXAMPLES=OFF"
      ];
    });
  };
}
