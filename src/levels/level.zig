
const Terrain = @import("../ground.zig").Terrain;

pub const Level = struct {
    ground: [5]Terrain = [5]Terrain{Terrain{},Terrain{},Terrain{},Terrain{},Terrain{}},
};