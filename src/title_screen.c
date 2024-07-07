#include "screens.h"
#include "utils.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>


const Screen TitleScreen = {
    (void (*)(void*, State*))title_load,
    (void (*)(void*, State*))title_update,
    (void (*)(const void*, const State*))title_draw,
    (void (*)(void*))title_unload
};

// Title screen functions
void title_load(Title* self, State* game_state) {
    (void)game_state;
    // self->background = LoadTexture("resources/menu.jpg"); // TODO: fix background
}

void title_update(Title* self, State* game_state) {
    (void)self;
    if (IsMouseButtonPressed(MOUSE_BUTTON_LEFT) || GetKeyPressed() > 0) {
        Carousel* carousel = malloc(sizeof(Carousel));
        carousel_load(carousel, game_state);
        set_screen(game_state, (Screen*)carousel);
    }
}

void title_draw(const Title* self, const State* game_state) {
    (void)self;
    (void)game_state;
    DrawTextureEx(self->background, (Vector2){0, 0}, 0, 1, WHITE);
    DrawText("KASAIVAL", 480, 160, 200, MAROON);
    DrawText("an out of control flame trying to survive", 350, 640, 60, MAROON);
    DrawText("touch anywhere to start burning", 480, 1000, 60, BEIGE);
}

void title_unload(Title* self) {
    UnloadTexture(self->background);
}
