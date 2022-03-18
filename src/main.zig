const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});

const print = std.debug.print;


const lyra = @import("lyra.zig");

const title_screen = @import("screens/title.zig");
const game_screen = @import("screens/game.zig");


fn min(a: f16, b: f16) f16 { if (a < b) { return a; } else { return b; } }
fn clamp(val: f16, lower: f16, higher: f16) f16 {
    if (val < lower) { return lower; }
    else if (val > higher) { return higher; }
    else { return val; }
}


const Screen = union(lyra.ScreenNames) {
    title: title_screen.TitleScreen,
    game: game_screen.GameScreen,
};

fn clamp_value(value: ray.struct_Vector2, low: ray.struct_Vector2, max: ray.struct_Vector2) ray.struct_Vector2 {
    var ret = value;
    _ = low;
    ret.x = if (ret.x > max.x) { max.x; } else { ret.x; };
    return ret;
}

pub fn main() void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 800;
    const screenHeight = 450;
    ray.SetConfigFlags(ray.FLAG_WINDOW_RESIZABLE);
    ray.InitWindow(screenWidth, screenHeight, "Kasaival");
    ray.SetTargetFPS(60);
    
    // Render texture initialization, used to hold the rendering result so we can easily resize it
    var target = ray.LoadRenderTexture(lyra.screen_width, lyra.screen_height);
    ray.SetTextureFilter(target.texture, ray.TEXTURE_FILTER_BILINEAR);

    // init audio device
    ray.InitAudioDevice();

    // setup camera
    var camera = ray.Camera2D{
        .offset = ray.Vector2{.x = 0, .y = 0},
        .target = ray.Vector2{.x = 0, .y = 0},
        .rotation = 0,
        .zoom = 1
    };

    var current = Screen{ .title = title_screen.new() };
    switch (current) {
        Screen.title => { current.title.load(); },
        Screen.game => { current.game.load(); },
    }
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!ray.WindowShouldClose()) {
        // Update
        //----------------------------------------------------------------------------------
        // calculate scale for window scaling
        var screen_width = @intToFloat(f16, ray.GetScreenWidth());
        var screen_height = @intToFloat(f16, ray.GetScreenHeight());
        const scale = min(screen_width / lyra.screen_width, screen_height / lyra.screen_height);
        // quit on escape key
        if (ray.IsKeyPressed(ray.KEY_F)) ray.ToggleFullscreen();
        // update camera
        camera.target = ray.Vector2{.x = lyra.cx, .y = 0};
        camera.zoom = lyra.zoom;
        // update virtual mouse
        var mouse = ray.GetMousePosition();
        lyra.mouse_x = (@floatCast(f16, mouse.x) - (screen_width - (lyra.screen_width * scale)) * 0.5) / scale;
        lyra.mouse_y = (@floatCast(f16, mouse.y) - (screen_height - (lyra.screen_height * scale)) * 0.5) / scale;
        
        lyra.mouse_x = clamp(lyra.mouse_x, 0, lyra.screen_width);
        lyra.mouse_y = clamp(lyra.mouse_y, 0, lyra.screen_height);
        // if game screen changes, update to the new screen
        if (lyra.next != current) {       
            switch (current) {
                Screen.title => { current.title.unload(); },
                Screen.game => { current.game.unload(); },
            }
            switch (lyra.next) {
                lyra.ScreenNames.title => { current = Screen{ .title = title_screen.new() }; },
                lyra.ScreenNames.game => { current = Screen{ .game = game_screen.new() }; },
            }
            switch (current) {
                Screen.title => { current.title.load(); },
                Screen.game => { current.game.load(); },
            }
        }
        // update current game screen
        switch (current) {
            Screen.title => { current.title.update(); },
            Screen.game => { current.game.update(); },
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        ray.BeginDrawing();
        ray.ClearBackground(ray.BLACK);
        ray.BeginTextureMode(target);
        ray.BeginMode2D(camera);
        switch (current) {
            Screen.title => { current.title.draw(); },
            Screen.game => { current.game.draw(); },
        }
        ray.EndMode2D();
        ray.EndTextureMode();
        // Draw RenderTexture2D to window, properly scaled
        const texture_rect = ray.Rectangle{.x = 0, .y = 0, .width = @intToFloat(f16, target.texture.width), .height = @intToFloat(f16, -target.texture.height)};
        const screen_rect = ray.Rectangle{.x = (@intToFloat(f16, ray.GetScreenWidth()) - lyra.screen_width * scale) * 0.5, .y = (@intToFloat(f16, ray.GetScreenHeight()) - lyra.screen_height * scale) * 0.5, .width = lyra.screen_width * scale, .height = lyra.screen_height * scale};
        ray.DrawTexturePro(target.texture, texture_rect, screen_rect, ray.Vector2{.x = 0, .y = 0}, 0.0, ray.WHITE);
       
        ray.EndDrawing();
      
        // reset cursor image
        ray.SetMouseCursor(ray.MOUSE_CURSOR_DEFAULT);
        //----------------------------------------------------------------------------------
    }
    // De-Initialization
    //--------------------------------------------------------------------------------------
    switch (current) {
        Screen.title => { current.title.unload(); },
        Screen.game => { current.game.unload(); },
    }
    ray.CloseAudioDevice();
    ray.CloseWindow();
    //--------------------------------------------------------------------------------------

}
