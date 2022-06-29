const std = @import("std");

pub const Screen = struct {
    initFn: fn (std.mem.Allocator) anyerror!void = init,
    deinitFn: fn () void = deinit,
    updateFn: fn (std.mem.Allocator, f32) anyerror!void = update,
    drawFn: fn () void = draw,
    predrawFn: fn () void = predraw,

};

fn init(allocator: std.mem.Allocator) !void {
    _ = allocator;
}

fn update(dt: f32) !void {
    _ = dt;
}

fn deinit() void {}
fn draw() void {}
fn predraw() void {}
