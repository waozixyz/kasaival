const Terrain = @import("ground.zig").Terrain;
const rl = @import("raylib/raylib.zig");


pub const Ground = struct {
    terrains: [5]Terrain = [5]Terrain{ Terrain{}, Terrain{}, Terrain{}, Terrain{}, Terrain{} },
    tile_w: f32 = 33,
    tile_h: f32 = 32,
};

pub const Level = struct {
    music: [*:0]const u8 = "assets/music/StrangerThings.ogg",
    ground: Ground = Ground{},
};
