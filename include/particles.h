#ifndef PARTICLES_H
#define PARTICLES_H

#include <raylib.h>

#define MAX_PARTICLES 60

typedef struct {
    float y;
    Vector2 position;
    int lifetime;
    Vector2 vel_start;
    Vector2 vel_end;
    Color color;
    Color color_start;
    Color color_end;
    float scale;
    float shrink_factor;
} Particle;

typedef struct {
    int lifetime;
    Vector2 position;
    Color color;
    int amount;
    int radius;
    float scale;
    Particle particles[MAX_PARTICLES];
    int particle_count;
} Fire;

void fire_load(Fire* self);
void fire_get_dimensions(const Fire* self, float* width, float* height);
void fire_update(Fire* self, float x, float y);
void fire_draw(const Fire* self, int i);
void fire_unload(Fire* self);

#endif // PARTICLES_H
