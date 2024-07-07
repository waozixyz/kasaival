#include "ecs.h"
#include "utils.h"
#include "mobs.h"
#include "plants.h"
#include <stdlib.h>

void get_spawn_pos(int start_x, int end_x, int* x, int* y) {
    *x = rand() % (end_x - start_x + 1) + start_x;
    *y = rand() % (GAME_HEIGHT - START_Y + 1) + START_Y;
}

bool check_collision(const float* a, const float* b) {
    return a[0] < b[1] && a[1] > b[0] && a[2] < b[3] && a[3] > b[2];
}

Entity* new_entity(EntityName name) {
    Entity* entity = NULL;

    switch (name) {
        case ENTITY_DOG:
            entity = create_dog();
            break;
        case ENTITY_FROG:
            entity = create_frog();
            break;
        case ENTITY_FOX:
            entity = create_fox();
            break;
        case ENTITY_SAGUARO:
            entity = create_saguaro();
            break;
        case ENTITY_KALI:
            entity = create_kali();
            break;
        case ENTITY_OAK:
            entity = create_oak();
            break;
    }

    return entity;
}

// Blank entity functions
static void blank_load(Entity* self, int x, int y) {
    // Do nothing for blank entity
}

static void blank_update(Entity* self, State* game_state) {
    // Do nothing for blank entity
}

static void blank_draw(const Entity* self, const State* game_state) {
    // Do nothing for blank entity
}

static void blank_unload(Entity* self) {
    // Do nothing for blank entity
}

static void blank_collided(Entity* self, const char* element, float dp) {
    // Do nothing for blank entity
}

static void blank_get_hitbox(const Entity* self, float* hitbox) {
    hitbox[0] = 0;
    hitbox[1] = 0;
    hitbox[2] = 0;
    hitbox[3] = 0;
}

Entity* create_blank_entity() {
    Entity* blank = malloc(sizeof(Entity));
    blank->y = 0;
    blank->dead = false;
    blank->points = 0;
    blank->load = blank_load;
    blank->update = blank_update;
    blank->draw = blank_draw;
    blank->unload = blank_unload;
    blank->collided = blank_collided;
    blank->get_hitbox = blank_get_hitbox;
    return blank;
}
