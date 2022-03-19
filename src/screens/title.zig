const std = @import("std");
const rl = @import("raylib");


const lyra = @import("../lyra.zig");

const print = std.debug.print;

pub const TitleScreen = struct{
    texture: rl.Texture,
    pub fn load(_: *TitleScreen) void {
    }
    pub fn update(_: *TitleScreen) void {
        if (rl.IsMouseButtonPressed(rl.MouseButton.MOUSE_LEFT_BUTTON) or rl.GetKeyPressed() > 0) {
            lyra.next = lyra.ScreenNames.game;
        }
    }
    pub fn predraw(self: *TitleScreen) void {
        rl.ClearBackground(rl.BLACK);
        rl.DrawTexture(self.texture, 0, 0, rl.WHITE);
        rl.DrawText("KASAIVAL", 480, 160, 200, rl.MAROON);
        rl.DrawText("an out of control flame trying to survive", 350, 640, 60, rl.MAROON);
        rl.DrawText("touch anywhere to start burning", 480, 1000, 60, rl.BEIGE);
    }
    pub fn draw(_: *TitleScreen) void {}
    pub fn unload(self: *TitleScreen) void {
        rl.UnloadTexture(self.texture);
    }
};


pub fn new() TitleScreen {
    return TitleScreen{.texture = rl.LoadTexture("assets/menu.jpg") };
}
