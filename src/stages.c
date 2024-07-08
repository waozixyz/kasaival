// stages.c
#include "stages.h"
#include "config.h"
#include <string.h>
#include <stdio.h>

static const char* PATH = "resources/scenery/";
static const int OCEAN[] = {50, 60, 220};
static const int BEACH[] = {200, 180, 60};
static const int SHRUBLAND[] = {180, 120, 10};
static const int CAVELAND[] = {60, 0, 40};


Stage* create_empty_stage(void) {

    Stage* stage = (Stage*)MemAlloc(sizeof(Stage));

    if (stage == NULL) {
        TraceLog(LOG_ERROR, "Failed to allocate memory for shrubland stage");
        return NULL;
    }

    memset(stage, 0, sizeof(Stage));

    strncpy(stage->music, "", sizeof(stage->music) - 1);
    stage->music[sizeof(stage->music) - 1] = '\0'; // Ensure null-termination

    // Add a single scene
    stage->scenes[0] = (Scene){1500, {21, 0, 13, 255}};
    stage->scene_count = 1;

    // Add a single spawner
    stage->spawners[0] = (Spawner){ENTITY_KALI, 3500, 7000, 1.0f, 0.0f};
    stage->spawner_count = 1;

    return stage;
}

Stage* create_shrubland(void) {
    Stage* stage = (Stage*)MemAlloc(sizeof(Stage));
    if (stage == NULL) {
        TraceLog(LOG_ERROR, "Failed to allocate memory for shrubland stage");
        return NULL;
    }
    memset(stage, 0, sizeof(Stage));


    strcpy(stage->music, "spring/maintheme.ogg");

    // Add start
    stage->scenes[stage->scene_count++] = (Scene){1500, {21, 0, 13, 255}};

    // Add ocean
    stage->scenes[stage->scene_count++] = (Scene){1500, {OCEAN[0], OCEAN[1], OCEAN[2], 255}};

    // Add beach
    stage->scenes[stage->scene_count++] = (Scene){1000, {BEACH[0], BEACH[1], BEACH[2], 255}};

    // Add shrubland
    stage->scenes[stage->scene_count++] = (Scene){7000, {SHRUBLAND[0], SHRUBLAND[1], SHRUBLAND[2], 255}};

    // Add beach
    stage->scenes[stage->scene_count++] = (Scene){1000, {BEACH[0], BEACH[1], BEACH[2], 255}};

    // Add ocean
    stage->scenes[stage->scene_count++] = (Scene){1500, {OCEAN[0], OCEAN[1], OCEAN[2], 255}};

    // Add end for color gradient
    stage->scenes[stage->scene_count++] = (Scene){0, {21, 0, 13, 255}};

    // Add shrub spawner
    stage->spawners[stage->spawner_count++] = (Spawner){ENTITY_KALI, 3500, 7000, 1.0f, 0.0f};

    // Add background items if needed
    // stage->bg[stage->bg_count++] = (BGItem){"path/to/bg.png", 0.5f, 0, 0};

    return stage;
}

void stage_load(Stage* stage, State* game_state) {
    // Load music
    // char music_path[256];
    // snprintf(music_path, sizeof(music_path), "resources/music/%s", stage->music);
    // game_state->music = LoadMusicStream(music_path);
    // PlayMusicStream(game_state->music);

    // Calculate game width
    game_state->gw = 0;
    for (int i = 0; i < stage->scene_count; i++) {
        game_state->gw += stage->scenes[i].width;
    }

    // Set start_x
    game_state->start_x = (int)(-((float)game_state->gw) * 0.5f + GAME_WIDTH * 0.5f);

    // Adjust spawner positions
    for (int i = 0; i < stage->spawner_count; i++) {
        stage->spawners[i].start_x += game_state->start_x;
        stage->spawners[i].end_x += game_state->start_x;
    }

    // Create ground (this should be done in the game_load function)
    // self->ground = ground_init(&self->ground);

    // Add ground sections
    float x = (float)game_state->start_x;
    for (int i = 0; i < stage->scene_count - 1; i++) {
        int direction = (i < stage->scene_count * 0.5f) ? 1 : 0;
        Color colors[2] = {stage->scenes[i].color, stage->scenes[i + 1].color};
        // This function call should be done in the game_load function
        // x = ground_add_section(&self->ground, x, stage->scenes[i].width, colors, direction);
    }

    // Load player and sky (these should be done in the game_load function)
    // player_load(&self->player);
    // sky_load(&self->sky);
}