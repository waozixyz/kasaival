const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});

const print = std.debug.print;

pub const GameScreen = struct{
    value: i32,
    pub fn load(_: *GameScreen) void {
    }
    pub fn update(_: *GameScreen) void {
        if (ray.IsMouseButtonPressed(ray.MOUSE_LEFT_BUTTON) or ray.GetKeyPressed() > 0) {

        }
    }
    pub fn draw(_: *GameScreen) void {
        ray.ClearBackground(ray.BLACK);
        ray.DrawText("aa", 480, 160, 200, ray.MAROON);
        ray.DrawText("an outontrol flame trying to survive", 350, 640, 60, ray.MAROON);
        ray.DrawText("touch anywhere to start burning", 480, 1000, 60, ray.BEIGE);
    }
    pub fn unload(_: *GameScreen) void {
    }
};


pub fn new() GameScreen {
    return GameScreen{.value = 1};
}