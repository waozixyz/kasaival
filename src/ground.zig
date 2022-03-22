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
    v3: rl.Vector2,
    width: f32,
    color: rl.Color,
    org_color: rl.Color,
    pub fn heal(self: *Tile) void {
        if (self.color.r != self.org_color.r) {
            self.color.r -= 1;
        }
        else if (self.color.g != self.org_color.g) {
            self.color.g += 1;
        }

        else if (self.color.b != self.org_color.b) {
            self.color.b += 1;
        }
    }
    pub fn burn(self: *Tile) void {
        if (self.color.r < 200) {
            self.color.r += 14;
        }
        if (self.color.g > 60) {
            self.color.g -= 10;
        }
        if (self.color.b > 5) {
            self.color.b -= 4;
        }
    }
};

const colors = [_]rl.Color{
    rl.Color{.r = 20, .g = 200, .b = 10, .a = 220},
    rl.Color{.r = 50, .g = 190, .b = 12, .a = 200},
    rl.Color{.r = 16, .g = 180, .b = 15, .a = 210},
    rl.Color{.r = 18, .g = 175, .b = 20, .a = 200},
    rl.Color{.r = 60, .g = 170, .b = 22, .a = 220},
    rl.Color{.r = 22, .g = 165, .b = 26, .a = 200},
    rl.Color{.r = 24, .g = 160, .b = 32, .a = 220},
    rl.Color{.r = 26, .g = 155, .b = 45, .a = 220},
    rl.Color{.r = 28, .g = 150, .b = 40, .a = 220}

};
pub const Ground = struct{
    tiles : ArrayList(Tile),
    fn append_tile(self: *Ground, t: Tile) !void {
        var append = try self.tiles.append(t);
        _ = append;
    }
    pub fn load(self: *Ground) void {
        const rand = std.crypto.random;
        var height: f32 = 18;
        var width: f32 = 32;
        var start_y: f32 = lyra.start_y;

        while (start_y < lyra.game_height + height) {
            var start_x: f32 = lyra.start_x - width - 200;
            var i: u8 = 0;
            while (start_x < lyra.game_width + width) {
                if (start_x > lyra.start_x - width) {
                    const random_factor = @intToFloat(f16, rand.intRangeAtMost(u16, 0, @floatToInt(u16, width * 0.4))) - width * 0.4 * 0.5;
                    var color = colors[ rand.intRangeAtMost(u64, 0, 8)];
                    var v1 = rl.Vector2{.x = start_x - width * 0.5 , .y = start_y};
                    var v2 = rl.Vector2{.x = start_x + width * 0.5 + random_factor, .y = start_y};
                    var v3 = rl.Vector2{.x = start_x, .y = start_y - height + random_factor};
                    if (@mod(i, 2) == 0) {
                        v1 = rl.Vector2{.x = start_x - width * 0.5, .y = start_y + random_factor};
                        v2 = rl.Vector2{.x = start_x + random_factor, .y = start_y + height};
                        v3 = rl.Vector2{.x = start_x + width * 0.5, .y = start_y };
                    }
                    var t = Tile{ .v1 = v1, .v2 = v2, .v3 = v3, .width = width, .color = color, .org_color = color };

                    append_tile(self, t) catch |err| {
                        std.log.info("Caught error: {s}", .{ err });
                    };
                }
                start_x += width * 0.4;
                i += 1;
            }
            height *= 1.1;
            width *= 1.1;
            start_y += height * 0.4;

        } 
    }
    pub fn update(self: *Ground) void {
        for (self.tiles.items) |*t, i| {
            _ = i;
            t.heal();
        }
    }
    pub fn predraw(_: *Ground) void {
        rl.DrawRectangle(0, @floatToInt(u16, lyra.start_y), lyra.game_width, lyra.game_height, colors[0]);
    }

    pub fn draw(self: *Ground, i : usize) void {
        var t =self.tiles.items[i];
        rl.DrawTriangle(t.v1, t.v2, t.v3, t.color);
    }
    pub fn unload(self: *Ground) void {
        self.tiles.deinit();

    }

};


pub fn new() Ground {
    return Ground{
        .tiles = ArrayList(Tile).init(test_allocator),

    };
}
