{ pkgs, lib, config, inputs, ... }:

let
  customRaylib = pkgs.raylib.overrideAttrs (oldAttrs: {
    cmakeFlags = oldAttrs.cmakeFlags ++ [
      "-DSUPPORT_FILEFORMAT_JPG=ON"  # Enable JPEG support
    ];
    buildInputs = oldAttrs.buildInputs ++ [ pkgs.libjpeg ];
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
    run-project.exec = "./myproject";
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