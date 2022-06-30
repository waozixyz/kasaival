const std = @import("std");
const log = @import("./log.zig");
const ZecsiAllocator = @import("allocator.zig").ZecsiAllocator;
const rl = @import("raylib/raylib.zig");
const lyra = @import("lyra.zig");
const Screen = @import("screens/screen.zig").Screen;
const screens = @import("screens.zig");
const ScreenNames = @import("screens.zig").ScreenNames;

var current_screen: Screen = undefined;
var current: ScreenNames = ScreenNames.title;

var zalloc = ZecsiAllocator{};

var camera = rl.Camera2D{
    .offset = rl.Vector2{.x = 0, .y = 0},
    .target = rl.Vector2{.x = 0, .y = 0},
    .rotation = 0,
    .zoom = 1
};

var target: rl.RenderTexture2D = undefined;

pub fn min(a: f16, b: f16) f16 { if (a < b) { return a; } else { return b; } }




pub fn start() !void {
    // Initialization
    //--------------------------------------------------------------------------------------

    rl.SetConfigFlags(rl.ConfigFlags.FLAG_WINDOW_RESIZABLE);
    rl.InitWindow(lyra.screen_width, lyra.screen_height, "Kasaival");
    rl.SetTargetFPS(60);
    target = rl.LoadRenderTexture(lyra.screen_width, lyra.screen_height);

     // Render texture initialization, used to hold the rendering result so we can easily resize it
    rl.SetTextureFilter(target.texture, @enumToInt(rl.TextureFilter.TEXTURE_FILTER_BILINEAR));

    // init audio device
    rl.InitAudioDevice();
    
    if (screens.screens.get(@tagName(current))) |e| {
        current_screen = e;
        try current_screen.initFn(zalloc.allocator());
    }
}

fn switch_screen() !void {
    current = screens.next;

    if (screens.screens.get(@tagName(current))) |e| {
        current_screen.deinitFn();

        current_screen = e;
        try current_screen.initFn(zalloc.allocator());
    }

}

pub fn stop() void {
    current_screen.deinitFn();

    rl.CloseAudioDevice();
    rl.CloseWindow();
    if (zalloc.deinit()) {
        log.err("memory leaks detected!", .{});
    }
}

pub fn loop(dt: f32) void {
    var window_width = @intToFloat(f16, rl.GetScreenWidth());
    var window_height = @intToFloat(f16, rl.GetScreenHeight());
    const scale = min(window_width / lyra.screen_width, window_height / lyra.screen_height);
    // fullscreen on f press
    if (rl.IsKeyPressed(rl.KeyboardKey.KEY_F)) rl.ToggleFullscreen();
    // update camera
    camera.target = rl.Vector2{.x = lyra.cx, .y = 0};
    camera.zoom = lyra.zoom;
    // update virtual mouse
    var mouse = rl.GetMousePosition();
    lyra.mouse_x = (@floatCast(f16, mouse.x) - (window_width - (lyra.screen_width * scale)) * 0.5) / scale;
    lyra.mouse_y = (@floatCast(f16, mouse.y) - (window_height - (lyra.screen_height * scale)) * 0.5) / scale;
        
    lyra.mouse_x = lyra.clamp(lyra.mouse_x, 0, lyra.screen_width);
    lyra.mouse_y = lyra.clamp(lyra.mouse_y, 0, lyra.screen_height);
    // if game screen changes, update to the new screen
    
    if (current != screens.next) {
        switch_screen() catch |err| log.err("ERROR: {?}", .{err});
    }

    current_screen.updateFn(zalloc.allocator(), dt) catch |err| log.err("ERROR: {?}", .{err});
    
    //----------------------------------------------------------------------------------

    // Draw
    //----------------------------------------------------------------------------------
    rl.BeginDrawing();
    rl.ClearBackground(rl.BLACK);   

    rl.BeginTextureMode(target);
    rl.ClearBackground(rl.BLACK);

    current_screen.predrawFn();

    rl.BeginMode2D(camera);
    current_screen.drawFn();

    rl.EndMode2D();
    rl.EndTextureMode();
    // Draw RenderTexture2D to window, properly scaled
    const texture_rect = rl.Rectangle{.x = 0, .y = 0, .width = @intToFloat(f16, target.texture.width), .height = @intToFloat(f16, -target.texture.height)};
    const screen_rect = rl.Rectangle{.x = (@intToFloat(f16, rl.GetScreenWidth()) - lyra.screen_width * scale) * 0.5, .y = (@intToFloat(f16, rl.GetScreenHeight()) - lyra.screen_height * scale) * 0.5, .width = lyra.screen_width * scale, .height = lyra.screen_height * scale};
    rl.DrawTexturePro(target.texture, texture_rect, screen_rect, rl.Vector2{.x = 0, .y = 0}, 0.0, rl.WHITE);
    
    rl.EndDrawing();
      
    // reset cursor image
    rl.SetMouseCursor(rl.MouseCursor.MOUSE_CURSOR_DEFAULT);
    //----------------------------------------------------------------------------------
}
