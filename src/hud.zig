const std = @import("std");
const rl = @import("raylib/raylib.zig");
const math = std.math;
const log = @import("./log.zig");
const lyra = @import("./lyra.zig");

var buf_slice: [:0]u8 = undefined;
const print = std.debug.print;


fn get_zero_or_none(val: i32) [2:0]u8 {
    if (val < 10) {
        return " 0".*;
    }
    else {
        return " ".*;
    }
}
pub const HUD = struct{
    pub fn init(_: *HUD) void {

    }
    pub fn update(_: *HUD) void {
    }

    pub fn predraw(_: *HUD) void {
        var elapsed = @floatToInt(u32, lyra.elapsed_time);
        var min = @mod(elapsed, 60);
        var hour = @divFloor(@mod(elapsed, 24 * 60), 60);
        var day = @divFloor(@mod(elapsed, 24 * 60 * 30), 60 * 24);
        var buf: [100]u8 = undefined;

        buf_slice = std.fmt.bufPrintZ(&buf, "day {d}, {d:0>2}:{d:0>2}", .{day, hour, min}) catch |err| errblk: {
            log.err("ERROR: {?}", .{err});
            break :errblk "";
        };

        rl.DrawText(buf_slice, 20, 20, 40, rl.LIGHTGRAY);

      
    }

    pub fn deinit(_: *HUD) void {
    }
};

