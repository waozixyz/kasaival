#include <raylib.h>
#include "screens.h"
#include "state.h"
#include "config.h"
#include <stdio.h>
#include <time.h>


#define SCREEN_WIDTH 800
#define SCREEN_HEIGHT 450
#define WINDOW_TITLE "Kasaival"

float max(float a, float b) {
    return a > b ? a : b;
}

float min(float a, float b) {
    return a < b ? a : b;
}

Vector2 clamp_value(Vector2 value, Vector2 min, Vector2 max) {
    Vector2 result = value;
    result.x = result.x > max.x ? max.x : result.x;
    result.x = result.x < min.x ? min.x : result.x;
    result.y = result.y > max.y ? max.y : result.y;
    result.y = result.y < min.y ? min.y : result.y;
    return result;
}

void CustomLog(int msgType, const char *text, va_list args)
{
    char timeStr[64] = { 0 };
    time_t now = time(NULL);
    struct tm *tm_info = localtime(&now);

    strftime(timeStr, sizeof(timeStr), "%Y-%m-%d %H:%M:%S", tm_info);
    printf("[%s] ", timeStr);

    switch (msgType)
    {
        case LOG_INFO: printf("[INFO] : "); break;
        case LOG_ERROR: printf("[ERROR]: "); break;
        case LOG_WARNING: printf("[WARN] : "); break;
        case LOG_DEBUG: printf("[DEBUG]: "); break;
        default: break;
    }

    vprintf(text, args);
    printf("\n");
}
int main(void) {
    SetConfigFlags(FLAG_WINDOW_RESIZABLE | FLAG_VSYNC_HINT);
    SetTraceLogCallback(CustomLog);

    InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, WINDOW_TITLE);
    
    RenderTexture2D target = LoadRenderTexture(GAME_WIDTH, GAME_HEIGHT);
    InitAudioDevice();
    
    State* game_state = create_state();
    if (!game_state) {
        TraceLog(LOG_ERROR, "Failed to create game state");
        CloseAudioDevice();
        CloseWindow();
        return -1;
    }

    TraceLog(LOG_INFO, "BEFORE SET SCREEN");

    set_screen(game_state, &GameScreen, sizeof(Game));
    TraceLog(LOG_INFO, "The boolean MAIN FILE is: %s", game_state->exit ? "true" : "false");

    Camera2D camera = {0};
    int key_timeout = 0;
    SetTargetFPS(60);
    
    while (!WindowShouldClose()) {
        float scale = min((float)GetScreenWidth() / GAME_WIDTH, (float)GetScreenHeight() / GAME_HEIGHT);
        
        if (key_timeout > 0) {
            key_timeout--;
        }
        
        if (IsKeyDown(KEY_F)) {
            if (key_timeout == 0) {
                ToggleFullscreen();
            }
            key_timeout = 2;
        }

        game_state->screen_vtable->update(game_state->current_screen, game_state);
        
        camera.target = (Vector2){ game_state->cx, 0 };
        camera.zoom = 1;
        
        Vector2 mouse = GetMousePosition();
        Vector2 virtual_mouse = {0};
        virtual_mouse.x = (mouse.x - (GetScreenWidth() - (GAME_WIDTH * scale)) * 0.5f) / scale;
        virtual_mouse.y = (mouse.y - (GetScreenHeight() - (GAME_HEIGHT * scale)) * 0.5f) / scale;
        game_state->mouse = clamp_value(virtual_mouse, (Vector2){0, 0}, (Vector2){GAME_WIDTH, GAME_HEIGHT});
        
        BeginDrawing();
        {
            ClearBackground(BLACK);
            BeginTextureMode(target);
            {
                BeginMode2D(camera);
                {
                    ClearBackground(BLACK);
                    game_state->screen_vtable->draw(game_state->current_screen, game_state);
                }
                EndMode2D();
            }
            EndTextureMode();
            
            DrawTexturePro(target.texture,
                           (Rectangle){ 0, 0, (float)target.texture.width, (float)-target.texture.height },
                           (Rectangle){ (GetScreenWidth() - GAME_WIDTH * scale) * 0.5f,
                                        (GetScreenHeight() - (GAME_HEIGHT * scale)) * 0.5f,
                                        GAME_WIDTH * scale, GAME_HEIGHT * scale },
                           (Vector2){ 0, 0 }, 0.0f, WHITE);
        }
        EndDrawing();
        
        SetMouseCursor(MOUSE_CURSOR_DEFAULT);
    }
    
    UnloadRenderTexture(target);
    game_state->screen_vtable->unload(game_state->current_screen);
    free_state(game_state);
    CloseAudioDevice();
    CloseWindow();
    
    return 0;
}
