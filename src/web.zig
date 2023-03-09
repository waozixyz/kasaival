const std = @import("std");
const fmt = std.fmt;
const emsdk = @cImport({
    @cDefine("__EMSCRIPTEN__", "1");
    @cInclude("emscripten/emscripten.h");
});
const log = @import("log.zig");
const game = @import("game.zig");
const ZecsiAllocator = @import("allocator.zig").ZecsiAllocator;
const raylib = @cImport({
    @cInclude("raylib.h");
});

////special entry point for Emscripten build, called from src/marshall/emscripten_entry.c
export fn emsc_main() callconv(.C) c_int {
    return safeMain() catch |err| {
        log.err("ERROR: {?}", .{err});
        return 1;
    };
}

export fn emsc_set_window_size(width: c_int, height: c_int) callconv(.C) void {
    raylib.SetWindowSize(@intCast(i32, width), @intCast(i32, height));
}

fn safeMain() !c_int {
    var zalloc = ZecsiAllocator{};
    const allocator = zalloc.allocator();
    try log.infoAlloc(allocator, "starting da game  ...", .{});
    
    try game.start(allocator);
    defer game.stop();


    emsdk.emscripten_set_main_loop(gameLoop, 0, 1);
    log.info("after emscripten_set_main_loop", .{});
    
    log.info("CLEANUP", .{});
    if (zalloc.deinit()) {
        log.err("memory leaks detected!", .{});
        return 1;
    }
    
    return 0;
}

export fn gameLoop() callconv(.C) void {
    game.mainLoop() catch unreachable;
}
