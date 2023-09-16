let
  nixpkgs = import <nixpkgs> { };

in
nixpkgs.mkShell {
  buildInputs = [
    nixpkgs.nim
  ];

  shellHook = ''
    echo "Development environment loaded!"
  '';
}
