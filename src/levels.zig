const Level = @import("levels/level.zig").Level;
const Terrain = @import("ground.zig").Terrain;


pub const daisyland = Level{
    .ground = [5]Terrain{
        Terrain{
            .w = 1000,
            .cs_r = [2]u8{16, 60},
            .cs_g = [2]u8{60, 120},
            .cs_b = [2]u8{200, 250},
        },
        Terrain{
            .w = 1000,
            .cs_r = [2]u8{16, 60},
            .cs_g = [2]u8{160, 200},
            .cs_b = [2]u8{30, 50},
        },
        Terrain{
            .w = 1000,
            .cs_r = [2]u8{50, 60},
            .cs_g = [2]u8{130, 200},
            .cs_b = [2]u8{80, 120},
        },
        Terrain{
            .w = -1,
            .cs_r = [2]u8{16, 60},
            .cs_g = [2]u8{60, 90},
            .cs_b = [2]u8{130, 200},
        },
        Terrain{},
    },
};
