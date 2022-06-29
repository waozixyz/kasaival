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
    ground,
    plant,
    none
};
const ZEntity = struct {
    item: ZEntities,
    index : [3]usize,
    z: u16,
};

fn compareLeq(context: void, left: ZEntity, right: ZEntity) bool {
    _ = context;
    if (left.item != ZEntities.none and right.item != ZEntities.none and left.item != right.item) {
        if (left.z == right.z) {
            if (left.item == ZEntities.player) {
                return true;
            }
            else {
                return false;
            }
        } else {
            return left.z < right.z;
        }
    }
    else {
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
    

fn append_to_order(ze: ZEntity) !void {
    _ = try to_order.append(ze);
}

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

fn sort_tile_rows() void {
    // add ground tiles to_order
    for (ground.tiles.items) |*row, i| {
        var t = row.items[0];
        // make new zentity 
        var ze = ZEntity{
            .index = .{i, 0, 0},
            .z = @floatToInt(u16, t.y),
            .item = ZEntities.ground
        };

        add_to_order(ze);
    }
}


fn check_tile_collision() void {
    // check tile collision with player
    for (ground.tiles.items) |*row, i| {
        _ = i;
        for (row.items) |*t, j| {
            _ = j;
            if ( t.get_right_x() > lyra.cx and t.get_left_x() < lyra.cx + lyra.screen_width) {
                // find collision with player
                var px = player.position.x;
                var py = player.position.y;
                var pr = player.get_radius();
                if (t.y > py - pr * 0.5 and t.y - t.h * 0.5 < py + pr * 0.5) {
                    if (t.get_right_x() > px - pr  and t.get_left_x() < px + pr) {
                        t.burn();
                    }
                }
            
            } 
        }
    }
}
// go through each flam particle and add it as a zentity for sorting
fn sort_player_particles() void {
    // add player particles to_order
    for (player.flame.particles.items) |*p, i| {
        var ze = ZEntity{
            .index = .{i, 0, 0},
            .z = p.start_y ,
            .item = ZEntities.player
        };

        add_to_order(ze);
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
    sort_tile_rows();
    sort_player_particles();
    sort_plants();


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
    for (to_order.items) |*ze, i| {
        _ = i;
        switch (ze.item) {
            ZEntities.ground => {
                ground.draw(ze.index[0]);
            },
            ZEntities.player => {
                player.draw(ze.index[0]);
            },
            ZEntities.plant => {
                var p = plants.items[ze.index[0]];
                p.draw();
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
