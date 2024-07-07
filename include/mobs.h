#ifndef MOBS_H
#define MOBS_H

#include <raylib.h>
#include "state.h"
#include "utils.h"
#include "ecs.h"

typedef struct {
    Entity base;
    float x;
    Texture2D texture;
    Animation anime;
} Fox;

typedef struct {
    Entity base;
    int counter;
    int speed;
    float speed_y;
    float x;
    Texture2D texture;
    Animation anime;
    float walk_time;
    float pee_time;
    float burn_time;
    bool burning;
    int w;
    int h;
    float direction_y;
} Dog;

typedef struct {
    Entity base;
    float x;
    Texture2D texture;
    Animation anime;
} Frog;

Entity* create_fox();
Entity* create_dog();
Entity* create_frog();

#endif // MOBS_H
