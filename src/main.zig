const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});

const print = std.debug.print;


const lyra = @import("lyra.zig");

const title_screen = @import("screens/title.zig");
const game_screen = @import("screens/game.zig");

const gameWidth : f16 = 1920;
const gameHeight: f16 = 1080;

fn min(a: f16, b: f16) f16 { if (a < b) { return a; } else { return b; } }



const Screen = union(lyra.ScreenNames) {
    title: title_screen.TitleScreen,
    game: game_screen.GameScreen,
};
pub fn main() void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 800;
    const screenHeight = 450;
    ray.SetConfigFlags(ray.FLAG_WINDOW_RESIZABLE);
    ray.InitWindow(screenWidth, screenHeight, "Kasaival");
    ray.SetTargetFPS(60);
    
    // Render texture initialization, used to hold the rendering result so we can easily resize it
    var target = ray.LoadRenderTexture(gameWidth, gameHeight);
    ray.SetTextureFilter(target.texture, ray.TEXTURE_FILTER_BILINEAR);

    // init audio device
    ray.InitAudioDevice();


    var current = Screen{ .title = title_screen.new() };
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!ray.WindowShouldClose()) {
        // Update
        //----------------------------------------------------------------------------------
        const scale = min(@intToFloat(f16, ray.GetScreenWidth()) / gameWidth, @intToFloat(f16, ray.GetScreenHeight()) / gameHeight);

        if (ray.IsKeyPressed(ray.KEY_F)) ray.ToggleFullscreen();
        if (lyra.next != current) {       
            switch (current) {
                Screen.title => { current.title.unload(); },
                Screen.game => { current.game.unload(); },
            }
            switch (lyra.next) {
                lyra.ScreenNames.title => { current = Screen{ .title = title_screen.new() }; },
                lyra.ScreenNames.game => { current = Screen{ .game = game_screen.new() }; },
            }
        }

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
        switch (current) {
            Screen.title => { current.title.draw(); },
            Screen.game => { current.game.draw(); },
        }
        ray.EndTextureMode();

        // Draw RenderTexture2D to window, properly scaled
        const texture_rect = ray.Rectangle{.x = 0, .y = 0, .width = @intToFloat(f16, target.texture.width), .height = @intToFloat(f16, -target.texture.height)};
        const screen_rect = ray.Rectangle{.x = (@intToFloat(f16, ray.GetScreenWidth()) - gameWidth * scale) * 0.5, .y = (@intToFloat(f16, ray.GetScreenHeight()) - gameHeight * scale) * 0.5, .width = gameWidth * scale, .height = gameHeight * scale};
        ray.DrawTexturePro(target.texture, texture_rect, screen_rect, ray.Vector2{.x = 0, .y = 0}, 0.0, ray.WHITE);
       
        ray.EndDrawing();
        //----------------------------------------------------------------------------------
    }
    // De-Initialization
    //--------------------------------------------------------------------------------------
    switch (current) {
        Screen.title => { current.title.unload(); },
        Screen.game => { current.game.unload(); },
    }
    ray.CloseWindow();
    //--------------------------------------------------------------------------------------

}
