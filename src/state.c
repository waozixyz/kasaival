#include "state.h"

void set_screen(State* game_state, Screen* screen) {
    if (game_state->screen) {
        game_state->screen->unload(game_state->screen);
    }
    game_state->screen = screen;
    game_state->screen->load(game_state->screen, game_state);
}
