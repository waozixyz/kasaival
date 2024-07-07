#ifndef SCENERY_H
#define SCENERY_H

#include <raylib.h>
#include "state.h"

#define MAX_SECTIONS 10
#define MAX_TILE_ROWS 12
#define MAX_TILES 100
#define MAX_STARS 100
#define MAX_BACKGROUND_ITEMS 10

typedef struct {
    Vector2 p1;
    Vector2 p2;
    Vector2 p3;
    Color org_color;
    Color color;
} Tile;

typedef struct {
    Tile grid[MAX_TILE_ROWS][MAX_TILES];
    int tile_counts[MAX_TILE_ROWS];
    bool water;
    int direction;
    int gradient[2][3];
    float tile_w;
    int width;
    float start_x;
} Section;

typedef struct {
    Section sections[MAX_SECTIONS];
    int section_count;
    float pos_y[MAX_TILE_ROWS];
    float tile_size;
    float elapsed;
    float tick;
} Ground;

typedef struct {
    float elapsed;
    float time;
    int x;
    int y;
    int r;
    Color pc;
    Color nc;
} Star;

typedef struct {
    Texture2D nebula;
    Texture2D bg[2];
    int bg_count;
    Star stars[MAX_STARS];
    int star_count;
} Sky;

typedef struct {
    Texture2D texture;
    float cx;
    int x;
    int y;
    int layer;
} BackgroundItem;

typedef struct {
    BackgroundItem items[MAX_BACKGROUND_ITEMS];
    int item_count;
} Background;

void ground_init(Ground* self);
float ground_add_section(Ground* self, float start_x, int width, int gradient[2][3], int direction);
void ground_update(Ground* self);
float ground_collide(Ground* self, float* b, const char* element, float power);
void ground_draw(const Ground* self, const State* game_state);
void ground_unload(Ground* self);

void sky_init(Sky* self);
void sky_load(Sky* self);
void sky_update(Sky* self, const State* game_state);
void sky_draw(const Sky* self, const State* game_state);
void sky_unload(Sky* self);

void background_init(Background* self);
void background_add(Background* self, Texture2D texture, float cx, int x, int y);
void background_update(Background* self, const State* game_state);
void background_draw(const Background* self, const State* game_state);
void background_unload(Background* self);

#endif // SCENERY_H
