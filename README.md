# Kasaival

Flame survival game

## supported platforms
- Windows
- macOS
- Linux
- HTML5/WebGL (emscripten)


## BUILD

### dependencies
- git
- [zig (0.10.0)](https://ziglang.org/documentation/master/)
- [emscripten sdk](https://emscripten.org/)

```
git clone --recurse-submodules https://codeberg.org/wolfi/kasaival
```

### run locally

```sh
zig build run
```

### build for host os and architecture

```sh
zig build -Drelease-small
```

The output files will be in `./zig-out/bin`

### html5 / emscripten

```sh
EMSDK=../emsdk #path to emscripten sdk

zig build -Drelease-small -Dtarget=wasm32-wasi --sysroot "$EMSDK/upstream/emscripten"
```

The output files will be in `./zig-out/web/`

- game.html (entry point)
- game.js
- game.wasm
- game.data

The game data needs to be served with a webserver. Just opening the game.html in a browser won't work

You can utilize python as local http server:
```sh
python -m http.server
```