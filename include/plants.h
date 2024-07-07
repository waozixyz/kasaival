#ifndef PLANTS_H
#define PLANTS_H

#include <raylib.h>
#include "state.h"

#define MAX_PLANT_ROWS 10
#define MAX_BRANCHES_PER_ROW 50

typedef struct {
    int deg;
    float x1;
    float y1;
    float x2;
    float y2;
    float w;
    float h;
    Color color;
} Branch;

typedef struct {
    char element[10];
    float left_x;
    float right_x;
    float y;
    int points;
    int w;
    int h;
    int cs_branch[6];
    int cs_leaf[6];
    int change_color[4];
    Branch grid[MAX_PLANT_ROWS][MAX_BRANCHES_PER_ROW];
    int branch_counts[MAX_PLANT_ROWS];
    int max_row;
    int current_row;
    int split_chance;
    int split_angle[2];
    int grow_timer;
    int grow_time;
    int burning;
    float burn_intensity;
    bool two_start_branches;
    bool grow_to_random_row;
    bool dead;
} Plant;

void plant_load(Plant* self, int start_x, int y);
void plant_update(Plant* self, const State* game_state);
void plant_draw(const Plant* self, const State* game_state);
void plant_unload(Plant* self);
void plant_collided(Plant* self, const char* element, float dp);
void plant_get_hitbox(const Plant* self, float* hitbox);

Plant* create_saguaro(void);
Plant* create_oak(void);
Plant* create_kali(void);

#endif // PLANTS_H
