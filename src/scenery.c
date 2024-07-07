#include "scenery.h"
#include "config.h"
#include <math.h>
#include <string.h>
#include <stdlib.h>

static Color get_color(const Section* s, float x) {
    float rat = (x - s->start_x) / s->width;
    rat = rat + ((float)rand() / RAND_MAX * 0.2f - 0.1f);
    rat = fmaxf(0.0f, fminf(1.0f, rat));

    int r = s->gradient[0][0] * (1 - rat) + s->gradient[1][0] * rat;
    int g = s->gradient[0][1] * (1 - rat) + s->gradient[1][1] * rat;
    int b = s->gradient[0][2] * (1 - rat) + s->gradient[1][2] * rat;

    return (Color){r, g, b, 255};
}

static void tile_heal(Tile* tile) {
    if (tile->color.r != tile->org_color.r) tile->color.r--;
    if (tile->color.b != tile->org_color.b) tile->color.b++;
    if (tile->color.g != tile->org_color.g) tile->color.g++;
}

static void tile_wave(Tile* tile, Color c) {
    tile->color.r = (tile->org_color.r + c.r) / 2;
    tile->color.g = (tile->org_color.g + c.g) / 2;
    tile->color.b = (tile->org_color.b + c.b) / 2;
}

static float tile_burn(Tile* tile, float power) {
    unsigned char dmg = (unsigned char)power;
    unsigned char o_r = tile->org_color.r, o_g = tile->org_color.g;
    unsigned char t_g = tile->color.g;

    if (tile->color.g > o_g - 30 && tile->color.g - dmg > 0) {
        tile->color.g -= dmg;
    }
    if (tile->color.r < o_r + 20 && tile->color.r + dmg < 255) {
        tile->color.r += dmg;
    }

    return t_g - tile->color.g - tile->color.b * 0.05f;
}

void ground_init(Ground* self) {
    memset(self, 0, sizeof(Ground));
}


float ground_add_section(Ground* self, float start_x, int width, int gradient[2][3], int direction) {
    if (self->section_count >= MAX_SECTIONS) return start_x;

    Section* s = &self->sections[self->section_count++];
    memcpy(s->gradient, gradient, sizeof(s->gradient));
    s->width = width;
    s->tile_w = (GAME_HEIGHT - START_Y) / MAX_TILE_ROWS;
    s->start_x = start_x;
    s->direction = direction;
    self->tile_size = s->tile_w;

    float y = START_Y;
    float w = s->tile_w;
    float h = w;
    float end_x = start_x; 

    for (int i = 0; i < MAX_TILE_ROWS; i++) {
        if (i >= self->section_count) {
            self->pos_y[i] = y;
        }

        float x = s->start_x - w;
        int tile_count = 0;

        while (x < s->start_x + width + w && tile_count < MAX_TILES) {
            Color c1 = get_color(s, x - w * 0.5f);
            Color c2 = get_color(s, x);

            s->grid[i][tile_count] = (Tile){
                {x - w * 0.5f, y},
                {x, y + h},
                {x + w * 0.5f, y},
                c1, c1
            };
            tile_count++;

            s->grid[i][tile_count] = (Tile){
                {x + w * 0.5f, y},
                {x, y + h},
                {x + w, y + h},
                c2, c2
            };
            tile_count++;

            x += w;
        }

        s->tile_counts[i] = tile_count;
        y += h;
    }

    for (int i = 0; i < 2; i++) {
        if (gradient[i][2] > gradient[i][0] && gradient[i][2] > gradient[i][1]) {
            s->water = true;
            s->direction = i;
            break;
        }
    }

    return end_x + w;
}

void ground_update(Ground* self) {
    self->elapsed += GetFrameTime();
    self->tick += GetFrameTime();

    for (int s = 0; s < self->section_count; s++) {
        Section* section = &self->sections[s];
        for (int r = 0; r < MAX_TILE_ROWS; r++) {
            for (int t = 0; t < section->tile_counts[r]; t++) {
                Tile* tile = &section->grid[r][t];

                if (self->tick > 0.1f) {
                    tile_heal(tile);
                }

                if (section->water) {
                    int modi = section->direction == 0 ? t + 1 : section->tile_counts[r] - t + 1;
                    if ((int)(self->elapsed * 60) % modi == 0) {
                        tile_wave(tile, get_color(section, tile->p2.x - section->tile_w * 0.5f));
                    }
                }
            }
        }
    }

    if (self->tick > 0.1f) {
        self->tick = 0;
    }
}

float ground_collide(Ground* self, float* b, const char* element, float power) {
    float fuel = 0;
    int index[MAX_TILE_ROWS];
    int index_count = 0;

    for (int i = 0; i < MAX_TILE_ROWS; i++) {
        if (self->pos_y[i] < b[3] && self->pos_y[i] + self->tile_size > b[2]) {
            index[index_count++] = i;
        }
    }

    for (int s = 0; s < self->section_count; s++) {
        Section* section = &self->sections[s];
        for (int i = 0; i < index_count; i++) {
            int row = index[i];
            for (int j = 0; j < section->tile_counts[row]; j++) {
                Tile* tile = &section->grid[row][j];
                float l = j % 2 == 0 ? tile->p1.x : tile->p2.x;
                float r = tile->p3.x;

                if (l < b[1] && r > b[0]) {
                    if (strcmp(element, "fire") == 0) {
                        fuel += tile_burn(tile, power);
                    }
                }
            }
        }
    }

    return fuel;
}

void ground_draw(const Ground* self, const State* game_state) {
    for (int s = 0; s < self->section_count; s++) {
        const Section* section = &self->sections[s];
        for (int r = 0; r < MAX_TILE_ROWS; r++) {
            for (int t = 0; t < section->tile_counts[r]; t++) {
                const Tile* tile = &section->grid[r][t];
                float l = t % 2 == 0 ? tile->p1.x : tile->p2.x;
                float r = tile->p3.x;
                float w = r - l;

                if (l + w > game_state->cx && r < game_state->cx + GAME_WIDTH + w) {
                    DrawTriangle(tile->p1, tile->p2, tile->p3, tile->color);
                }
            }
        }
    }
}

void ground_unload(Ground* self) {
    (void)self;
}

static Color star_color(void) {
    return (Color){
        200 + rand() % 50,
        150 + rand() % 50,
        90 + rand() % 50,
        255
    };
}

void sky_init(Sky* self) {
    memset(self, 0, sizeof(Sky));
}

void sky_load(Sky* self) {
    self->bg[self->bg_count++] = LoadTexture("resources/sky/planets.jpg");
    self->nebula = LoadTexture("resources/sky/nebula.png");

    for (int i = 0; i < 100; i++) {
        Star* star = &self->stars[self->star_count++];
        star->x = rand() % GAME_WIDTH;
        star->y = rand() % GAME_HEIGHT;
        star->r = 4 + rand() % 12;
        star->pc = star_color();
        star->nc = star_color();
        star->time = 0.5f;
        star->elapsed = (float)rand() / RAND_MAX * 0.5f;

        if (i == 80) star->r = 50;
        if (i == 20) star->r = 150;
    }
}

static Color get_current_color(const Star* star, float rat) {
    Color pc = star->pc;
    Color nc = star->nc;
    return (Color){
        pc.r * (1 - rat) + nc.r * rat,
        pc.g * (1 - rat) + nc.g * rat,
        pc.b * (1 - rat) + nc.b * rat,
        245
    };
}

void sky_update(Sky* self, const State* game_state) { 
    (void)game_state;

    float delta = GetFrameTime();
    for (int i = 0; i < self->star_count; i++) {
        Star* star = &self->stars[i];
        star->elapsed += delta;
        if (star->elapsed > star->time) {
            star->pc = star->nc;
            star->nc = star_color();
            star->elapsed = 0;
            star->y--;
            star->x += -2 + rand() % 5;
            if (star->y + star->r < 0) {
                star->y += GAME_HEIGHT;
            }
        }
    }
}

void sky_draw(const Sky* self, const State* game_state) {
    for (int i = 0; i < self->bg_count; i++) {
        DrawTexture(self->bg[i], game_state->cx, 0, WHITE);
    }

    for (int i = 0; i < self->star_count; i++) {
        const Star* star = &self->stars[i];
        float r = star->elapsed / star->time;
        Color c = get_current_color(star, r);
        DrawCircle(star->x + game_state->cx, star->y, star->r, c);
    }

    DrawTexture(self->nebula, game_state->cx, 0, WHITE);
}

void sky_unload(Sky* self) {
    for (int i = 0; i < self->bg_count; i++) {
        UnloadTexture(self->bg[i]);
    }
    UnloadTexture(self->nebula);
}

void background_init(Background* self) {
    memset(self, 0, sizeof(Background));
}

void background_add(Background* self, Texture2D texture, float cx, int x, int y) {
    if (self->item_count < MAX_BACKGROUND_ITEMS) {
        self->items[self->item_count++] = (BackgroundItem){texture, cx, x, y, 0};
    }
}

void background_update(Background* self, const State* game_state) {
    (void)self; 
    (void)game_state;
}

void background_draw(const Background* self, const State* game_state) {
    for (int i = 0; i < self->item_count; i++) {
        const BackgroundItem* item = &self->items[i];
        float scale = (float)START_Y / item->texture.height;
        float x = item->x + game_state->cx * item->cx - item->texture.width * scale;
        DrawTextureEx(item->texture, (Vector2){x, item->y}, 0, scale, WHITE);
    }
}

void background_unload(Background* self) {
    for (int i = 0; i < self->item_count; i++) {
        UnloadTexture(self->items[i].texture);
    }
}
