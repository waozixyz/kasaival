const Level = @import("./level.zig").Level;
const Terrain = @import("../ground.zig").Terrain;
const TerrainMedium = @import("../ground.zig").TerrainMedium;


pub const Daisyland = Level{
    .ground = [Terrain{
            .start_x = 0,
            .end_x = 1000,
            .medium = TerrainMedium.water,
        }]
}