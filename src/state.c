#include "state.h"
#include <raylib.h>
#include <string.h>
#include <stddef.h>

void set_screen(State* game_state, const Screen* screen_vtable, size_t screen_size) {
    TraceLog(LOG_INFO, "Entering set_screen function");
    if (game_state == NULL || screen_vtable == NULL) {
        TraceLog(LOG_ERROR, "Invalid game_state or screen_vtable in set_screen");
        return;
    }

    TraceLog(LOG_INFO, "Unloading current screen");
    // Unload and free the current screen if it exists
    if (game_state->current_screen != NULL) {
        if (game_state->screen_vtable != NULL && game_state->screen_vtable->unload != NULL) {
            TraceLog(LOG_INFO, "Calling unload function");
            game_state->screen_vtable->unload(game_state->current_screen);
        }
        TraceLog(LOG_INFO, "Freeing current screen memory");
        MemFree(game_state->current_screen);
    }

    TraceLog(LOG_INFO, "Allocating memory for new screen: %zu bytes", screen_size);
    // Allocate memory for the new screen
    game_state->current_screen = MemAlloc(screen_size);
    if (game_state->current_screen == NULL) {
        TraceLog(LOG_ERROR, "Failed to allocate memory for new screen");
        return;
    }

    TraceLog(LOG_INFO, "Setting new screen vtable");
    // Set the new screen's vtable
    game_state->screen_vtable = screen_vtable;

    TraceLog(LOG_INFO, "Initializing new screen memory");
    // Initialize the new screen to zero
    memset(game_state->current_screen, 0, screen_size);

    TraceLog(LOG_INFO, "Loading new screen");
    // Load the new screen
    if (game_state->screen_vtable->load != NULL) {
        TraceLog(LOG_INFO, "Calling load function");
        game_state->screen_vtable->load(game_state->current_screen, game_state);
    }

    TraceLog(LOG_INFO, "Screen changed successfully");
}

State* create_state(void) {
    State* state = (State*)MemAlloc(sizeof(State));
    if (!state) {
        TraceLog(LOG_ERROR, "Failed to allocate memory for State");
        return NULL;
    }
    memset(state, 0, sizeof(State));

    
    // Initialize all members
    state->current_screen = NULL;
    state->screen_vtable = NULL;
    state->exit = false;
    state->mute = false;
    state->pause = false;
    state->start_x = 0;
    state->cx = 0.0f;
    state->gw = GAME_WIDTH;
    state->gh = GAME_HEIGHT;
    state->score = 0;
    state->mouse = (Vector2){0, 0};

    TraceLog(LOG_INFO, "The boolean value is: %s", state->exit ? "true" : "false");

    return state;
}

void free_state(State* state) {
    if (state) {
        // Free other dynamic members if any
        MemFree(state);
    }
}
