#include "player.h"
#include "config.h"
#include <math.h>
#include <string.h>

#define KEY_COUNT 4
#define KEYS_PER_DIRECTION 2

static const int KEYS_RIGHT[KEYS_PER_DIRECTION] = {KEY_RIGHT, KEY_D};
static const int KEYS_LEFT[KEYS_PER_DIRECTION] = {KEY_LEFT, KEY_A};
static const int KEYS_UP[KEYS_PER_DIRECTION] = {KEY_UP, KEY_W};
static const int KEYS_DOWN[KEYS_PER_DIRECTION] = {KEY_DOWN, KEY_S};

static bool is_key_down(const int* keys, int count) {
    for (int i = 0; i < count; i++) {
        if (IsKeyDown(keys[i])) {
            return true;
        }
    }
    return false;
}

static void get_direction(const PlayerCore* self, const State* game_state, float* dx, float* dy) {
    *dx = 0.0f;
    *dy = 0.0f;

    if (is_key_down(KEYS_RIGHT, KEYS_PER_DIRECTION)) *dx = 1.0f;
    if (is_key_down(KEYS_LEFT, KEYS_PER_DIRECTION)) *dx = -1.0f;
    if (is_key_down(KEYS_UP, KEYS_PER_DIRECTION)) *dy = -1.0f;
    if (is_key_down(KEYS_DOWN, KEYS_PER_DIRECTION)) *dy = 1.0f;

    if (IsMouseButtonDown(MOUSE_BUTTON_LEFT)) {
        Vector2 pos = game_state->mouse;
        float diff_x = pos.x - self->x + game_state->cx;
        float diff_y = pos.y - self->y;
        float offset = self->speed * 0.3f;

        if (fabsf(diff_x) > offset || fabsf(diff_y) > offset) {
            float angle = atan2f(diff_x, diff_y);
            *dx = sinf(angle);
            *dy = cosf(angle);
        }
    }
}

void player_load(PlayerCore* self) {
    strcpy(self->element, "fire");
    self->x = GAME_WIDTH * 0.5f;
    self->y = GAME_HEIGHT * 0.8f;
    self->dp = 5.0f;
    self->scale = 1.0f;
    self->hp = 100.0f;
    self->xp = 0.0f;
    self->lvl = 0;
    self->speed = 10;
    self->dead = false;
    fire_load(&self->flame);
}

void player_update(PlayerCore* self, State* game_state) {
    float w, h;
    fire_get_dimensions(&self->flame, &w, &h);

    float dx, dy;
    get_direction(self, game_state, &dx, &dy);

    dx *= self->speed;
    dy *= self->speed;

    float eye_bound = GAME_WIDTH / 5.0f;

    if ((self->x + dx < game_state->cx + eye_bound && game_state->cx > game_state->start_x) ||
        (self->x + dx > game_state->cx + GAME_WIDTH - eye_bound &&
         game_state->cx < game_state->gw + game_state->start_x - GAME_WIDTH)) {
        game_state->cx += dx;
    }

    if (self->x + dx < game_state->cx + w * 0.5f && dx < 0) {
        self->x = game_state->cx + w * 0.5f;
    } else if (self->x + dx > game_state->cx + GAME_WIDTH - w * 0.5f) {
        self->x = game_state->cx + GAME_WIDTH - w * 0.5f;
    } else {
        self->x += dx;
    }

    if (self->y + dy > GAME_HEIGHT && dy > 0) {
        self->y = GAME_HEIGHT;
    } else if (self->y + dy < START_Y + h * 0.3f && dy < 0) {
        self->y = START_Y + h * 0.3f;
    } else {
        self->y += dy;
    }

    fire_update(&self->flame, self->x, self->y - h);
}

void player_burn(PlayerCore* self, float fuel) {
    (void)self;
    (void)fuel; 
}

void player_get_hitbox(const PlayerCore* self, float* hitbox) {
    float w, h;
    fire_get_dimensions(&self->flame, &w, &h);
    hitbox[0] = self->x - w;
    hitbox[1] = self->x;
    hitbox[2] = self->y - h * 0.7f;
    hitbox[3] = self->y - h * 0.1f;
}

void player_draw(const PlayerCore* self, int i) {
    fire_draw(&self->flame, i);
}

void player_unload(PlayerCore* self) {
    fire_unload(&self->flame);
}
