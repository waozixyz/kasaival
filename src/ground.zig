const std = @import("std");
const rl = @import("raylib/raylib.zig");
const lyra = @import("lyra.zig");

const print = std.debug.print;
const math = std.math;
const ArrayList = std.ArrayList;

const Tile = struct {
    x: f32,
    y: f32,
    w: f32,
    h: f32,
    scale: f32,
    color: rl.Color,
    org_color: rl.Color,

    pub fn burn(self: *Tile) void {
        if (self.color.r < 200) {
            self.color.r += 20;
        }
        if (self.color.g > 100) {
            self.color.g -= 10;
        }
        if (self.color.b > 4) {
            self.color.b -= 4;
        }
        
    }
};

fn get_color() rl.Color {
    var r = @intCast(u8, rl.GetRandomValue(16, 60));
    var g = @intCast(u8, rl.GetRandomValue(150, 180));
    var b = @intCast(u8, rl.GetRandomValue(10, 50));
    var a = @intCast(u8, rl.GetRandomValue(240, 250));
    return rl.Color{.r = r, .g = g, .b = b, .a = a};
}

pub const Ground = struct {
    tiles : ArrayList(ArrayList(Tile)) = undefined,
    fn append_tile(self: *Ground, row: usize,  t: Tile) !void {
        var append = try self.tiles.items[row].append(t);
        _ = append;
    }
    fn append_row(self: *Ground, allocator: std.mem.Allocator) !void {
        var append = try self.tiles.append((ArrayList(Tile).init(allocator)));
        _ = append;
    }
    pub fn init(self: *Ground, allocator: std.mem.Allocator) void {
        self.tiles = ArrayList(ArrayList(Tile)).init(allocator);

        var th: f16= 50;
        var tw: f16 = 26;

        var start_y: f32 = lyra.start_y ;

        var i: usize = 0;

        while (start_y < lyra.game_height + th * 0.5) {
            var start_x: f32 = lyra.start_x - 200;
            var scale = start_y / lyra.game_height * lyra.sx;
            var w = tw * scale;
            var h = th * scale;
            self.append_row(allocator) catch |err| {
                std.log.info("Caught error: {s}", .{ err });
            };
            while (start_x < lyra.game_width + w) {
                if (start_x > lyra.start_x - w) {
                    var color = get_color();
                    var t = Tile{ .x = start_x, .y = start_y, .w = w, .h = h, .scale = 1, .color = color, .org_color = color };
                    append_tile(self, i, t) catch |err| {
                        std.log.info("Caught error: {s}", .{ err });
                    };
                }
                start_x += w;
            }
            i += 1;
            start_y += h;

        } 
    }
    pub fn update(self: *Ground) void {
        for (self.tiles.items) |*row, i| {
            _ = i;
            for (row.items) |*t, j| {
                _ = j;
                if (t.color.r > t.org_color.r) {
                    t.color.r -= 2;
                }
                var heal = rl.GetRandomValue(0, 10);
                if (heal > 7) {
                    if (t.color.g < t.org_color.g) {
                        t.color.g += 1;    
                    }
                    else if (t.color.b < t.org_color.b) {
                        t.color.b += 1;
                    }
                }
            }

        }

    }
    pub fn predraw(_: *Ground) void {
        var color = rl.Color{.r = 50, .g = 100, .b = 10, .a = 220};

        rl.DrawRectangle(0, @floatToInt(u16, lyra.start_y), lyra.game_width, lyra.game_height, color);
    }
    pub fn draw(self: *Ground) void {
        for (self.tiles.items) |*row, i| {
            _ = i;
            for (row.items) |*t, j| {
                _ = j;
                var pos = rl.Vector2{.x = t.x, .y = t.y};
                var w: f32 = t.w * t.scale;
                var h: f32 = t.h * t.scale;
                var size = rl.Vector2{ .x = w, .y = h};
                rl.DrawRectangleV(pos, size, t.color);
            }
        }
    }
    pub fn deinit(self: *Ground) void {
        for (self.tiles.items) |*row, i| {
            _ = i;
            row.deinit();
        }
        self.tiles.deinit();

    }

};

