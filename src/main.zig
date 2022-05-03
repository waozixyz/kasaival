const std = @import("std");
const rl = @import("raylib");


const print = std.debug.print;


const lyra = @import("lyra.zig");
const game_screen = @import("screens/game.zig");
const title_screen = @import("screens/title.zig");


fn min(a: f16, b: f16) f16 { if (a < b) { return a; } else { return b; } }
fn clamp(val: f16, lower: f16, higher: f16) f16 {
    if (val < lower) { return lower; }
    else if (val > higher) { return higher; }
    else { return val; }
}


const Screen = union(lyra.ScreenNames) {
    game: game_screen.GameScreen,
    title: title_screen.TitleScreen,

};

fn clamp_value(value: rl.struct_Vector2, low: rl.struct_Vector2, max: rl.struct_Vector2) rl.struct_Vector2 {
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
    rl.SetConfigFlags(@enumToInt(rl.ConfigFlags.FLAG_WINDOW_RESIZABLE));
    rl.InitWindow(screenWidth, screenHeight, "Kasaival");
    rl.SetTargetFPS(60);
    
    // Render texture initialization, used to hold the rendering result so we can easily resize it
    var target = rl.LoadRenderTexture(lyra.screen_width, lyra.screen_height);
    rl.SetTextureFilter(target.texture, @enumToInt(rl.TextureFilter.TEXTURE_FILTER_BILINEAR));

    // init audio device
    rl.InitAudioDevice();

    // setup camera
    var camera = rl.Camera2D{
        .offset = rl.Vector2{.x = 0, .y = 0},
        .target = rl.Vector2{.x = 0, .y = 0},
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
    while (!rl.WindowShouldClose()) {
        // Update
        //----------------------------------------------------------------------------------
        // calculate scale for window scaling
        var screen_width = @intToFloat(f16, rl.GetScreenWidth());
        var screen_height = @intToFloat(f16, rl.GetScreenHeight());
        const scale = min(screen_width / lyra.screen_width, screen_height / lyra.screen_height);
        // quit on escape key
        // if (rl.IsKeyPressed(rl.KEY_F)) rl.ToggleFullscreen();
        // update camera
        camera.target = rl.Vector2{.x = lyra.cx, .y = 0};
        camera.zoom = lyra.zoom;
        // update virtual mouse
        var mouse = rl.GetMousePosition();
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
        rl.BeginDrawing();
        rl.ClearBackground(rl.BLACK);

        rl.BeginTextureMode(target);
        rl.ClearBackground(rl.BLACK);

        switch (current) {
            Screen.title => { current.title.predraw(); },
            Screen.game => { current.game.predraw(); },
        }
        rl.BeginMode2D(camera);
        switch (current) {
            Screen.title => { current.title.draw(); },
            Screen.game => { current.game.draw(); },
        }
        rl.EndMode2D();
        rl.EndTextureMode();
        // Draw RenderTexture2D to window, properly scaled
        const texture_rect = rl.Rectangle{.x = 0, .y = 0, .width = @intToFloat(f16, target.texture.width), .height = @intToFloat(f16, -target.texture.height)};
        const screen_rect = rl.Rectangle{.x = (@intToFloat(f16, rl.GetScreenWidth()) - lyra.screen_width * scale) * 0.5, .y = (@intToFloat(f16, rl.GetScreenHeight()) - lyra.screen_height * scale) * 0.5, .width = lyra.screen_width * scale, .height = lyra.screen_height * scale};
        rl.DrawTexturePro(target.texture, texture_rect, screen_rect, rl.Vector2{.x = 0, .y = 0}, 0.0, rl.WHITE);
       
        rl.EndDrawing();
      
        // reset cursor image
        rl.SetMouseCursor(@enumToInt(rl.MouseCursor.MOUSE_CURSOR_DEFAULT));
        //----------------------------------------------------------------------------------
    }
    // De-Initialization
    //--------------------------------------------------------------------------------------
    switch (current) {
        Screen.title => { current.title.unload(); },
        Screen.game => { current.game.unload(); },
    }
    rl.CloseAudioDevice();
    rl.CloseWindow();
    //--------------------------------------------------------------------------------------

}
