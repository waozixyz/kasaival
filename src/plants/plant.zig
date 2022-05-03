const std = @import("std");
const rl = @import("raylib");

const print = std.debug.print;
const math = std.math;
const ArrayList = std.ArrayList;
const test_allocator = std.testing.allocator;
const rand = std.crypto.random;

pub const Branch = struct {
    deg: i32,
    v1: rl.Vector2,
    v2: rl.Vector2,
    w: f32,
    h: f32,
    color: rl.Color,
    pub fn get_z(self: *Branch) f32 {
        var rtn = self.v1.y;
        if (self.v2.y > rtn) {
            rtn = self.v2.y;
        }
        return rtn;
    }
};
pub const Leaf = struct {
    row: usize,
    v1: rl.Vector2,
    v2: rl.Vector2,
    r: f32,
    color: rl.Color
};

const deg_to_rad: f32 = math.pi / 180.0;

fn get_color(cs: [6]u8) rl.Color {
    const r = rand.intRangeAtMost(u8, cs[0], cs[1]);
    const g = rand.intRangeAtMost(u8, cs[2], cs[3]);
    const b = rand.intRangeAtMost(u8, cs[4], cs[5]);
    return rl.Color{ .r = r, .g = g, .b = b, .a = 255};
}

fn get_rot_x(deg: i32) f32 {
    return math.cos(@intToFloat(f32, deg) * deg_to_rad);
}
fn get_rot_y(deg: i32) f32 {
    return math.sin(@intToFloat(f32, deg) * deg_to_rad);
}
pub const Plant = struct{
    branches: ArrayList(ArrayList(Branch)),
    leaves: ArrayList(Leaf),
    leaf_chance: f32,
    max_row: i32,
    current_row: usize,
    split_chance: i32,
    split_angle: [2]i32,
    cs_branch: [6]u8,
    cs_leaf: [6]u8,
    left_x: f32,
    right_x: f32,
    grow_timer: i32,
    grow_time: i32,
    w: f32,
    h: f32,
    fn append_row(self: *Plant) !void {
        var append = try self.branches.append((ArrayList(Branch).init(test_allocator)));
        _ = append;
    }
    fn append_branch(self: *Plant, row: usize, b: Branch) !void {
        var append = try self.branches.items[row].append(b);
        _ = append;
    }
    fn append_leaf(self: *Plant, l: Leaf) !void {
        var append = try self.leaves.append(l);
        _ = append;
    }
    fn get_angle(self: *Plant) i32 {
        return rand.intRangeAtMost(i32, self.split_angle[0], self.split_angle[1]);
    }
    fn add_branch(self: *Plant, deg: i32, b: *Branch) void {
        const w = b.w * 0.9;
        const h = b.h * 0.95;
        const px = b.v2.x;
        const py = b.v2.y;
        const nx = px + get_rot_x(deg) * h;
        const ny = py + get_rot_y(deg) * h;
        const c = get_color(self.cs_branch);
        self.append_branch(self.current_row + 1, Branch{
            .deg = deg,
            .v1 = rl.Vector2{.x = px, .y = py},
            .v2 = rl.Vector2{.x = nx, .y = ny},
            .w = w,
            .h = h,
            .color = c}) catch |err| {
            std.log.info("Caught error: {s}", .{ err });
        };
        var leaf_chance = rand.float(f32) * @intToFloat(f32, self.current_row) / @intToFloat(f32, self.max_row);
        if (leaf_chance > self.leaf_chance) {
            var div_x = get_rot_x(deg * 2) * w;
            var div_y = get_rot_y(deg * 2) * w;

            self.append_leaf(Leaf{
                .row = self.current_row,
                .r = w,
                .v1 = rl.Vector2{.x = nx + div_x, .y = ny + div_y},
                .v2 = rl.Vector2{.x = nx - div_x, .y = ny - div_y},
                .color = get_color(self.cs_leaf)
            }) catch |err| {
                std.log.info("Caught error: {s}", .{ err });
            };
        }

        if (nx < self.left_x) {
            self.left_x = nx;
        } else if (nx > self.right_x) {
            self.right_x = nx + w;
        }   
    }
    pub fn get_z(self: *Plant) f32 {
        return self.branches.items[0].items[0].v1.y;

    }
    fn get_next_pos(self: *Plant, a: f32, b: f32) f32 {
        return b + (a - b) * @intToFloat(f32, self.grow_timer) / @intToFloat(f32, self.grow_time); 
    }
    fn grow(self: *Plant) void {
        self.append_row() catch |err| {
            std.log.info("Caught error: {s}", .{ err });
        };
        var prev_row = self.branches.items[self.current_row].items;
        
        for (prev_row) |*b, i| {
            _ = i;
            var split = rand.intRangeAtMost(i32, 0, 100);
            if (self.split_chance > split) {
                self.add_branch(b.deg - self.get_angle(), b);
                self.add_branch(b.deg + self.get_angle(), b);
            } else {
                self.add_branch(b.deg, b);
            }
        }
        self.current_row += 1;
    }
    pub fn load(self: *Plant, x: f32, y: f32, random_row: bool) void {
        var angle: i32 = -90;
        self.append_row() catch |err| {
            std.log.info("Caught error: {s}", .{ err });
        };
        self.append_branch(0, Branch{
            .deg = angle,
            .v1 = rl.Vector2{ .x = x, .y = y},
            .v2 = rl.Vector2{ .x = x, .y = y - self.h},
            .w = self.w,
            .h = self.h,
            .color = get_color(self.cs_branch),
        }) catch |err| {
            std.log.info("Caught error: {s}", .{ err });
        };
        self.grow_timer = rand.intRangeAtMost(i32, 0, self.grow_time);
        if (random_row) {
            var grow_to_row = rand.intRangeAtMost(i32, 0, self.max_row);
            while (self.current_row < grow_to_row) {
                self.grow();
            }
        }
    }
    pub fn update(self: *Plant) void {
        if (self.grow_timer > 0) {
            self.grow_timer -= 1;
        }
        if (self.grow_timer == 0 and self.current_row < self.max_row) {
            self.grow();
            self.grow_timer = self.grow_time;
        } 
    }
    pub fn draw(self: *Plant) void {
        for (self.branches.items) |*row, i| {
            for (row.items) |*b, j| {
                _ = j;
                    
                var v2 = b.v2;

                if (i == self.current_row and self.grow_timer > 0) {
                    v2 = rl.Vector2{
                        .x = self.get_next_pos(b.v1.x, v2.x),
                        .y = self.get_next_pos(b.v1.y, v2.y)
                    };
                }
            
                rl.DrawLineEx(b.v1, v2, b.w, b.color);
            }
            for (self.leaves.items) |*l, j| {
                _ = j;
                if (l.row < i and !(i == self.current_row and self.grow_timer > 0)) {
                    rl.DrawCircleV(l.v1, l.r, l.color);
                    rl.DrawCircleV(l.v2, l.r, l.color);
                }
            }
        }
    
    }
    pub fn unload(_: *Plant) void {

    }
};

pub fn new() Plant {
    return Plant{
        .branches = ArrayList(ArrayList(Branch)).init(test_allocator),
        .leaves = ArrayList(Leaf).init(test_allocator),
        .leaf_chance = 0.5,
        .max_row = 10,
        .current_row = 0,
        .w = 10,
        .h = 40,
        .split_chance = 50,
        .split_angle = .{20, 30},
        .cs_branch = .{125, 178, 122, 160, 76, 90},
        .cs_leaf = .{150, 204, 190, 230, 159, 178},
        .left_x = 9999999,
        .right_x = -9999999,
        .grow_timer = 0,
        .grow_time = 20,
    };
}
