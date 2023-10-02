let
  nixpkgs = import <nixpkgs> { };

in
nixpkgs.mkShell {
  buildInputs = [
    nixpkgs.love
  ];

  shellHook = ''
    echo "Development environment loaded!"
  '';
}


