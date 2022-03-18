const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});

const lyra = @import("lyra.zig");

const flame = @import("particles/flame.zig");

const print = std.debug.print;
const math = std.math;
const ArrayList = std.ArrayList;
const test_allocator = std.testing.allocator;


const Tile = struct {
    v1: ray.struct_Vector2,
    v2: ray.struct_Vector2,
    width: f32,
    color: ray.struct_Color,
};

const colors = [_]ray.struct_Color{
    ray.Color{.r = 20, .g = 200, .b = 5, .a = 200},
    ray.Color{.r = 18, .g = 190, .b = 7, .a = 200},
    ray.Color{.r = 16, .g = 180, .b = 9, .a = 200},
    ray.Color{.r = 18, .g = 175, .b = 7, .a = 200},
    ray.Color{.r = 20, .g = 170, .b = 5, .a = 200},
    ray.Color{.r = 22, .g = 165, .b = 9, .a = 200},
    ray.Color{.r = 24, .g = 160, .b = 12, .a = 200},
    ray.Color{.r = 26, .g = 155, .b = 15, .a = 200},
    ray.Color{.r = 28, .g = 150, .b = 20, .a = 200}

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
                    .v1 = ray.Vector2{.x = start_x, .y = start_y},
                    .v2 = ray.Vector2{.x = start_x, .y = start_y - height},
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
            ray.DrawLineEx(t.v1, t.v2, t.width, t.color); 
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