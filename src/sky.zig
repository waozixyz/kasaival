const std = @import("std");
const rl = @import("raylib/raylib.zig");

const lyra = @import("lyra.zig");

const math = std.math;

pub const Sky = struct{
    pub fn init(_: *Sky) void {
    }
    pub fn update(_: *Sky) void {
    }
    pub fn predraw(_: *Sky) void {
        // draw blue sky

        var color = rl.Color{.r = 30, .g = 10, .b = 150, .a = 200};
        var start_v = rl.Vector2{.x = 0, .y = 0};
        var end_v = rl.Vector2{.x = lyra.screen_width, .y = lyra.start_y};
        rl.DrawRectangleV(start_v, end_v, color);
    }
    pub fn deinit(_: *Sky) void {
    }
};

