const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});

const lyra = @import("../lyra.zig");

const print = std.debug.print;

pub const TitleScreen = struct{
    texture: ray.struct_Texture,

    pub fn update(_: *TitleScreen) void {
        if (ray.IsMouseButtonPressed(ray.MOUSE_LEFT_BUTTON) or ray.GetKeyPressed() > 0) {
            lyra.next = lyra.Screen.game;
        }
    }
    pub fn draw(self: *TitleScreen) void {
        ray.ClearBackground(ray.BLACK);
        ray.DrawTexture(self.texture, 0, 0, ray.WHITE);
        ray.DrawText("KASAIVAL", 480, 160, 200, ray.MAROON);
        ray.DrawText("an out of control flame trying to survive", 350, 640, 60, ray.MAROON);
        ray.DrawText("touch anywhere to start burning", 480, 1000, 60, ray.BEIGE);
    }
    pub fn unload(self: *TitleScreen) void {
        ray.UnloadTexture(self.texture);
    }
};


pub fn new() TitleScreen {
    return TitleScreen{.texture = ray.LoadTexture("assets/menu.jpg") };
}