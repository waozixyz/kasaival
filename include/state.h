// state.h
#ifndef STATE_H
#define STATE_H

#include <raylib.h>
#include <stdbool.h>
#include "config.h"

typedef struct State State;

typedef struct Screen {
    void (*load)(void* self, State* state);
    void (*update)(void* self, State* state);
    void (*draw)(const void* self, const State* state);
    void (*unload)(void* self);
} Screen;

struct State {
    Screen* screen;
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

void set_screen(State* game_state, Screen* screen);

#endif // STATE_H
