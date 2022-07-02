const std = @import("std");
const rl = @import("raylib/raylib.zig");
const lyra = @import("lyra.zig");
const utils = @import("utils.zig");

const print = std.debug.print;
const math = std.math;
const ArrayList = std.ArrayList;

pub const TerrainMedium = enum { grass, desert, water };

pub const Terrain = struct {
    start_x: f32,
    end_x: f32,
    medium: TerrainMedium,
};

const Tile = struct {
    pos: rl.Vector2,
    size: rl.Vector2,
    v1: rl.Vector2,
    v2: rl.Vector2,
    v3: rl.Vector2,
    burnTimer: f32 = 0,
    color: rl.Color,
    org_color: rl.Color,
};

fn rand_u8(min: f16, max: f16) u8 {
    var rtn: f16 = @intToFloat(f16, rl.GetRandomValue(@floatToInt(i32, min), @floatToInt(i32, max)));
    rtn = utils.clamp(rtn , 0, 255);
    return @floatToInt(u8, rtn);
}

fn get_color(col: f16, x: f16, y: f16) rl.Color {
    var add_b: f16 = 0;
    var sub_g: f16 = 0;
    _ = y;
    _ = x;
    var max: f16 = 50;
    if (col < max) {
        var s: f16 = (col / max) * 200;
        add_b = 200 - s;
        max = 30;
        if ( col < max ) {
            var a: f16 = (col / max) * 100;
            sub_g = 100 - a;
        }
    }
    var r = rand_u8(16, 60);
    var g = rand_u8(120 - sub_g, 200 - sub_g);
    var b = rand_u8(add_b + 10, add_b + 50);

    var a = rand_u8(120, 200);
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
    pub fn init(self: *Ground, allocator: std.mem.Allocator) !void {
        self.tiles = ArrayList(ArrayList(Tile)).init(allocator);

        var th: f16 = 33;
        var tw: f16 = 32;
        var scale = lyra.start_y / lyra.game_height * lyra.sx;

        var start_y: f16 = lyra.start_y + th * scale ;

        var row: usize = 0;

        while (start_y < lyra.game_height + th ) {
            var start_x: f16 = lyra.start_x - 200;
            scale = start_y / lyra.game_height * lyra.sx;

            var w: f16 = tw * scale;
            var h: f16 = th * scale;
            self.append_row(allocator) catch |err| {
                std.log.info("Caught error: {s}", .{ err });
            };
            var col: f16 = 0;
            while (start_x < lyra.game_width + w) {
                if (start_x > lyra.start_x - w) {
                    col += 1;

                    var color = get_color(col, start_x, start_y);

                    var x = start_x;
                    var y = start_y;
                    var pos = rl.Vector2{.x = x, .y = y};
                    var size = rl.Vector2{.x = w, .y = h};
                    var v1 = rl.Vector2{ .x = x - w, .y = y};
                    var v2 = rl.Vector2{ .x = x + w, .y = y};
                    var v3 = rl.Vector2{ .x = x, .y = y - h};

                    var t = Tile{.pos = pos, .size = size, .v1 = v1, .v2 = v2, .v3 = v3, .color = color, .org_color = color };
                    try append_tile(self, row, t);


                    v1 = rl.Vector2{ .x = x, .y = y};
                    v2 = rl.Vector2{ .x = x + w, .y = y - h};
                    v3 = rl.Vector2{ .x = x - w , .y = y - h};
                    t = Tile{.pos = pos, .size = size, .v1 = v1, .v2 = v2, .v3 = v3, .color = color, .org_color = color };
                    try append_tile(self, row, t);

                }
                start_x += w;
            }
            row += 1;
            start_y += h;

        } 
    }
    pub fn update(self: *Ground, dt: f32) void {
        for (self.tiles.items) |*row, i| {
            _ = i;
            for (row.items) |*t, j| {
                _ = j;

                if (t.burnTimer > 0) {
                    if (t.color.r < 200) {
                        t.color.r += 20;
                    }
                    if (t.color.g > 100) {
                        t.color.g -= 10;
                    }
                    if (t.color.b > 4) {
                        t.color.b -= 4;
                    }
                    t.burnTimer -= 20 * dt;
                }
                else {
                    var heal = rl.GetRandomValue(0, 10);
                    if (heal > 7) {
                        if (t.color.r > t.org_color.r) {
                            t.color.r -= 2;
                        } else if (t.color.g < t.org_color.g) {
                            t.color.g += 1;    
                        } else if (t.color.b < t.org_color.b) {
                            t.color.b += 1;
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
    pub fn draw(self: *Ground) void {
        for (self.tiles.items) |*row, i| {
            _ = i;
            for (row.items) |*t, j| {
                _ = j;
                
                rl.DrawTriangle(t.v1, t.v2, t.v3, t.color);
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

