#include "plants.h"
#include "utils.h"
#include <math.h>
#include <stdlib.h>
#include <string.h>

#define PI 3.14159265358979323846
#define DEG_TO_RAD (PI / 180.0)

static void plant_shrink(Plant* self) {
    self->branch_counts[self->current_row] = 0;
    self->current_row--;
    if (self->current_row == 0) {
        self->dead = true;
    }
}

static void plant_grow(Plant* self) {
    int prev_row = self->current_row;
    for (int i = 0; i < self->branch_counts[prev_row]; i++) {
        Branch* prev_branch = &self->grid[prev_row][i];
        int split = rand() % 101;
        float px = prev_branch->x2;
        float py = prev_branch->y2;
        float w = prev_branch->w * 0.9f;
        float h = prev_branch->h * 0.95f;
        
        int degs[2];
        int deg_count = 0;
        
        if (self->split_chance > split) {
            int angle1 = self->split_angle[0] + rand() % (self->split_angle[1] - self->split_angle[0] + 1);
            int angle2 = self->split_angle[0] + rand() % (self->split_angle[1] - self->split_angle[0] + 1);
            degs[deg_count++] = prev_branch->deg - angle1;
            degs[deg_count++] = prev_branch->deg + angle2;
        } else {
            degs[deg_count++] = prev_branch->deg;
        }
        
        for (int j = 0; j < deg_count; j++) {
            int deg = degs[j];
            float nx = px + cosf(deg * DEG_TO_RAD) * h;
            float ny = py + sinf(deg * DEG_TO_RAD) * h;
            Color c = get_color(self->cs_branch);
            
            Branch new_branch = {deg, px, py, nx, ny, w, h, c};
            self->grid[self->current_row + 1][self->branch_counts[self->current_row + 1]++] = new_branch;
            
            if (nx < self->left_x) {
                self->left_x = nx;
            } else if (nx > self->right_x) {
                self->right_x = nx + w;
            }
        }
    }
    self->current_row++;
}

static void branch_burn_color(Branch* branch, const Plant* self) {
    unsigned char r = branch->color.r;
    unsigned char g = branch->color.g;
    unsigned char b = 0;
    
    if (r < 200) {
        r += (unsigned char)(self->burn_intensity * 2);
    }
    if (g > 100) {
        g -= 2;
    }
    
    branch->color = (Color){r, g, b, 255};
}

void plant_load(Plant* self, int start_x, int y) {
    self->y = y;
    self->grow_timer = rand() % self->grow_time;
    memset(self->branch_counts, 0, sizeof(self->branch_counts));
    
    int x = start_x;
    int start_angle = -90;
    
    if (self->two_start_branches) {
        Branch start_branch1 = {start_angle + 10, x, y, x, y - self->h, self->w, self->h, get_color(self->cs_branch)};
        self->grid[0][self->branch_counts[0]++] = start_branch1;
        start_angle -= 10;
        x += 10 + rand() % 11;
    }
    
    Branch start_branch2 = {start_angle, x, y, x, y - self->h, self->w, self->h, get_color(self->cs_branch)};
    self->grid[0][self->branch_counts[0]++] = start_branch2;
    
    self->left_x = x;
    self->right_x = x + self->w;
    
    if (self->grow_to_random_row) {
        int grow_to_row = 1 + rand() % self->max_row;
        for (int i = 1; i < grow_to_row; i++) {
            plant_grow(self);
        }
    }
}

void plant_update(Plant* self, const State* game_state) {
    (void)game_state;
    if (self->burning > 0) {
        for (int i = 0; i <= self->current_row; i++) {
            for (int j = 0; j < self->branch_counts[i]; j++) {
                branch_burn_color(&self->grid[i][j], self);
            }
        }
        if (self->current_row >= 0) {
            if (self->grow_timer >= self->grow_time) {
                plant_shrink(self);
                self->grow_timer = 0;
            }
            self->grow_timer += (int)self->burn_intensity;
        }
    } else {
        if (self->current_row < self->max_row - 1) {
            self->grow_timer--;
            if (self->grow_timer < 0) {
                plant_grow(self);
                self->grow_timer = self->grow_time;
            }
        }
    }
}

static Color plant_get_color(const Plant* self, Color c) {
    float growth = (float)(self->current_row + 1 - (float)self->grow_timer / self->grow_time) / self->max_row;
    unsigned char r = (unsigned char)(c.r + self->change_color[0] * growth);
    unsigned char g = (unsigned char)(c.g + self->change_color[1] * growth);
    unsigned char b = (unsigned char)(c.b + self->change_color[2] * growth);
    return (Color){r, g, b, 255};
}

void plant_draw(const Plant* self, const State* game_state) {
    for (int i = 0; i <= self->current_row; i++) {
        for (int j = 0; j < self->branch_counts[i]; j++) {
            const Branch* branch = &self->grid[i][j];
            float x1 = branch->x1;
            float y1 = branch->y1;
            float x2 = branch->x2;
            float y2 = branch->y2;
            
            if (i == self->current_row && self->grow_timer > 0) {
                float t = (float)self->grow_timer / self->grow_time;
                x2 = x1 + (x2 - x1) * (1 - t);
                y2 = y1 + (y2 - y1) * (1 - t);
            }
            
            if ((x1 > game_state->cx || x2 > game_state->cx) &&
                (x1 < game_state->cx + GAME_WIDTH || x2 < game_state->cx + GAME_WIDTH)) {
                DrawLineEx((Vector2){x1, y1}, (Vector2){x2, y2}, branch->w, plant_get_color(self, branch->color));
            }
        }
    }
}

void plant_unload(Plant* self) {
    (void)self;
}

void plant_collided(Plant* self, const char* element, float dp) {
    if (strcmp(element, "fire") == 0) {
        self->burning = 100;
        self->burn_intensity = dp;
    }
}

void plant_get_hitbox(const Plant* self, float* hitbox) {
    const Branch* b = &self->grid[0][0];
    hitbox[0] = self->left_x;
    hitbox[1] = self->right_x;
    hitbox[2] = b->y2;
    hitbox[3] = b->y1;
}

Plant* create_saguaro(void) {
    Plant* plant = (Plant*)malloc(sizeof(Plant));
    strcpy(plant->element, "plant");
    plant->w = 14;
    plant->h = 42;
    plant->max_row = 7;
    int cs_branch[] = {125, 178, 122, 160, 76, 90};
    memcpy(plant->cs_branch, cs_branch, sizeof(cs_branch));
    int cs_leaf[] = {150, 204, 190, 230, 159, 178};
    memcpy(plant->cs_leaf, cs_leaf, sizeof(cs_leaf));
    int change_color[] = {-25, -64, -50, 0};
    memcpy(plant->change_color, change_color, sizeof(change_color));
    plant->grow_time = 20;
    plant->split_chance = 40;
    plant->points = 30;
    plant->split_angle[0] = 20;
    plant->split_angle[1] = 30;
    return plant;
}

Plant* create_oak(void) {
    Plant* plant = (Plant*)malloc(sizeof(Plant));
    strcpy(plant->element, "plant");
    plant->w = 20;
    plant->h = 50;
    plant->points = 20;
    int cs_branch[] = {40, 70, 170, 202, 60, 100};
    memcpy(plant->cs_branch, cs_branch, sizeof(cs_branch));
    int change_color[] = {-10, -10, -10, 0};
    memcpy(plant->change_color, change_color, sizeof(change_color));
    plant->max_row = 8;
    plant->split_chance = 70;
    plant->split_angle[0] = 20;
    plant->split_angle[1] = 30;
    plant->grow_time = 20;
    return plant;
}

Plant* create_kali(void) {
    Plant* plant = (Plant*)malloc(sizeof(Plant));
    strcpy(plant->element, "plant");
    plant->points = 15;
    plant->w = 22;
    plant->h = 22;
    plant->max_row = 5;
    plant->grow_time = 20;
    int cs_branch[] = {140, 170, 160, 190, 25, 50};
    memcpy(plant->cs_branch, cs_branch, sizeof(cs_branch));
    int change_color[] = {-70, -100, -10, 0};
    memcpy(plant->change_color, change_color, sizeof(change_color));
    plant->split_chance = 100;
    plant->split_angle[0] = 40;
    plant->split_angle[1] = 60;
    plant->two_start_branches = true;
    return plant;
}
