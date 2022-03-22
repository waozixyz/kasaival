const std = @import("std");
const rl = @import("raylib");

const lyra = @import("../lyra.zig");
const player = @import("../player.zig");
const ground = @import("../ground.zig");
const sky = @import("../sky.zig");

const sort = std.sort.sort;
const print = std.debug.print;
const ArrayList = std.ArrayList;
const test_allocator = std.testing.allocator;

const ZEntities = enum {
    player,
    ground,
    none
};
const ZEntity = struct {
    item: ZEntities,
    index : usize,
    z: u16,
};

fn compareLeq(context: void, left: ZEntity, right: ZEntity) bool {
    _ = context;
    if (left.item != ZEntities.none and right.item != ZEntities.none) {
        if (left.item != right.item) {
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
    else {
        return false;
    }
}
pub const GameScreen = struct{
    sky: sky.Sky,
    player: player.Player,
    ground: ground.Ground,
    to_order: ArrayList(ZEntity),

    pub fn load(self: *GameScreen) void {
        self.sky.load();
        self.ground.load();
        self.player.load();

    }
    fn append_to_order(self: *GameScreen, ze: ZEntity) !void {
        var append = try self.to_order.append(ze);
        _ = append;
    }

    pub fn update(self: *GameScreen) void {
        self.sky.update();
        self.ground.update();
        self.player.update();
        // add ground tiles to_order
        var item_count: usize = 0;
        for (self.ground.tiles.items) |*t, i| {
            _ = i;  
            var flag: bool = false;
            var x:[3]f32 = .{t.v1.x, t.v2.x, t.v3.x};
            for (x) |xval, j| {
                _ = j;
                if (xval > lyra.cx and xval < lyra.cx + lyra.screen_width) {
                    flag = true;
                    break;
                }
            }
            if (flag) {
                // find the lower y value in the tri-vector tile
                var y:[3]f32 = .{t.v1.y, t.v2.y, t.v3.y};
                var z:f32 = 999999;
                for (y) |yval, j| {
                    _ = j;

                    if (yval < z) {
                        z = yval;
                    }
                }
                // find collision with player
                var px = self.player.position.x;
                var py = self.player.position.y;
                var pr = self.player.get_radius();
                if (z > py - pr*2 and z < py) {
                    if (x[0] > px - pr or x[1] > px - pr or x[2] > px - pr) {
                        if (x[0] < px + pr or x[1] < px + pr or x[2] < px + pr) {
                            t.burn();
                        }
                    }

                }
                // make new zentity 
                var ze = ZEntity{
                    .index = i,
                    .z = @floatToInt(u16, z),
                    .item = ZEntities.ground
                };
                // add to z_entity order list
                if (item_count >= self.to_order.items.len) {
                    append_to_order(self, ze) catch |err| {
                        std.log.info("Caught error: {s}", .{ err });
                    };
                }
                else {
                    self.to_order.items[item_count] = ze;
                }
                item_count += 1;
            } 
        }

        // add player particles to_order
        for (self.player.flame.particles.items) |*p, i| {
            var ze = ZEntity{
                .index = i,
                .z = @floatToInt(u16, p.start_y) + 1,
                .item = ZEntities.player
            };
            if (item_count + i >= self.to_order.items.len) {
                append_to_order(self, ze) catch |err| {
                    std.log.info("Caught error: {s}", .{ err });
                };
            }
            else {
                self.to_order.items[item_count + i] = ze;
            }
        }
        item_count += self.player.flame.particles.items.len - 1;
        
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
    pub fn predraw(self: *GameScreen) void {
        self.sky.predraw();
        self.ground.predraw();

    }
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
                ZEntities.none => {}

            }
        }
    //    
    //    
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
        .sky = sky.new(),
        .ground = ground.new(),
        .player = player.new(),
        .to_order = ArrayList(ZEntity).init(test_allocator),
        };
}
