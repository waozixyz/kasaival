const std = @import("std");
const rl = @import("raylib/raylib.zig");
const lyra = @import("lyra.zig");
const math = std.math;
const log = @import("./log.zig");

pub const HUD = struct{
    pub fn init(_: *HUD) void {

    }
    pub fn update(_: *HUD) void {
    }

    pub fn predraw(_: *HUD) void {
        const day = @floatToInt(i32, lyra.time);
        var buf: [100]u8 = undefined;
        var buf_slice: [:0]u8 = std.fmt.bufPrintZ(&buf, "{d}", .{day}) catch |err| errblk: {
            log.err("ERROR: {?}", .{err});
            break :errblk "";
        };

        rl.DrawText(buf_slice, 20, 20, 40, rl.LIGHTGRAY);

      
    }

    pub fn deinit(_: *HUD) void {
    }
};

