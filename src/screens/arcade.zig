const std = @import("std");
const rl = @import("../raylib/raylib.zig");
const Screen = @import("screen.zig").Screen;
const lyra = @import("../lyra.zig");
const Player = @import("../player.zig").Player;
const Ground = @import("../ground.zig").Ground;
const Sky = @import("../sky.zig").Sky;
const Plant = @import("../plants/plant.zig").Plant;
const log = @import("../log.zig");

const sort = std.sort.sort;
const print = std.debug.print;
const ArrayList = std.ArrayList;
const rand = std.crypto.random;


pub const screen = Screen{
    .initFn = init,
    .updateFn = update,
    .drawFn = draw,
    .predrawFn = predraw,
    .deinitFn = deinit,
};


const PlantSpawner = struct {
    frequency: f32,
    elapsed: f32,
};
const ZEntities = enum {
    player,
    plant,
    none
};
const ZEntity = struct {
    item: ZEntities,
    index : [3]usize,
    z: u16,
};

fn compareLeq(_: void, left: ZEntity, right: ZEntity) bool {
    if (left.item != ZEntities.none and right.item != ZEntities.none and left.item != right.item) {
        if (left.z == right.z) {
            return left.item == ZEntities.player;
        } else {
            return left.z < right.z;
        }
    } else {
        return false;
    }
}

var sky = Sky{};
var player: Player = Player{};
var ground: Ground = Ground{};
var plants: ArrayList(Plant) = undefined;
var plant_spawners: ArrayList(PlantSpawner) = undefined;
var to_order: ArrayList(ZEntity) = undefined;
var elapsed_time: f32 = 0;
var item_count: usize = 0;

fn init(allocator: std.mem.Allocator) !void {
    plants = ArrayList(Plant).init(allocator);
    plant_spawners = ArrayList(PlantSpawner).init(allocator);
    to_order = ArrayList(ZEntity).init(allocator);

    sky.init();
    ground.init(allocator);
    player.init(allocator);
    
    try plant_spawners.append(.{
        .frequency = 2,
        .elapsed = 0,
    });
}

fn add_to_order(ze: ZEntity) void {
    // add to z_entity order list
    if (item_count == to_order.items.len) {
        to_order.append(ze) catch |err| log.err("ERROR: {?}", .{err});
    } else {
        to_order.items[item_count] = ze;
    }
    item_count += 1;
}

// sort plants
fn sort_plants() void {
    // plants to_order
    for (plants.items) |*p, i| {
        var ze = ZEntity{
            .index = .{i, 0, 0},
            .z = @floatToInt(u16, p.get_z()),
            .item = ZEntities.plant
        };
        add_to_order(ze);
    }
}

// spawn plant
fn plant_spawning(allocator: std.mem.Allocator) !void {
    // plant spawning
    for (plant_spawners.items) |*s, i| {
        _ = i;
        if (elapsed_time > s.elapsed + s.frequency) {
            s.elapsed = elapsed_time;
            var p = Plant{};
            var x = rl.GetRandomValue(@floatToInt(i32, lyra.start_x), @floatToInt(i32, lyra.game_width + lyra.start_x));
            var y = rl.GetRandomValue(@floatToInt(i32, lyra.start_y), @floatToInt(i32, lyra.game_height));
            try p.init(allocator, @intToFloat(f32, x), @intToFloat(f32, y), false);
            try plants.append(p);
        }
    }
}

fn check_tile_collision() void {
    // check tile collision with player
    for (ground.tiles.items) |*row, i| {
        _ = i;
        for (row.items) |*t, j| {
            _ = j;
            if ( t.x > lyra.cx and t.x + t.h < lyra.cx + lyra.screen_width) {
                // find collision with player
                var px = player.position.x;
                var py = player.position.y;
                var pr = player.get_radius();
                if (t.y + t.h > py - pr * 0.5 and t.y < py + pr * 0.5) {
                    if (t.x + t.h > px - pr  and t.x < px + pr) {
                        t.burn();
                    }
                }
            
            } 
        }
    }
}

// main update game loop
fn update(allocator: std.mem.Allocator, dt: f32) !void {
    elapsed_time += dt;
    sky.update();
    ground.update();
    player.update();
    
    check_tile_collision();
    try plant_spawning(allocator);

    // update plants
    for (plants.items) |*p, i| {
        _ = i;
        p.update(allocator, dt) catch |err| log.err("ERROR: {?}", .{err});
    }
        
    // z order sorting
    item_count = 0;
    sort_plants();

    var p_ze = ZEntity{
        .index = .{0, 0, 0},
        .z = @floatToInt(u16, player.position.y),
        .item = ZEntities.player
    };

    add_to_order(p_ze);

    // reset unused slots in arraylist to_order
    while (item_count < to_order.items.len) {
        var ze = ZEntity{
            .index = .{0, 0, 0},
            .z = 0,
            .item = ZEntities.none
        };
        add_to_order(ze);
    }
    var slice = to_order.items[0..item_count];
    sort(ZEntity, slice, {}, compareLeq);
}

// unaffected by camera movement
pub fn predraw() void {
    sky.predraw();
    ground.predraw();
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
              //  var p = plants.items[ze.index[0]];
             //   p.draw();
            },
            ZEntities.none => {}

        }
    }
}
pub fn deinit() void {
    sky.deinit();
    ground.deinit();
    player.deinit();
    for (plants.items) |*p, i| {
        _ = i;
        p.deinit();
    }
    plant_spawners.deinit();
    plants.deinit();
    to_order.deinit();
}
