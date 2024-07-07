#include "utils.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>


void animation_load(Animation* self, const char* mob, const char** state_names, const int* state_frames, int state_count, int speed, int frame_w, int frame_h, int burn_frame) {
    self->direction = 1;
    self->speed = speed;
    
    char filename[256];
    snprintf(filename, sizeof(filename), "resources/mobs/%s.png", mob);
    self->texture = LoadTexture(filename);
    
    self->w = frame_w;
    self->h = frame_h;
    self->frame_count = 0;
    
    int x = 0, y = 0;
    for (y = 0; y < self->texture.height; y += frame_h) {
        for (x = 0; x < self->texture.width; x += frame_w) {
            self->frames[self->frame_count] = (Vector2){x, y};
            self->frame_count++;
            if (self->frame_count == MAX_FRAMES) {
                break;
            }
        }
        if (self->frame_count == MAX_FRAMES) {
            break;
        }
    }
    
    self->state_count = state_count;
    for (int i = 0; i < state_count; i++) {
        strncpy(self->states[i].name, state_names[i], sizeof(self->states[i].name) - 1);
        self->states[i].frames = state_frames[i];
    }
}

void animation_update(Animation* self, float x, float y) {
    self->counter++;
    if (self->counter >= 60 / self->speed) {
        self->frame++;
        int start_frame = 0;
        int state_frames = 0;
        for (int i = 0; i < self->state_count; i++) {
            if (strcmp(self->state, self->states[i].name) == 0) {
                state_frames = self->states[i].frames;
                break;
            }
            start_frame += self->states[i].frames;
        }
        if (self->frame >= start_frame + state_frames || self->frame < start_frame) {
            self->frame = start_frame;
        }
        self->counter = 0;
    }
    self->x = x;
    self->y = y;
}

void animation_draw(const Animation* self) {
    Rectangle sourceRec = {self->frames[self->frame].x, self->frames[self->frame].y, self->w * self->direction, self->h};
    Vector2 position = {self->x, self->y - self->h};
    DrawTextureRec(self->texture, sourceRec, position, WHITE);
}

void animation_unload(Animation* self) {
    UnloadTexture(self->texture);
}

Color get_color(const int* cs) {
    int r = cs[0] + rand() % (cs[1] - cs[0] + 1);
    int g = cs[2] + rand() % (cs[3] - cs[2] + 1);
    int b = cs[4] + rand() % (cs[5] - cs[4] + 1);
    return (Color){r, g, b, 255};
}
