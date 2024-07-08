#ifndef SCREENS_H
#define SCREENS_H

#include <raylib.h>
#include "state.h"
#include "ui.h"
#include "ecs.h"
#include "player.h"
#include "scenery.h"
#include "stages.h"

typedef enum {
    TO_ORDER_PLAYER,
    TO_ORDER_ENTITY
} ToOrder;

typedef struct {
    ToOrder entity;
    float y;
    int i;
} Z_Order;

typedef struct {
    Screen base;
    Stage* stage;
    Entity* entities;
    int entity_count;
    Z_Order* entity_order;
    int entity_order_count;
    PlayerCore player;
    Ground ground;
    Background background;
    Sky sky;
    Music music;
    HUD hud;
    float elapsed;
} Game;

typedef struct {
    Screen base;
    Texture2D background;
} Title;

typedef struct {
    Screen base;
    Texture2D background;
    ImageButton* stages;
    int stage_count;
} Carousel;

extern const Screen GameScreen;
extern const Screen TitleScreen;
extern const Screen CarouselScreen;

// Game screen functions
void game_load(Game* self, State* game_state);
void game_update(Game* self, State* game_state);
void game_draw(const Game* self, const State* game_state);
void game_unload(Game* self);

// Title screen functions
void title_load(Title* self, State* game_state);
void title_update(Title* self, State* game_state);
void title_draw(const Title* self, const State* game_state);
void title_unload(Title* self);

// Carousel screen functions
void carousel_load(Carousel* self, State* game_state);
void carousel_update(Carousel* self, State* game_state);
void carousel_draw(const Carousel* self, const State* game_state);
void carousel_unload(Carousel* self);

#endif // SCREENS_H
