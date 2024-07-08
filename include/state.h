// state.h
#ifndef STATE_H
#define STATE_H

#include <raylib.h>
#include <stdbool.h>
#include <stddef.h>
#include "config.h"

typedef struct State State;

typedef struct Screen {
    void (*load)(void* self, State* state);
    void (*update)(void* self, State* state);
    void (*draw)(const void* self, const State* state);
    void (*unload)(void* self);
} Screen;

struct State {
    void* current_screen;
    const Screen* screen_vtable;
    bool exit;
    bool mute;
    bool pause;
    int start_x;
    float cx;
    float gw;
    float gh;
    int score;
    Vector2 mouse;
};
void set_screen(State* game_state, const Screen* screen, size_t screen_size);
State* create_state(void);
void free_state(State* game_state);

#endif // STATE_H
