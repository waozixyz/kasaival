
const Terrain = @import("ground.zig").Terrain;
const rl = @import("raylib/raylib.zig");

pub const Ground = struct {
    terrains: [5]Terrain = [5]Terrain{Terrain{},Terrain{},Terrain{},Terrain{},Terrain{}},
    tile_w: f16 = 33,
    tile_h: f16 = 32,
};

pub const Level = struct {
    ground: Ground = Ground{},
};