const std = @import("std");
const rl = @import("raylib");

const lyra = @import("../lyra.zig");
const player = @import("../player.zig");
const ground = @import("../ground.zig");
const sky = @import("../sky.zig");
const plant = @import("../plant.zig");


const sort = std.sort.sort;
const print = std.debug.print;
const ArrayList = std.ArrayList;
const test_allocator = std.testing.allocator;

const PlantSpawner = struct {
    frequency: f32,
    elapsed: f32,
    item: plant.Plant,
};
const ZEntities = enum {
    player,
    ground,
    plant,
    none
};
const ZEntity = struct {
    item: ZEntities,
    index : usize,
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

pub const GameScreen = struct{
    sky: sky.Sky,
    player: player.Player,
    ground: ground.Ground,
    plants: ArrayList(plant.Plant),
    plant_spawners: ArrayList(PlantSpawner),
    to_order: ArrayList(ZEntity),
    elapsed_time: f32,
    pub fn load(self: *GameScreen) void {
        self.sky.load();
        self.ground.load();
        self.player.load();
        
        var spawner = PlantSpawner{
            .frequency = 2,
            .elapsed = 0,
            .item = plant.new(),
        };
        self.append_plant_spawner(spawner) catch |err| {
            std.log.info("Caught error: {s}", .{ err });
        };
    }
    fn append_plant(self: *GameScreen, p: plant.Plant) !void {
        _ = try self.plants.append(p);
    }
    fn append_plant_spawner(self: *GameScreen, spawner: PlantSpawner) !void {
        _ = try self.plant_spawners.append(spawner);
    }
    fn append_to_order(self: *GameScreen, ze: ZEntity) !void {
        _ = try self.to_order.append(ze);
    }

    fn sort_tiles(self: *GameScreen, item_count: usize) usize {
        var rtn = item_count;
        // add ground tiles to_order
        for (self.ground.tiles.items) |*t, i| {
            _ = i;  
            if ( t.get_right_x() > lyra.cx and t.get_left_x() < lyra.cx + lyra.screen_width) {
                // find collision with player
                var px = self.player.position.x;
                var py = self.player.position.y;
                var pr = self.player.get_radius();
                if (t.y > py - pr * 0.5 and t.y - t.h * 0.5 < py + pr * 0.5) {
                    if (t.get_right_x() > px - pr  and t.get_left_x() < px + pr) {
                        t.burn();
                    }
                }
                // make new zentity 
                var ze = ZEntity{
                    .index = i,
                    .z = @floatToInt(u16, t.y),
                    .item = ZEntities.ground
                };
                // add to z_entity order list
                if (rtn >= self.to_order.items.len) {
                    self.append_to_order(ze) catch |err| {
                        std.log.info("Caught error: {s}", .{ err });
                    };
                }
                else {
                    self.to_order.items[rtn] = ze;
                }
                rtn += 1;
            } 
        }
        return rtn;
    }
    // go through each flam particle and add it as a zentity for sorting
    fn sort_player_particles(self: *GameScreen, item_count: usize) usize {
        var rtn = item_count;
        // add player particles to_order
        for (self.player.flame.particles.items) |*p, i| {
            var ze = ZEntity{
                .index = i,
                .z = @floatToInt(u16, p.start_y) + 1,
                .item = ZEntities.player
            };
            if (rtn + i >= self.to_order.items.len) {
                self.append_to_order(ze) catch |err| {
                    std.log.info("Caught error: {s}", .{ err });
                };
            }
            else {
                self.to_order.items[rtn + i] = ze;
            }
        }
        rtn += self.player.flame.particles.items.len - 1;
        return rtn;
    }
    // main update game loop
    pub fn update(self: *GameScreen) void {
        var delta = rl.GetFrameTime();
        self.elapsed_time += delta;
        self.sky.update();
        self.ground.update();
        self.player.update();
        
        // plant spawning
        for (self.plant_spawners.items) |*s, i| {
            _ = i;
            if (self.elapsed_time > s.elapsed + s.frequency) {
                s.elapsed = self.elapsed_time;
                self.append_plant(s.item) catch |err| {
                    std.log.info("Caught error: {s}", .{ err });
                };
            }
        }
        // z order sorting
        var item_count: usize = 0;
        item_count = self.sort_tiles(item_count);
        item_count = self.sort_player_particles(item_count);
       
        // reset unused slots in arraylist to_order
        while (self.to_order.items.len > item_count) {
            var ze = ZEntity{
                .index = 0,
                .z = 0,
                .item = ZEntities.none
            };
            self.to_order.items[item_count] = ze;
            item_count += 1;
        }
        var slice = self.to_order.items[0..item_count];
        sort(ZEntity, slice, {}, compareLeq);


    }
    // unaffected by camera movement
    pub fn predraw(self: *GameScreen) void {
        self.sky.predraw();
        self.ground.predraw();

    }
    // draw function
    pub fn draw(self: *GameScreen) void {
        for (self.to_order.items) |*ze, i| {
            _ = i;
            switch (ze.item) {
                ZEntities.ground => {
                    self.ground.draw(ze.index);
                },
                ZEntities.player => {
                    self.player.draw(ze.index);
                },
                ZEntities.plant => {
                },
                ZEntities.none => {}

            }
        }
    }
    pub fn unload(self: *GameScreen) void {
        self.sky.unload();
        self.ground.unload();
        self.player.unload();
        self.to_order.deinit();
    }
};


pub fn new() GameScreen {
    return GameScreen{
        .elapsed_time = 0,
        .sky = sky.new(),
        .ground = ground.new(),
        .player = player.new(),
        .plants = ArrayList(plant.Plant).init(test_allocator),
        .plant_spawners = ArrayList(PlantSpawner).init(test_allocator),
        .to_order = ArrayList(ZEntity).init(test_allocator),
    };
}
