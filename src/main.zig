const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});

const title_screen = @import("screens/title.zig");

pub fn main() void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 800;
    const screenHeight = 450;
    ray.SetConfigFlags(ray.FLAG_WINDOW_RESIZABLE);
    ray.InitWindow(screenWidth, screenHeight, "Kasaival");
    ray.SetTargetFPS(60);

    var screen = title_screen.new();
    screen.load();
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!ray.WindowShouldClose()) {
        // Update
        //----------------------------------------------------------------------------------
        if (ray.IsKeyPressed(ray.KEY_F)) ray.ToggleFullscreen();
        screen.update();
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        ray.BeginDrawing();
        ray.ClearBackground(ray.RAYWHITE);
        screen.draw();
        ray.EndDrawing();
        //----------------------------------------------------------------------------------
    }
    // De-Initialization
    //--------------------------------------------------------------------------------------
    screen.unload();
    ray.CloseWindow();
    //--------------------------------------------------------------------------------------

}
