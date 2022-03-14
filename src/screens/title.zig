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
    }
    pub fn draw(self: *TitleScreen) void {
        ray.DrawTexture(self.texture, 0, 0, ray.WHITE);
    }
    pub fn unload(self: *TitleScreen) void {
        ray.UnloadTexture(self.texture);
    }
};


pub fn new() TitleScreen {
    return TitleScreen{.value = 1, .texture = ray.LoadTexture("assets/menu.jpg") };
}