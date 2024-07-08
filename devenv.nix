{ pkgs, lib, config, inputs, ... }:

let
  customRaylib = pkgs.raylib.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or []) ++ [
      (pkgs.writeText "enable-jpeg.patch" ''
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
    buildInputs = oldAttrs.buildInputs ++ [ pkgs.libjpeg ];
    cmakeFlags = oldAttrs.cmakeFlags ++ [
      "-DUSE_EXTERNAL_GLFW=ON"
      "-DBUILD_EXAMPLES=OFF"
    ];
  });
in
{
  # https://devenv.sh/basics/
  env.GREET = "devenv";

  # https://devenv.sh/packages/
  packages = [
    pkgs.git
    pkgs.clang
    pkgs.llvmPackages.libclang
    customRaylib
    pkgs.libjpeg
    pkgs.pkg-config
  ];

  # https://devenv.sh/scripts/
  scripts = {
    hello.exec = "echo hello from $GREET";
    build-project.exec = ''
      clang -o myproject main.c `pkg-config --cflags --libs raylib` -lm
    '';
    run-project.exec = "./Kasaival";
  };

  enterShell = ''
    hello
    git --version
  '';

  # https://devenv.sh/languages/
  languages.c.enable = true;

  # Set the C compiler in the environment
  env.CC = "${pkgs.clang}/bin/clang";

  # https://devenv.sh/pre-commit-hooks/
  # pre-commit.hooks.shellcheck.enable = true;

  # https://devenv.sh/processes/
  # processes.ping.exec = "ping example.com";

  # See full reference at https://devenv.sh/reference/options/
}
