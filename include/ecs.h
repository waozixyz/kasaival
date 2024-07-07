// ecs.h
#ifndef ECS_H
#define ECS_H

#include "ecs_types.h"
#include "state.h"

// Function declarations
void get_spawn_pos(int start_x, int end_x, int* x, int* y);
bool check_collision(const float* a, const float* b);
Entity* new_entity(EntityName name);
Entity* create_blank_entity();

// Entity function pointers
typedef void (*EntityLoadFunc)(Entity* self, int x, int y);
typedef void (*EntityUpdateFunc)(Entity* self, State* game_state);
typedef void (*EntityDrawFunc)(const Entity* self, const State* game_state);
typedef void (*EntityUnloadFunc)(Entity* self);
typedef void (*EntityCollidedFunc)(Entity* self, const char* element, float dp);
typedef void (*EntityGetHitboxFunc)(const Entity* self, float* hitbox);

// Entity struct definition
struct Entity {
    float y;
    bool dead;
    int points;
    EntityLoadFunc load;
    EntityUpdateFunc update;
    EntityDrawFunc draw;
    EntityUnloadFunc unload;
    EntityCollidedFunc collided;
    EntityGetHitboxFunc get_hitbox;
};

#endif // ECS_H
