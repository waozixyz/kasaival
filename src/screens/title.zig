const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});

const print = std.debug.print;

pub const TitleScreen = struct{
    value: i32,
    texture: ray.struct_Texture,
    pub fn load(_: *TitleScreen) void {
    }
    pub fn update(_: *TitleScreen) void {
        if (ray.IsMouseButtonPressed(ray.MOUSE_LEFT_BUTTON) or ray.GetKeyPressed() > 0) {
            print("hi", .{});
        }
    }
    pub fn draw(self: *TitleScreen) void {
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
    return TitleScreen{.value = 1, .texture = ray.LoadTexture("assets/menu.jpg") };
}