const std = @import("std");
const Allocator = std.mem.Allocator;
const fmt = std.fmt;
const log = @import("log.zig");
const game = @import("game.zig");
const raylib = @import("raylib/raylib.zig");
const ZecsiAllocator = @import("allocator.zig").ZecsiAllocator;

var zalloc = ZecsiAllocator{};

pub fn main() anyerror!void {
    const allocator = zalloc.allocator();
    defer {
        log.info("free memory...", .{});
        if (zalloc.deinit()) {
            log.err("memory leaks detected!", .{});
        }
    }

    const exePath = try std.fs.selfExePathAlloc(allocator);
    defer allocator.free(exePath);
    
    log.info("starting game...", .{});
    try game.start(allocator);

    defer {
        log.info("stopping game...", .{});
        game.stop();
    }
    
    while (!raylib.WindowShouldClose()) {
        try game.mainLoop();
    }
}
