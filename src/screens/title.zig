const std = @import("std");
const rl = @import("../raylib/raylib.zig");
const lyra = @import("../lyra.zig");
const Screen = @import("screen.zig").Screen;
const ScreenNames = @import("../screens.zig").ScreenNames;
const screens = @import("../screens.zig");

const print = std.debug.print;

var texture: rl.Texture2D = undefined;

pub const screen = Screen{
    .initFn = init,
    .updateFn = update,
    .predrawFn = predraw,
    .deinitFn = deinit,
};


fn init(_: std.mem.Allocator) !void {
    texture = rl.LoadTexture("assets/menu.png");
}

fn update(_: std.mem.Allocator, _: f32) !void {
    if (rl.IsMouseButtonPressed(rl.MouseButton.MOUSE_BUTTON_LEFT) or rl.GetKeyPressed() > 0) {
        screens.next = ScreenNames.arcade;
    }
}

fn predraw() void {
    rl.DrawTextureEx(texture, rl.Vector2{.x = 0, .y = 0 }, 0, 11, rl.WHITE);    
        
    rl.DrawText("KASAIVAL", 200, 90, 80, rl.MAROON);
    rl.DrawText("an out of control flame trying to survive", 100, 255, 30, rl.MAROON);
    rl.DrawText("touch anywhere to start burning", 140, 555, 30, rl.BEIGE);
}

fn deinit() void {
    rl.UnloadTexture(texture);
}

