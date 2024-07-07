#ifndef PLAYER_H
#define PLAYER_H

#include <raylib.h>
#include "particles.h"
#include "state.h"

typedef struct {
    char element[10];
    float y;
    float dp;
    Fire flame;
    float x;
    float scale;
    float hp;
    float xp;
    int lvl;
    int speed;
    bool dead;
} PlayerCore;

void player_load(PlayerCore* self);
void player_update(PlayerCore* self, State* game_state);
void player_burn(PlayerCore* self, float fuel);
void player_get_hitbox(const PlayerCore* self, float* hitbox);
void player_draw(const PlayerCore* self, int i);
void player_unload(PlayerCore* self);

#endif // PLAYER_H