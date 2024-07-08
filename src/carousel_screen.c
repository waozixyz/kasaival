#include "screens.h"
#include "utils.h"
#include "state.h"
#include "ui.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>


static const char* STAGES[] = {"shrubland", "grassland"};
static const int STAGES_ID[] = {0, 1};
static const int START_X = 200;
static const char* EXT = ".jpg";
static const char* PATH = "resources/stages/";


const Screen CarouselScreen = {
    (void (*)(void*, State*))carousel_load,
    (void (*)(void*, State*))carousel_update,
    (void (*)(const void*, const State*))carousel_draw,
    (void (*)(void*))carousel_unload
};


// Carousel screen functions
void carousel_load(Carousel* self, State* game_state) {
    game_state->cx = 0;
    self->background = LoadTexture("resources/menu.jpg");
    self->stage_count = sizeof(STAGES) / sizeof(STAGES[0]);
    self->stages = malloc(sizeof(ImageButton) * self->stage_count);

    int w = 0;
    int off_x = 100;
    for (int i = 0; i < self->stage_count; i++) {
        char filename[256];
        snprintf(filename, sizeof(filename), "%s%s%s", PATH, STAGES[i], EXT);
        Texture2D img = LoadTexture(filename);
        int x = START_X + w + off_x * i;
        int y = START_Y;
        self->stages[i] = (ImageButton){img, x, y, 1};
        w = img.width;
    }
}

static void get_key_action(int i, State* game_state) {
    switch (i) {
        case 0:
        case 1:
            {
                set_screen(game_state, &GameScreen, sizeof(Game));
            }
            break;
        default:
            break;
    }
}

void carousel_update(Carousel* self, State* game_state) {
    int key = -1;
    int key_pressed = GetKeyPressed();
    bool mouse_pressed = IsMouseButtonPressed(MOUSE_BUTTON_LEFT);

    for (int i = 0; i < self->stage_count; i++) {
        if (image_button_mouse_on_button(&self->stages[i], game_state)) {
            if (mouse_pressed) {
                key = i;
            }
        }
    }

    if (key_pressed >= 49 && key_pressed < 58) {
        key = key_pressed - 49;
    } else if (key_pressed >= 321 && key_pressed < 330) {
        key = key_pressed - 321;
    }

    get_key_action(key, game_state);
}

void carousel_draw(const Carousel* self, const State* game_state) {
    DrawTextureEx(self->background, (Vector2){0, 0}, 0, 1, WHITE);
    DrawText("KASAIVAL", 480, 160, 200, MAROON);
    for (int i = 0; i < self->stage_count; i++) {
        image_button_draw(&self->stages[i], game_state);
    }
}

void carousel_unload(Carousel* self) {
    UnloadTexture(self->background);
    for (int i = 0; i < self->stage_count; i++) {
        image_button_unload(&self->stages[i]);
    }
    free(self->stages);
}
