#ifndef UI_H
#define UI_H

#include <raylib.h>
#include "state.h"

#define MAX_ICONS 10
#define MAX_BUTTON_STATES 2

typedef struct {
    Texture2D texture;
    void (*execute)(State* game_state);
} ButtonState;

typedef struct {
    ButtonState states[MAX_BUTTON_STATES];
    int state_count;
    int state;
    int x;
    int y;
} Icon;

typedef struct {
    int key_timeout;
    Icon icons[MAX_ICONS];
    int icon_count;
} HUD;

typedef struct {
    Texture2D texture;
    int x;
    int y;
    int scale;
} ImageButton;

void hud_load(HUD* self);
void hud_update(HUD* self, State* game_state);
void hud_draw(const HUD* self, const State* game_state);
void hud_unload(HUD* self);

bool image_button_mouse_on_button(const ImageButton* self, const State* game_state);
void image_button_draw(const ImageButton* self, const State* game_state);
void image_button_unload(ImageButton* self);

#endif // UI_H
