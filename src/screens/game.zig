const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});

const lyra = @import("../lyra.zig");
const player = @import("../player.zig");

const print = std.debug.print;

pub const GameScreen = struct{
    player: player.Player,

    pub fn update(self: *GameScreen) void {
        self.player.update();
    }
    pub fn draw(self: *GameScreen) void {
        ray.ClearBackground(ray.BLACK);
        self.player.draw();
    }
    pub fn unload(self: *GameScreen) void {
        self.player.unload();
    }
};


pub fn new() GameScreen {
    return GameScreen{.player = player.new()};
}