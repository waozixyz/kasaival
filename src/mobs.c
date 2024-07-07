#include "mobs.h"
#include "config.h"
#include <stdlib.h>
#include <string.h>

// Fox functions
static void fox_load(Entity* entity, int x, int y) {
    Fox* self = (Fox*)entity;
    self->x = x;
    self->base.y = y;
    // TODO: Implement fox animation loading
}

static void fox_update(Entity* entity, State* game_state) {
    Fox* self = (Fox*)entity;
    animation_update(&self->anime, self->x, self->base.y);
    (void)game_state; // Suppress unused parameter warning
}

static void fox_draw(const Entity* entity, const State* game_state) {
    const Fox* self = (const Fox*)entity;
    animation_draw(&self->anime);
    (void)game_state; // Suppress unused parameter warning
}

static void fox_unload(Entity* entity) {
    Fox* self = (Fox*)entity;
    animation_unload(&self->anime);
}

static void fox_collided(Entity* entity, const char* element, float dp) {
    (void)entity; // Suppress unused variable warning
    (void)dp; // Suppress unused parameter warning
    if (strcmp(element, "fire") == 0) {
        // Add any specific behavior for fire collision
    }
}

static void fox_get_hitbox(const Entity* entity, float* hitbox) {
    const Fox* self = (const Fox*)entity;
    hitbox[0] = self->x;
    hitbox[1] = self->x;
    hitbox[2] = self->base.y;
    hitbox[3] = self->base.y;
}

Entity* create_fox() {
    Fox* fox = malloc(sizeof(Fox));
    fox->base.y = 0;
    fox->base.dead = false;
    fox->base.points = 30;
    fox->base.load = fox_load;
    fox->base.update = fox_update;
    fox->base.draw = fox_draw;
    fox->base.unload = fox_unload;
    fox->base.collided = fox_collided;
    fox->base.get_hitbox = fox_get_hitbox;
    return (Entity*)fox;
}

// Dog functions
static void dog_load(Entity* entity, int x, int y) {
    Dog* self = (Dog*)entity;
    self->x = x;
    self->base.y = y;
    
    const char* state_names[] = {"walk", "pee", "burn"};
    int state_frames[] = {3, 3, 6};
    int state_count = 3;
    
    animation_load(&self->anime, "dog", state_names, state_frames, state_count, 6, self->w, self->h, 7);
    
    self->walk_time = 5;
    self->pee_time = 3;
    self->burn_time = 0.15f;
    self->counter = rand() % (int)(self->walk_time * 60);
    self->direction_y = ((float)rand() / (float)RAND_MAX) * 2.0f - 1.0f;
    self->anime.direction = 1 - (rand() % 2) * 2;
}

static void dog_update(Entity* entity, State* game_state) {
    Dog* self = (Dog*)entity;
    // TODO: Implement dog update logic
    (void)game_state; // Suppress unused parameter warning
    (void)self; // Suppress unused variable warning for now
}

static void dog_draw(const Entity* entity, const State* game_state) {
    const Dog* self = (const Dog*)entity;
    animation_draw(&self->anime);
    (void)game_state; // Suppress unused parameter warning
}

static void dog_unload(Entity* entity) {
    Dog* self = (Dog*)entity;
    animation_unload(&self->anime);
}

static void dog_collided(Entity* entity, const char* element, float dp) {
    Dog* self = (Dog*)entity;
    if (strcmp(element, "fire") == 0) {
        self->burning = true;
    }
    (void)dp; // Suppress unused parameter warning
}

static void dog_get_hitbox(const Entity* entity, float* hitbox) {
    const Dog* self = (const Dog*)entity;
    hitbox[0] = self->x;
    hitbox[1] = self->x + self->w;
    hitbox[2] = self->base.y - self->h * 0.2f;
    hitbox[3] = self->base.y;
}

Entity* create_dog() {
    Dog* dog = malloc(sizeof(Dog));
    dog->base.y = 0;
    dog->base.dead = false;
    dog->base.points = 30;
    dog->speed = 2;
    dog->speed_y = 1.5f;
    dog->w = 100;
    dog->h = 64;
    dog->base.load = dog_load;
    dog->base.update = dog_update;
    dog->base.draw = dog_draw;
    dog->base.unload = dog_unload;
    dog->base.collided = dog_collided;
    dog->base.get_hitbox = dog_get_hitbox;
    return (Entity*)dog;
}

// Frog functions
static void frog_load(Entity* entity, int x, int y) {
    Frog* self = (Frog*)entity;
    self->x = x;
    self->base.y = y;
    // TODO: Implement frog animation loading
}

static void frog_update(Entity* entity, State* game_state) {
    Frog* self = (Frog*)entity;
    animation_update(&self->anime, self->x, self->base.y);
    (void)game_state; // Suppress unused parameter warning
}

static void frog_draw(const Entity* entity, const State* game_state) {
    const Frog* self = (const Frog*)entity;
    animation_draw(&self->anime);
    (void)game_state; // Suppress unused parameter warning
}

static void frog_unload(Entity* entity) {
    Frog* self = (Frog*)entity;
    animation_unload(&self->anime);
}

static void frog_collided(Entity* entity, const char* element, float dp) {
    (void)entity; // Suppress unused variable warning
    (void)dp; // Suppress unused parameter warning
    if (strcmp(element, "fire") == 0) {
        // Add any specific behavior for fire collision
    }
}

static void frog_get_hitbox(const Entity* entity, float* hitbox) {
    const Frog* self = (const Frog*)entity;
    hitbox[0] = self->x;
    hitbox[1] = self->x;
    hitbox[2] = self->base.y;
    hitbox[3] = self->base.y;
}

Entity* create_frog() {
    Frog* frog = malloc(sizeof(Frog));
    frog->base.y = 0;
    frog->base.dead = false;
    frog->base.points = 40;
    frog->base.load = frog_load;
    frog->base.update = frog_update;
    frog->base.draw = frog_draw;
    frog->base.unload = frog_unload;
    frog->base.collided = frog_collided;
    frog->base.get_hitbox = frog_get_hitbox;
    return (Entity*)frog;
}
