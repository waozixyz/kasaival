#include "ui.h"
#include "config.h"
#include <string.h>
#include <stdio.h>

#define EXIT_BUTTON 0
#define PAUSE_BUTTON 1
#define MUSIC_BUTTON 2

static const char* ASSET_PATH = "resources/ui/";
static const char* ASSET_EXT = ".png";
static const char* TOP_LEFT[2][2] = {{"exit"}, {"pause", "resume"}};
static const char* TOP_RIGHT[1][2] = {{"music", "no_music"}};

static const int ICON_W = 128;
static const int ICON_H = 128;
static const int START_ICONS_X = 64;
static const int START_ICONS_Y = 64;
static const float ICON_SCALE = 0.7f;

static void exit_execute(State* game_state) {
    game_state->exit = true;
}

static void pause_execute(State* game_state) {
    game_state->pause = false;
}

static void resume_execute(State* game_state) {
    game_state->pause = true;
}

static void music_execute(State* game_state) {
    game_state->mute = false;
}

static void no_music_execute(State* game_state) {
    game_state->mute = true;
}

static void (*get_fn(const char* btn))(State*) {
    if (strcmp(btn, "exit") == 0) return exit_execute;
    if (strcmp(btn, "pause") == 0) return pause_execute;
    if (strcmp(btn, "resume") == 0) return resume_execute;
    if (strcmp(btn, "music") == 0) return music_execute;
    if (strcmp(btn, "no_music") == 0) return no_music_execute;
    return NULL;
}

static void add_icon(HUD* self, const char** states, int state_count, int x, int y) {
    Icon icon = {0};
    icon.x = x;
    icon.y = y;
    icon.state_count = state_count;

    for (int i = 0; i < state_count; i++) {
        char filename[256];
        snprintf(filename, sizeof(filename), "%s%s%s", ASSET_PATH, states[i], ASSET_EXT);
        icon.states[i].texture = LoadTexture(filename);
        icon.states[i].execute = get_fn(states[i]);
    }

    self->icons[self->icon_count++] = icon;
}

void hud_load(HUD* self) {
    self->icon_count = 0;

    // Top left row of icons
    for (int i = 0; i < 2; i++) {
        int x = START_ICONS_X + i * ICON_W;
        int y = START_ICONS_Y;
        add_icon(self, TOP_LEFT[i], i == 0 ? 1 : 2, x, y);
    }

    // Top right row of icons
    for (int i = 0; i < 1; i++) {
        int x = GAME_WIDTH - START_ICONS_X - (i + 1) * ICON_W;
        int y = START_ICONS_Y;
        add_icon(self, TOP_RIGHT[i], 2, x, y);
    }
}

static void update_state(Icon* icon, State* game_state) {
    if (icon->state_count > 1) {
        icon->state = (icon->state + 1) % icon->state_count;
    }
    icon->states[icon->state].execute(game_state);
}

void hud_update(HUD* self, State* game_state) {
    if (self->key_timeout > 0) {
        self->key_timeout--;
    }

    if (IsKeyDown(KEY_M)) {
        if (self->key_timeout == 0) {
            update_state(&self->icons[MUSIC_BUTTON], game_state);
        }
        self->key_timeout = 2;
    }

    bool pressed = IsMouseButtonPressed(MOUSE_BUTTON_LEFT);
    bool hover = false;
    float mx = game_state->mouse.x;
    float my = game_state->mouse.y;

    for (int i = 0; i < self->icon_count; i++) {
        Icon* icon = &self->icons[i];
        if (mx > icon->x && mx < icon->x + ICON_W * ICON_SCALE &&
            my > icon->y && my < icon->y + ICON_H * ICON_SCALE) {
            hover = true;
            if (pressed) {
                update_state(icon, game_state);
            }
        }
    }

    if (hover) {
        SetMouseCursor(MOUSE_CURSOR_CROSSHAIR);
    }
}

static void draw_score(const State* game_state) {
    char text[64];
    snprintf(text, sizeof(text), "Score: %d", game_state->score);
    int font_size = 64;
    int x = GAME_WIDTH / 2 - MeasureText(text, font_size) / 2;
    DrawText(text, x + game_state->cx, 60, font_size, PINK);
}

void hud_draw(const HUD* self, const State* game_state) {
    for (int i = 0; i < self->icon_count; i++) {
        const Icon* icon = &self->icons[i];
        DrawTextureEx(icon->states[icon->state].texture,
                      (Vector2){icon->x + game_state->cx, icon->y},
                      0, ICON_SCALE, WHITE);
    }
    draw_score(game_state);
}

void hud_unload(HUD* self) {
    for (int i = 0; i < self->icon_count; i++) {
        Icon* icon = &self->icons[i];
        for (int j = 0; j < icon->state_count; j++) {
            UnloadTexture(icon->states[j].texture);
        }
    }
}

bool image_button_mouse_on_button(const ImageButton* self, const State* game_state) {
    int w = self->texture.width * self->scale;
    int h = self->texture.height * self->scale;
    if (game_state->mouse.x > self->x && game_state->mouse.x < self->x + w &&
        game_state->mouse.y > self->y && game_state->mouse.y < self->y + h) {
        SetMouseCursor(MOUSE_CURSOR_CROSSHAIR);
        return true;
    }
    return false;
}

void image_button_draw(const ImageButton* self, const State* game_state) {
    DrawTextureEx(self->texture,
                  (Vector2){self->x + game_state->cx, self->y},
                  0, self->scale, WHITE);
}

void image_button_unload(ImageButton* self) {
    UnloadTexture(self->texture);
}
