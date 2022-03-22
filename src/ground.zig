const std = @import("std");
const rl = @import("raylib");


const lyra = @import("lyra.zig");

const print = std.debug.print;
const math = std.math;
const ArrayList = std.ArrayList;
const test_allocator = std.testing.allocator;
const rand = std.crypto.random;


const Tile = struct {
    x: f32,
    y: f32,
    w: f32,
    h: f32,
    scale: f32,
    random_factor: f32,
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
        else if (self.color.a != self.org_color.a) {
            self.color.a += 1;
        }
    }
    pub fn burn(self: *Tile) void {
        if (self.color.a > 5) {
            self.color.a -= 5;
        }
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
        var scale: f32 = 1;
        var start_y: f32 = lyra.start_y;
        var th: f16= 128;
        var tw: f16 = 256;
        while (start_y < lyra.game_height + th) {
            var start_x: f32 = lyra.start_x - 200;
            var i: u8 = 0;
            scale = start_y / lyra.game_height;
            var w = @intToFloat(f16, @floatToInt(i16, tw * scale));
            var h = @intToFloat(f16, @floatToInt(i16, th * scale));
            while (start_x < lyra.game_width) {
                if (start_x > lyra.start_x - w) {
                    const random_factor = @intToFloat(f16, rand.intRangeAtMost(u16, 0, @floatToInt(u16, w * 0.4))) - w * 0.4 * 0.5;
                    var color = colors[ rand.intRangeAtMost(u64, 0, 8)];
                    var t = Tile{ .x = start_x, .y = start_y, .scale = 1, .w = w, .h = h, .random_factor = random_factor, .color = color, .org_color = color };
                    append_tile(self, t) catch |err| {
                        std.log.info("Caught error: {s}", .{ err });
                    };
                }
                start_x += w * 0.4;
                i += 1;
            }
            start_y += h * 0.4;

        } 
    }
    pub fn update(self: *Ground) void {

        for (self.tiles.items) |*t, i| {
            _ = i;
            var heal = rand.intRangeAtMost(u16, 0, 10);
            if (heal > 7) {
                t.heal();
            }

        }

    }
    pub fn predraw(_: *Ground) void {
        var color = rl.Color{.r = 50, .g = 100, .b = 10, .a = 220};

        rl.DrawRectangle(0, @floatToInt(u16, lyra.start_y), lyra.game_width, lyra.game_height, color);
    }

    pub fn draw(self: *Ground, i : usize) void {
        var t = self.tiles.items[i];
        var scale: f32 = @intToFloat(f32, t.color.a) / @intToFloat(f32, t.org_color.a);
        var w: f32 = t.w * 0.5 * scale;
        var h: f32 = t.h * scale;

        var v1 = rl.Vector2{.x = t.x - w , .y = t.y};
        var v2 = rl.Vector2{.x = t.x + w + t.random_factor, .y = t.y};
        var v3 = rl.Vector2{.x = t.x, .y = t.y - h + t.random_factor};
                                               
        rl.DrawTriangle(v1, v2, v3, t.color);
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
