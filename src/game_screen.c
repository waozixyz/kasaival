#include "screens.h"
#include "mobs.h"
#include "player.h"
#include "ui.h"
#include "plants.h"
#include "scenery.h"
#include "utils.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#define MAX_ENTITIES 100
#define MAX_STAGES 10

const Screen GameScreen = {
    (void (*)(void*, State*))game_load,
    (void (*)(void*, State*))game_update,
    (void (*)(const void*, const State*))game_draw,
    (void (*)(void*))game_unload
};

static void load_stage(Game* self, State* game_state) {
    if (self == NULL) {
        TraceLog(LOG_ERROR, "Invalid Game pointer in load_stage");
        return;
    }

    Stage* new_stage = create_shrubland();

    if (new_stage == NULL) {
        TraceLog(LOG_ERROR, "FAILED TO CREATE STAGE");
        return;
    }

    // If there's an existing stage, free it first
    if (self->stage != NULL) {
        MemFree(self->stage);
    }

    // Assign the new stage
    self->stage = new_stage;

    stage_load(self->stage, game_state);
    
    /*char music_path[256];
    snprintf(music_path, sizeof(music_path), "resources/music/%s", self->stage->music);
    self->music = LoadMusicStream(music_path);
    PlayMusicStream(self->music);*/ // TODO: add music
    
    game_state->gw = 0;

    for (int i = 0; i < self->stage->scene_count; i++) {
        game_state->gw += self->stage->scenes[i].width;
    }
    
    game_state->start_x = (int)(-game_state->gw * 0.5 + GAME_WIDTH * 0.5);
    
    for (int i = 0; i < self->stage->spawner_count; i++) {
        self->stage->spawners[i].start_x += game_state->start_x;
        self->stage->spawners[i].end_x += game_state->start_x;
    }

    ground_init(&self->ground);
    float x = game_state->start_x;
 
    for (int i = 0; i < self->stage->scene_count - 1; i++) {
        int direction = (i < self->stage->scene_count * 0.5) ? 1 : 0;
        Color colors[2] = {self->stage->scenes[i].color, self->stage->scenes[i + 1].color};
        int gradient[2][3] = {
            {colors[0].r, colors[0].g, colors[0].b},
            {colors[1].r, colors[1].g, colors[1].b}
        };
        x = ground_add_section(&self->ground, x, self->stage->scenes[i].width, gradient, direction);
    }


    player_load(&self->player);
    sky_load(&self->sky);
}

static void add_entity(Game* self, EntityName name, int start_x, int end_x) {
    Entity* obj = NULL;
    int x, y;
    get_spawn_pos(start_x, end_x, &x, &y);

    switch (name) {
        case ENTITY_DOG:
            obj = create_dog();
            break;
        case ENTITY_FROG:
            obj = create_frog();
            break;
        case ENTITY_FOX:
            obj = create_fox();
            break;
        case ENTITY_SAGUARO:
            obj = (Entity*)create_saguaro();
            break;
        case ENTITY_KALI:
            obj = (Entity*)create_kali();
            break;
        case ENTITY_OAK:
            obj = (Entity*)create_oak();
            break;
        default:
            return;
    }

    if (obj) {
        obj->load(obj, x, y);
        
        for (int i = 0; i < self->entity_count; i++) {
            if (self->entities[i].dead) {
                free(&self->entities[i]);
                self->entities[i] = *obj;
                free(obj);
                return;
            }
        }
        
        if (self->entity_count < MAX_ENTITIES) {
            self->entities[self->entity_count++] = *obj;
        }
        
        free(obj);
    }
}

static int compare_z_order(const void* a, const void* b) {
    Z_Order* order_a = (Z_Order*)a;
    Z_Order* order_b = (Z_Order*)b;
    if (order_a->y < order_b->y) return -1;
    if (order_a->y > order_b->y) return 1;
    return 0;
}


void game_load(Game* self, State* game_state) {
    load_stage(self, game_state);

    sky_init(&self->sky);
    sky_load(&self->sky);

    background_init(&self->background);
    for (int i = 0; i < self->stage->bg_count; i++) {
        const BGItem* bg = &self->stage->bg[i];
        Texture2D texture = LoadTexture(bg->path);
        background_add(&self->background, texture, bg->cx, bg->x, bg->y);
    }

    player_load(&self->player);

    self->entities = malloc(sizeof(Entity) * MAX_ENTITIES);
    memset(self->entities, 0, sizeof(Entity) * MAX_ENTITIES);
    self->entity_count = 0;
    self->entity_order = malloc(sizeof(Z_Order) * MAX_ENTITIES);
    self->entity_order_count = 0;

    self->elapsed = 0;

    hud_load(&self->hud);
}
void game_update(Game* self, State* game_state) {

    float delta = GetFrameTime();
    self->elapsed += delta;

    if (!game_state->mute) {
        UpdateMusicStream(self->music);
    }
    
    if (!game_state->pause) {
        // Update spawners
        /*for (int i = 0; i < self->stage->spawner_count; i++) {
            self->stage->spawners[i].timer += delta;
            if (self->stage->spawners[i].timer >= self->stage->spawners[i].interval) {
                add_entity(self, self->stage->spawners[i].name, self->stage->spawners[i].start_x, self->stage->spawners[i].end_x);
                self->stage->spawners[i].timer = 0;
            }
        }*/

        // Update background, sky, and ground
        background_update(&self->background, game_state);
        sky_update(&self->sky, game_state);
        ground_update(&self->ground);

        // Update entities and check collisions
        self->entity_order_count = 0;
        
        for (int i = 0; i < self->entity_count; i++) {
            if (!self->entities[i].dead) {
                self->entities[i].update(&self->entities[i], game_state);
                self->entity_order[self->entity_order_count++] = (Z_Order){TO_ORDER_ENTITY, self->entities[i].y, i};

                float player_hitbox[4], entity_hitbox[4];
                player_get_hitbox(&self->player, player_hitbox);
                self->entities[i].get_hitbox(&self->entities[i], entity_hitbox);

                if (check_collision(player_hitbox, entity_hitbox)) {
                    self->entities[i].collided(&self->entities[i], self->player.element, self->player.dp);
                }
            } else {
                game_state->score += self->entities[i].points;
                // Instead of creating a blank entity, just mark it as dead
                self->entities[i].dead = true;
            }
        }
        
        // Update player
        player_update(&self->player, game_state);
        float player_hitbox[4];
        player_get_hitbox(&self->player, player_hitbox);
        float fuel = ground_collide(&self->ground, player_hitbox, self->player.element, self->player.dp);
        player_burn(&self->player, fuel);

        // Add player particles to entity order
        for (int i = 0; i < self->player.flame.particle_count; i++) {
            self->entity_order[self->entity_order_count++] = (Z_Order){TO_ORDER_PLAYER, self->player.flame.particles[i].y, i};
        }

        // Sort entity order
        qsort(self->entity_order, self->entity_order_count, sizeof(Z_Order), compare_z_order);
    }
    

    
    hud_update(&self->hud, game_state);

    if (game_state->exit) {
        set_screen(game_state, &TitleScreen, sizeof(Title));
        game_state->exit = false;
    }
}

void game_draw(const Game* self, const State* game_state) {
    background_draw(&self->background, game_state);
    sky_draw(&self->sky, game_state);
    ground_draw(&self->ground, game_state);

    for (int i = 0; i < self->entity_order_count; i++) {
        if (self->entity_order[i].entity == TO_ORDER_PLAYER) {
            player_draw(&self->player, self->entity_order[i].i);
        } else {
            self->entities[self->entity_order[i].i].draw(&self->entities[self->entity_order[i].i], game_state);
        }
    }

    hud_draw(&self->hud, game_state);
}

void game_unload(Game* self) {
    UnloadMusicStream(self->music);
    background_unload(&self->background);
    sky_unload(&self->sky);
    ground_unload(&self->ground);
    player_unload(&self->player);
    for (int i = 0; i < self->entity_count; i++) {
        if (!self->entities[i].dead) {
            self->entities[i].unload(&self->entities[i]);
        }
    }
    free(self->entities);
    free(self->entity_order);

    hud_unload(&self->hud);
}

