const std = @import("std");

pub const Screen = struct {
    initFn: *const fn (std.mem.Allocator) anyerror!void = init,
    deinitFn: *const fn () void = deinit,
    updateFn: *const fn (std.mem.Allocator, f32) anyerror!void = update,
    drawFn: *const fn () void = draw,
    predrawFn: *const fn () void = predraw,
};

fn init(allocator: std.mem.Allocator) !void {
    _ = allocator;
}

fn update(allocator: std.mem.Allocator, dt: f32) !void {
    _ = allocator;
    _ = dt;
}

fn deinit() void {}
fn draw() void {}
fn predraw() void {}
