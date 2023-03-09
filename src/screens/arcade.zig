const std = @import("std");
const rl = @import("../raylib/raylib.zig");
const Screen = @import("screen.zig").Screen;
const Player = @import("../player.zig").Player;
const Ground = @import("../ground.zig").Ground;
const Sky = @import("../sky.zig").Sky;
const Plant = @import("../plant.zig").Plant;
const Level = @import("../level.zig").Level;
const levels = @import("../levels.zig");
const HUD = @import("../hud.zig").HUD;
const tokenize = std.mem.tokenize;

const log = @import("../log.zig");
const config = @import("../config.zig");
const utils = @import("../utils.zig");
const Time = @import("../config.zig").Time;

const sort = std.sort.sort;
const print = std.debug.print;
const ArrayList = std.ArrayList;
const rand = std.crypto.random;

pub const screen = Screen{
    .initFn = init,
    .updateFn = update,
    .drawFn = draw,
    .staticDrawFn = staticDraw,
    .deinitFn = deinit,
};

const ZEntities = enum { player, plant, none };
const ZEntity = struct {
    item: ZEntities = ZEntities.none,
    index: [3]usize = [3]usize{ 0, 0, 0 },
    z: u16 = 0,
};

fn compareLeq(_: void, left: ZEntity, right: ZEntity) bool {
    if (left.z == right.z) {
        return left.item == ZEntities.player;
    } else {
        return left.z < right.z;
    }
}

var sky = Sky{};
var hud = HUD{};
var player: Player = Player{};
var ground: Ground = Ground{};
var to_order: ArrayList(ZEntity) = undefined;
var item_count: usize = 0;
var playing: bool = true;
var fade_in: u8 = 255;
var level: Level = levels.daisyland;
var music: rl.Music = undefined;
fn init(allocator: std.mem.Allocator) !void {
    music = rl.LoadMusicStream(level.music);
    
    rl.PlayMusicStream(music);

    try sky.init(allocator);
    try ground.init(allocator, level);
    player.init(allocator);

}

fn check_tile_collision() void {
    // check tile collision with player
    for (ground.tiles.items) |*row, i| {
        _ = i;
        for (row.items) |*t, j| {
            _ = j;
            if (t.pos.x + t.size.x > config.cx and t.pos.x - t.size.x < config.cx + config.screen_width) {
                // find collision with player
                var px = player.position.x;
                var py = player.position.y;
                var pr = player.get_radius();

                if (t.pos.y - t.size.y < py + pr and t.pos.y > py - pr) {
                    if (t.pos.x - t.size.x < px + pr and t.pos.x + t.size.x > px - pr) {
                        t.burnTimer = 2;
                    }
                }
            }
        }
    }
}

// main update game loop
fn update(allocator: std.mem.Allocator, dt: f32) !void {
    rl.UpdateMusicStream(music);   // Update music buffer with new stream data

    if (fade_in > 10) {
        fade_in -= 10;
        player.frozen = true;
        if (fade_in < 10) {
            player.frozen = false;
        }
    }

    config.elapsed_time += dt * config.time_speed;

    sky.update(dt);
    try ground.update(allocator, dt);
    try player.update();

    check_tile_collision();

    // z order sorting
    to_order.deinit();
    to_order = ArrayList(ZEntity).init(allocator);

    // plants to_order
    for (ground.tiles.items) |*row, i| {
        for (row.items) |*t, j| {
            for (t.plants.items) |*p, k| {
                try p.update(allocator);
                var ze = ZEntity{ .index = [3]usize{ i, j, k }, .z = @floatToInt(u16, p.start_y), .item = ZEntities.plant };
                try to_order.append(ze);
            }
        }
    }

    // player to sort
    var p_ze = ZEntity{ .z = @floatToInt(u16, player.position.y + player.get_radius()), .item = ZEntities.player };
    try to_order.append(p_ze);

    sort(ZEntity, to_order.items, {}, compareLeq);
}

// unaffected by camera movement
pub fn staticDraw() void {
    sky.predraw();
    ground.predraw();
    hud.predraw();
}

// draw function
pub fn draw() void {
    ground.draw();

    for (to_order.items) |*ze, i| {
        _ = i;
        switch (ze.item) {
            ZEntities.player => {
                player.draw();
            },
            ZEntities.plant => {
                var p = ground.tiles.items[ze.index[0]].items[ze.index[1]].plants.items[ze.index[2]];
                p.draw();
            },
            ZEntities.none => {},
        }
    }

    var start = rl.Vector2{ .x = 0, .y = 0 };
    var end = rl.Vector2{ .x = config.screen_width, .y = config.screen_height };

    var color = rl.BLACK;
    color.a = fade_in;
    rl.DrawRectangleV(start, end, color);
}
pub fn deinit() void {
    rl.UnloadMusicStream(music);   // Unload music stream buffers from RAM
    sky.deinit();
    ground.deinit();
    player.deinit();
    to_order.deinit();
}
