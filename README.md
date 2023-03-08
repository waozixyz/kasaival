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
- [zig (0.11.0)](https://ziglang.org/documentation/master/)
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
zig build
```

The output files will be in `./zig-out/bin`

### html5 / emscripten

```sh
EMSDK=../emsdk #path to emscripten sdk

zig build -Dtarget=wasm32-wasi --sysroot "$EMSDK/upstream/emscripten"
```

The output files will be in `./zig-out/web/`

- index.html (entry point)
- index.js
- index.wasm
- index.data

The game data needs to be served with a webserver. Just opening the index.html in a browser won't work

You can utilize python as local http server:
```sh
python -m http.server
```