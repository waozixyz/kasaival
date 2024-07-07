#include "particles.h"
#include <stdlib.h>

static Particle get_particle(const Fire* self) {
    Particle p = {0};
    p.lifetime = self->lifetime;
    p.position = self->position;
    p.vel_start = (Vector2){(float)(rand() % 7 - 3), -3.0f};
    p.vel_end = (Vector2){(float)(rand() % 5 - 2) * 1.6f, -3.0f};
    p.color_start = self->color;
    p.color_end = (Color){0, 30, 20, 0};
    p.color = p.color_start;
    p.scale = self->scale;
    p.shrink_factor = 0.95f + (float)rand() / RAND_MAX * 0.04f;
    p.y = self->position.y + (float)self->radius * 0.8f * self->scale;
    return p;
}

void fire_load(Fire* self) {
    self->lifetime = 60;
    self->radius = 48;
    self->color = (Color){180, 30, 40, 200};
    self->amount = self->lifetime;
    self->scale = 0.7f;
    self->particle_count = 0;
}

void fire_get_dimensions(const Fire* self, float* width, float* height) {
    *width = self->radius * self->scale;
    *height = self->radius * self->scale;
}

void fire_update(Fire* self, float x, float y) {
    self->position = (Vector2){x, y};

    if (self->particle_count < self->amount) {
        self->particles[self->particle_count] = get_particle(self);
        self->particle_count++;
    }

    for (int i = 0; i < self->particle_count; i++) {
        Particle* p = &self->particles[i];

        if (p->lifetime == 0) {
            *p = get_particle(self);
        }

        float pp = (float)p->lifetime / self->lifetime;

        if (p->lifetime < self->lifetime) {
            p->position.x += p->vel_start.x * pp + p->vel_end.x * (1 - pp);
            p->position.y += p->vel_start.y * pp + p->vel_end.y * (1 - pp);
        }

        p->color.r = (unsigned char)(p->color_start.r * pp + p->color_end.r * (1 - pp));
        p->color.g = (unsigned char)(p->color_start.g * pp + p->color_end.g * (1 - pp));
        p->color.b = (unsigned char)(p->color_start.b * pp + p->color_end.b * (1 - pp));
        p->color.a = (unsigned char)(p->color_start.a * pp + p->color_end.a * (1 - pp));

        p->scale *= p->shrink_factor;
        p->lifetime--;
    }
}

void fire_draw(const Fire* self, int i) {
    if (i < self->particle_count) {
        const Particle* p = &self->particles[i];
        float x = p->position.x - self->radius * p->scale * 0.5f;
        DrawCircle((int)x, (int)p->position.y, self->radius * p->scale, p->color);
    }
}

void fire_unload(Fire* self) {
    // No resources to unload in this implementation
}