const std = @import("std");
const rl = @import("../raylib/raylib.zig");
const lyra = @import("../lyra.zig");
const Screen = @import("screen.zig").Screen;
const ScreenNames = @import("../screens.zig").ScreenNames;
const screens = @import("../screens.zig");

const print = std.debug.print;

var fade_out: bool = false;
var black: u8 = 255;
var alpha: u8 = 255;
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
        fade_out = true;
    }
    if (black > 5) {
        black -= 5;
    }
    if (fade_out) {
        if (alpha > 10) {
            alpha -= 10;
        } else {
            screens.next = ScreenNames.arcade;
        }
    }
}

fn predraw() void {
    var start = rl.Vector2{.x = 0, .y = 0 };
    var end = rl.Vector2{.x = lyra.screen_width, .y = lyra.screen_height};
    
    var color = rl.WHITE;
    color.a = alpha;
    rl.DrawTextureEx(texture, start, 0, 1, color);    
    
    color = rl.MAROON;
    color.a = alpha;
    rl.DrawText("KASAIVAL", 200, 90, 80, color);
    rl.DrawText("an out of control flame trying to survive", 100, 255, 30, color);

    color = rl.BEIGE;
    color.a = alpha;
    rl.DrawText("touch anywhere to start burning", 140, 555, 30, color);
    
    color = rl.BLACK;
    color.a = black;
    rl.DrawRectangleV(start, end, color);
}

fn deinit() void {
    rl.UnloadTexture(texture);
}

