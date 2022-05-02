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

    pub fn burn(self: *Tile) void {
        if (self.color.r < 200) {
            self.color.r += 14;
        }
        if (self.color.g > 20) {
            self.color.g -= 10;
        } else {
            self.color.g = 20;
        }
        if (self.color.b > 4) {
            self.color.b -= 4;
        } else {
            self.color.b = 4;
        }
        
    }
    pub fn get_right_x(self: *Tile) f32 {
        return self.x + self.random_factor + self.w * 0.5 * self.scale;
    }
    pub fn get_left_x(self: *Tile) f32 {
        return self.x - self.w * 0.5 * self.scale;
    }
};

fn get_color() rl.Color {
    var r = rand.intRangeAtMost(u8, 16, 60);
    var g = rand.intRangeAtMost(u8, 150, 200);
    var b = rand.intRangeAtMost(u8, 10, 50);
    var a = rand.intRangeAtMost(u8, 200, 220);
    return rl.Color{.r = r, .g = g, .b = b, .a = a};
}

pub const Ground = struct{
    tiles : ArrayList(Tile),
    fn append_tile(self: *Ground, t: Tile) !void {
        var append = try self.tiles.append(t);
        _ = append;
    }
    pub fn load(self: *Ground) void {
        var start_y: f32 = lyra.start_y;
        var th: f16= 124;
        var tw: f16 = 256;
        while (start_y < lyra.game_height + th * 0.5) {
            var start_x: f32 = lyra.start_x - 200;
            var i: u8 = 0;
            var scale = start_y / lyra.game_height;
            var w = tw * scale;
            var h = th * scale;
            while (start_x < lyra.game_width) {
                if (start_x > lyra.start_x - w * 0.5) {
                    const random_factor = @intToFloat(f16, rand.intRangeAtMost(u16, 0, @floatToInt(u16, w * 0.4))) - w * 0.4 * 0.5;
                    var color = get_color();
                    var t = Tile{ .x = start_x, .y = start_y, .w = w, .h = h, .scale = 1, .random_factor = random_factor, .color = color, .org_color = color };
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
            if (t.color.r != t.org_color.r) {
                t.color.r -= 1;
            }
            if (t.color.r > 60) {
                if (t.scale > 0.5) {
                    t.scale -= 0.01;
                } else {
                    t.scale = 0.5;
                }
            }
            else {
                var heal = rand.intRangeAtMost(u16, 0, 10);
                if (heal > 7) {
                    if (t.color.g != t.org_color.g) {
                        var ra = rand.intRangeAtMost(u16, 0, 10);
                        if (ra > 7) {
                            t.color.g += 1;
                        }
                    }
                    else if (t.color.b != t.org_color.b) {
                        t.color.b += 1;
                    } else {
                        if (t.scale < 1) {
                            t.scale += 0.005;
                        } else {
                            t.scale = 1;
                        }
                    }
                }
            }

        }

    }
    pub fn predraw(_: *Ground) void {
        var color = rl.Color{.r = 50, .g = 100, .b = 10, .a = 220};

        rl.DrawRectangle(0, @floatToInt(u16, lyra.start_y), lyra.game_width, lyra.game_height, color);
    }
    pub fn draw(self: *Ground, i : usize) void {
        var t = self.tiles.items[i];
        var h: f32 = t.h * t.scale;

        var v1 = rl.Vector2{.x = t.get_left_x() , .y = t.y};
        var v2 = rl.Vector2{.x = t.get_right_x(), .y = t.y};
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
