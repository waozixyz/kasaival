const std = @import("std");
const rl = @import("raylib");


const lyra = @import("lyra.zig");

const print = std.debug.print;
const math = std.math;
const ArrayList = std.ArrayList;
const test_allocator = std.testing.allocator;


const Tile = struct {
    v1: rl.Vector2,
    v2: rl.Vector2,
    width: f32,
    color: rl.Color,
};

const colors = [_]rl.Color{
    rl.Color{.r = 20, .g = 200, .b = 5, .a = 200},
    rl.Color{.r = 18, .g = 190, .b = 7, .a = 200},
    rl.Color{.r = 16, .g = 180, .b = 9, .a = 200},
    rl.Color{.r = 18, .g = 175, .b = 7, .a = 200},
    rl.Color{.r = 20, .g = 170, .b = 5, .a = 200},
    rl.Color{.r = 22, .g = 165, .b = 9, .a = 200},
    rl.Color{.r = 24, .g = 160, .b = 12, .a = 200},
    rl.Color{.r = 26, .g = 155, .b = 15, .a = 200},
    rl.Color{.r = 28, .g = 150, .b = 20, .a = 200}

};
pub const Ground = struct{
    tiles : ArrayList(Tile),
    fn append_tile(self: *Ground, t: Tile) !void {
        var append = try self.tiles.append(t);
        _ = append;
    }
    pub fn load(self: *Ground) void {
        const rand = std.crypto.random;

        var start_x: f32 = lyra.start_x;
        var height: f32 = 64;
        var width: f32 = 32;

        while (start_x < lyra.game_width) {
            var start_y: f32 = lyra.start_y;
            while (start_y < lyra.game_height) {

                var color = colors[ rand.intRangeAtMost(u64, 0, 8)];
                var t = Tile{
                    .v1 = rl.Vector2{.x = start_x, .y = start_y},
                    .v2 = rl.Vector2{.x = start_x, .y = start_y - height},
                    .width = width,
                    .color = color
                };
                append_tile(self, t) catch |err| {
                    std.log.info("Caught error: {s}", .{ err });
                };
                start_y += height * 0.5;
            }
            start_x += width;
        } 
    }
    pub fn update(_: *Ground) void {

    }
    pub fn draw(self: *Ground) void {
        for (self.tiles.items) |*t, i| {
            _ = i;

            // update x pos with lyra camera x 
            rl.DrawLineEx(t.v1, t.v2, t.width, t.color);
        }
    }
    pub fn unload(_: *Ground) void {
    }

};


pub fn new() Ground {
    return Ground{
        .tiles = ArrayList(Tile).init(test_allocator),

    };
}
