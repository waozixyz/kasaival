const std = @import("std");
const rl = @import("raylib");

const lyra = @import("../lyra.zig");
const player = @import("../player.zig");
const ground = @import("../ground.zig");
const sky = @import("../sky.zig");

const print = std.debug.print;

pub const GameScreen = struct{
    sky: sky.Sky,
    player: player.Player,
    ground: ground.Ground,
    pub fn load(self: *GameScreen) void {
        self.sky.load();
        self.ground.load();
        self.player.load();

    }
    pub fn update(self: *GameScreen) void {
        self.sky.update();
        self.ground.update();
        self.player.update();

    }
    pub fn predraw(self: *GameScreen) void {
        rl.ClearBackground(rl.BLACK);
        self.sky.draw();
    }
    pub fn draw(self: *GameScreen) void {
        self.ground.draw();
        self.player.draw();
    }
    pub fn unload(self: *GameScreen) void {
        self.sky.unload();
        self.ground.unload();
        self.player.unload();

    }
};


pub fn new() GameScreen {
    return GameScreen{
        .sky = sky.new(),
        .ground = ground.new(),
        .player = player.new()
        };
}
