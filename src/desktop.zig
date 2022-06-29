const std = @import("std");
const Allocator = std.mem.Allocator;
const fmt = std.fmt;
const log = @import("log.zig");
const game = @import("game.zig");
const raylib = @import("raylib/raylib.zig");

pub fn main() anyerror!void {
    try game.start();
    defer game.stop();

    while (!raylib.WindowShouldClose()) {
        game.loop(raylib.GetFrameTime());
    }
}
