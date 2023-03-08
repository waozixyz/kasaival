const std = @import("std");
const rl = @import("raylib/raylib.zig");
const math = std.math;
const log = @import("./log.zig");
const common = @import("./common.zig");

const print = std.debug.print;

fn get_zero_or_none(val: i32) [2:0]u8 {
    if (val < 10) {
        return " 0".*;
    } else {
        return " ".*;
    }
}

const padding: i32 = 12;
const font_size: f32 = 20;
pub const HUD = struct {
    pub fn init(_: *HUD) void {}
    pub fn update(_: *HUD) void {}

    pub fn predraw(_: *HUD) void {
        var day = common.get_day();
        var day_buf: [100]u8 = undefined;
        var day_slice = std.fmt.bufPrintZ(&day_buf, "day {d}", .{day}) catch |err| errblk: {
            log.err("ERROR: {?}", .{err});
            break :errblk "";
        };
        var width: i32 = @intCast(i32, day_slice.len) * @floatToInt(i32, font_size * 0.5);
        rl.DrawText(day_slice, @floatToInt(i32, common.screen_width) - padding * 2 - width, padding, font_size, rl.MAGENTA);
    }

    pub fn deinit(_: *HUD) void {}
};
