const std = @import("std");
const Allocator = std.mem.Allocator;
const log = @import("./log.zig");
const rl = @import("raylib/raylib.zig");
const config = @import("config.zig");
const utils = @import("utils.zig");

const Screen = @import("screens/screen.zig").Screen;
const screens = @import("screens.zig");
const ScreenNames = @import("screens.zig").ScreenNames;
const title = @import("screens/title.zig");

const Self = @This();


var allocator: Allocator = undefined;
var windowsInitialized = false;

var current_screen: Screen = undefined;
var current: ScreenNames = ScreenNames.title;
var camera = rl.Camera2D{
    .offset = rl.Vector2{ .x = 0, .y = 0 },
    .target = rl.Vector2{ .x = 0, .y = 0 },
    .rotation = 0,
    .zoom = 1,
};
var target: rl.RenderTexture2D = undefined;

pub fn min(a: f32, b: f32) f32 {
    return if (a < b) a else b;
}

pub fn start(alloc: Allocator) !void {
    // Initialization
    //--------------------------------------------------------------------------------------

    Self.allocator = alloc;

    rl.SetConfigFlags(rl.ConfigFlags.FLAG_WINDOW_RESIZABLE);
    rl.InitWindow(config.screen_width, config.screen_height, "Kasaival");
    rl.SetTargetFPS(60);
    target = rl.LoadRenderTexture(config.screen_width, config.screen_height);

    // Render texture initialization, used to hold the rendering result so we can easily resize it
    rl.SetTextureFilter(target.texture, @enumToInt(rl.TextureFilter.TEXTURE_FILTER_BILINEAR));
    // init audio device
    rl.InitAudioDevice();
    if (screens.screens.get(@tagName(current))) |e| {
        current_screen = e;
        try current_screen.initFn(allocator);
    }
}


fn switch_screen() !void {
    current = screens.next;
    if (screens.screens.get(@tagName(current))) |e| {
        current_screen.deinitFn();

        current_screen = e;
        try current_screen.initFn(Self.allocator);
    }
}
pub fn mainLoop() !void {
    // Get the current window size
    var window_width = @intToFloat(f32, rl.GetScreenWidth());
    var window_height = @intToFloat(f32, rl.GetScreenHeight());

    // Calculate the scaling factor
    const scale = min(window_width / config.screen_width, window_height / config.screen_height);

    // Calculate the scaled screen size
    const width = config.screen_width * scale;
    const height = config.screen_height * scale;

    // Toggle fullscreen mode when F key is pressed
    if (rl.IsKeyPressed(rl.KeyboardKey.KEY_F)) rl.ToggleFullscreen();

    // Update the camera target and zoom
    camera.target.x = config.cx;
    camera.zoom = config.zoom;

    // Update the virtual mouse position
    var mouse = rl.GetMousePosition();
    config.mouse_x = (@floatCast(f32, mouse.x) - (window_width - width) * 0.5) / scale;
    config.mouse_y = (@floatCast(f32, mouse.y) - (window_height - height) * 0.5) / scale;

    // Clamp the mouse position within the screen bounds
    config.mouse_x = utils.clamp(config.mouse_x, 0, config.screen_width);
    config.mouse_y = utils.clamp(config.mouse_y, 0, config.screen_height);

    // If the current screen changes, switch to the new screen
    if (current != screens.next) {
        try switch_screen();
    }

    // Call the update function for the current screen
    try current_screen.updateFn(Self.allocator, rl.GetFrameTime());

    //----------------------------------------------------------------------------------

    // Draw
    //----------------------------------------------------------------------------------

    rl.BeginDrawing();

    // Begin drawing to a render texture
    rl.BeginTextureMode(target);
    rl.ClearBackground(rl.BLACK);

    // Draw the static elements of the current screen
    current_screen.staticDrawFn();

    // Begin 2D mode using the camera
    rl.BeginMode2D(camera);

    // Draw the dynamic elements of the current screen
    current_screen.drawFn();

    rl.EndMode2D();
    rl.EndTextureMode();

    // Draw the render texture to the screen, properly scaled
    const texture_rect = rl.Rectangle{
        .x = 0, .y = 0,
        .width = @intToFloat(f32, target.texture.width),
        .height = @intToFloat(f32, -target.texture.height)
    };
    const screen_rect = rl.Rectangle{
        .x = (window_width - width) * 0.5,
        .y = (window_height - height) * 0.5,
        .width = width,
        .height = height
    };
    rl.DrawTexturePro(target.texture, texture_rect, screen_rect, rl.Vector2{ .x = 0, .y = 0 }, 0.0, rl.WHITE);

    // End drawing
    rl.EndDrawing();

    // Reset the mouse cursor
    rl.SetMouseCursor(rl.MouseCursor.MOUSE_CURSOR_DEFAULT);

    //----------------------------------------------------------------------------------
}


pub fn stop() void {
    current_screen.deinitFn();
    rl.CloseAudioDevice();
    rl.CloseWindow();
}