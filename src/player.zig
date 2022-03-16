const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});

const flame = @import("particles/flame.zig");

const print = std.debug.print;

pub const Player = struct{
    flame: flame.Flame,
    position: ray.Vector2,
    hp: f16,
    xp: f16,

    pub fn update(self: *Player) void {
        const x = self.position.x;
        const y = self.position.y;
        self.flame.update(x, y);
    }
    pub fn draw(self: *Player) void {
        self.flame.draw();
    }
    pub fn unload(self: *Player) void {
        self.flame.unload();
    }
};


pub fn new() Player {
    return Player{
        .hp = 100,
        .xp = 100,
        .position = ray.Vector2{.x = 1920 * 0.5, .y = 1080 * 0.5},
        .flame = flame.new()};
}