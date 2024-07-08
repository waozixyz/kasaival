// stages.h
#ifndef STAGES_H
#define STAGES_H

#include "ecs.h"
#include <raylib.h>

#define MAX_SCENES 10
#define MAX_SPAWNERS 10
#define MAX_BG_ITEMS 10

typedef struct {
    int width;
    Color color;
} Scene;

typedef struct {
    EntityName name;
    int start_x;
    int end_x;
    float interval;
    float timer;
} Spawner;


typedef struct {
    char path[256];
    float cx;
    int x;
    int y;
} BGItem;

typedef struct {
    char music[256];
    Scene scenes[MAX_SCENES];
    int scene_count;
    Spawner spawners[MAX_SPAWNERS];
    int spawner_count;
    BGItem bg[MAX_BG_ITEMS];
    int bg_count;
} Stage;

Stage* create_shrubland(void);
Stage* create_empty_stage(void); 

#endif // STAGES_H
