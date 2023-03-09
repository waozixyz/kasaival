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
var screenWidth: i32 = 100;
var screenHeight: i32 = 100;

var current_screen: Screen = undefined;
var current: ScreenNames = ScreenNames.title;

var camera = rl.Camera2D{ .offset = rl.Vector2{ .x = 0, .y = 0 }, .target = rl.Vector2{ .x = 0, .y = 0 }, .rotation = 0, .zoom = 1 };

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
    var window_width = @intToFloat(f32, rl.GetScreenWidth());
    var window_height = @intToFloat(f32, rl.GetScreenHeight());
    const scale = min(window_width / config.screen_width, window_height / config.screen_height);
    // fullscreen on f press
    if (rl.IsKeyPressed(rl.KeyboardKey.KEY_F)) rl.ToggleFullscreen();
    // update camera
    camera.target = rl.Vector2{ .x = config.cx, .y = 0 };
    camera.zoom = config.zoom;
    // update virtual mouse
    var mouse = rl.GetMousePosition();
    config.mouse_x = (@floatCast(f32, mouse.x) - (window_width - (config.screen_width * scale)) * 0.5) / scale;
    config.mouse_y = (@floatCast(f32, mouse.y) - (window_height - (config.screen_height * scale)) * 0.5) / scale;

    config.mouse_x = utils.clamp(config.mouse_x, 0, config.screen_width);
    config.mouse_y = utils.clamp(config.mouse_y, 0, config.screen_height);
    // if game screen changes, update to the new screen

    if (current != screens.next) {
        try switch_screen();
    }

    try current_screen.updateFn(Self.allocator, rl.GetFrameTime());

    //----------------------------------------------------------------------------------

    // Draw
    //----------------------------------------------------------------------------------
    rl.BeginDrawing();
    rl.ClearBackground(rl.BLACK);
    rl.BeginTextureMode(target);
    rl.ClearBackground(rl.BLACK);
    current_screen.staticDrawFn();
    rl.BeginMode2D(camera);
    current_screen.drawFn();

    rl.EndMode2D();
    rl.EndTextureMode();
     // Draw RenderTexture2D to window, properly scaled
    const texture_rect = rl.Rectangle{ .x = 0, .y = 0, .width = @intToFloat(f32, target.texture.width), .height = @intToFloat(f32, -target.texture.height) };
    const screen_rect = rl.Rectangle{ .x = (@intToFloat(f32, rl.GetScreenWidth()) - config.screen_width * scale) * 0.5, .y = (window_height - config.screen_height * scale) * 0.5, .width = config.screen_width * scale, .height = config.screen_height * scale };
    rl.DrawTexturePro(target.texture, texture_rect, screen_rect, rl.Vector2{ .x = 0, .y = 0 }, 0.0, rl.WHITE);

    rl.EndDrawing();

    // reset cursor image
    rl.SetMouseCursor(rl.MouseCursor.MOUSE_CURSOR_DEFAULT);
    //----------------------------------------------------------------------------------
}


pub fn stop() void {
    current_screen.deinitFn();
    rl.CloseAudioDevice();
    rl.CloseWindow();

}