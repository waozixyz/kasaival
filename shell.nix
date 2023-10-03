let
  nixpkgs = import <nixpkgs> { };

in
nixpkgs.mkShell {
  buildInputs = [
    nixpkgs.love
    nixpkgs.zip
    nixpkgs.nodejs
  ];

  shellHook = ''
    echo "Development environment loaded!"
  '';
}


