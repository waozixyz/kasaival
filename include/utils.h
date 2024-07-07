#ifndef UTILS_H
#define UTILS_H

#include <raylib.h>
#include "config.h"

#define MAX_FRAMES 12
#define MAX_ANIMATION_STATES 10

typedef struct {
    char name[20];
    int frames;
} AnimationState;

typedef struct {
    char state[20];
    int direction;
    float x;
    float y;
    int w;
    int h;
    int counter;
    Texture2D texture;
    int frame;
    Vector2 frames[MAX_FRAMES];
    int frame_count;
    int speed;
    Vector2 pos;
    bool burning;
    AnimationState states[MAX_ANIMATION_STATES];
    int state_count;
} Animation;

void animation_load(Animation* self, const char* mob, const char** state_names, const int* state_frames, int state_count, int speed, int frame_w, int frame_h, int burn_frame);
void animation_update(Animation* self, float x, float y);
void animation_draw(const Animation* self);
void animation_unload(Animation* self);

Color get_color(const int* cs);

#endif // UTILS_H
