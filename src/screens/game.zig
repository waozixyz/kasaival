const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});

const lyra = @import("../lyra.zig");
const player = @import("../player.zig");
const ground = @import("../ground.zig");

const print = std.debug.print;

pub const GameScreen = struct{
    player: player.Player,
    ground: ground.Ground,
    pub fn load(self: *GameScreen) void {
        self.ground.load();
        self.player.load();

    }
    pub fn update(self: *GameScreen) void {
        self.ground.update();
        self.player.update();

    }
    pub fn draw(self: *GameScreen) void {
        ray.ClearBackground(ray.BLACK);
        self.ground.draw();
        self.player.draw();
    }
    pub fn unload(self: *GameScreen) void {
        self.ground.unload();
        self.player.unload();

    }
};


pub fn new() GameScreen {
    return GameScreen{
        .player = player.new(),
        .ground = ground.new()
        };
}