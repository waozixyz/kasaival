const std = @import("std");
const rl = @import("../raylib/raylib.zig");

const print = std.debug.print;
const math = std.math;
const ArrayList = std.ArrayList;
const lyra = @import("../lyra.zig");
const log = @import("../log.zig");

pub const Branch = struct {
    deg: i32,
    v1: rl.Vector2,
    v2: rl.Vector2,
    w: f32,
    h: f32,
    color: rl.Color,
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
    const r = @intCast(u8, rl.GetRandomValue(cs[0], cs[1]));
    const g = @intCast(u8, rl.GetRandomValue(cs[2], cs[3]));
    const b = @intCast(u8, rl.GetRandomValue(cs[4], cs[5]));
    return rl.Color{ .r = r, .g = g, .b = b, .a = 255};
}


fn get_rot_x(deg: i32) f32 {
    return math.cos(@intToFloat(f32, deg) * deg_to_rad);
}
fn get_rot_y(deg: i32) f32 {
    return math.sin(@intToFloat(f32, deg) * deg_to_rad);
}

pub const Plant = struct {
    branches: ArrayList(ArrayList(Branch)) = undefined,
    leaves: ArrayList(Leaf) = undefined,
    leaf_chance: f32 = 0.5,
    max_row: i32 = 5,
    current_row: usize = 0,
    split_chance: i32 = 40,
    split_angle: [2]i32 = .{20, 30},
    cs_branch: [6]u8 =  .{125, 178, 122, 160, 76, 90},
    cs_leaf: [6]u8 = .{150, 204, 190, 230, 159, 178},
    left_x: f32 = 9999999,
    right_x: f32 = -9999999,
    grow_timer: i32 = 0,
    grow_time: i32 = 20,
    scale: f16 = 1,
    w: f32 = 10,
    h: f32 = 15,
    start_y: f32 = 0,
    fn append_row(self: *Plant, allocator: std.mem.Allocator) !void {
        var append = try self.branches.append((ArrayList(Branch).init(allocator)));
        _ = append;
    }
    fn get_angle(self: *Plant) i32 {
        return rl.GetRandomValue(self.split_angle[0], self.split_angle[1]);
    }
    fn add_branch(self: *Plant, deg: i32, b: *Branch) void {
        const bw = b.w * 0.9;
        const bh = b.h * 0.95;
        const px = b.v2.x;
        const py = b.v2.y;
        const nx = px + get_rot_x(deg) * bh;
        const ny = py + get_rot_y(deg) * bh;
        const c = get_color(self.cs_branch);
        

        self.branches.items[self.current_row + 1].append(Branch{
            .deg = deg,
            .v1 = rl.Vector2{.x = px, .y = py},
            .v2 = rl.Vector2{.x = nx, .y = ny},
            .w = bw,
            .h = bh,
            .color = c}) catch |err| log.err("ERROR: {?}", .{err});

        var chance = (@intToFloat(f32, rl.GetRandomValue(0, 100)) / 100) * @intToFloat(f32, self.current_row) / @intToFloat(f32, self.max_row);
        if (chance > self.leaf_chance) {
            var div_x = get_rot_x(deg * 2) * bw;
            var div_y = get_rot_y(deg * 2) * bw;

            self.leaves.append(Leaf{
                .row = self.current_row,
                .r = bw,
                .v1 = rl.Vector2{.x = nx + div_x, .y = ny + div_y},
                .v2 = rl.Vector2{.x = nx - div_x, .y = ny - div_y},
                .color = get_color(self.cs_leaf)
            }) catch |err| log.err("ERROR: {?}", .{err});
        }

        if (nx < self.left_x) {
            self.left_x = nx;
        } else if (nx > self.right_x) {
            self.right_x = nx + bw;
        }   
    }
    pub fn get_z(self: *Plant) f32 {
        return self.branches.items[0].items[0].v1.y;
    }
    fn get_next_pos(self: *Plant, a: f32, b: f32) f32 {
        return b + (a - b) * @intToFloat(f32, self.grow_timer) / @intToFloat(f32, self.grow_time); 
    }
    fn grow(self: *Plant, allocator: std.mem.Allocator) void {
        self.append_row(allocator) catch |err| log.err("ERROR: {?}", .{err});
        var prev_row = self.branches.items[self.current_row].items;
        
        for (prev_row) |*b, i| {
            _ = i;
            var split = rl.GetRandomValue(0, 100);
            if (self.split_chance > split) {
                self.add_branch(b.deg - self.get_angle(), b);
                self.add_branch(b.deg + self.get_angle(), b);
            } else {
                self.add_branch(b.deg, b);
            }
        }
        self.current_row += 1;
    }
    pub fn init(self: *Plant, allocator: std.mem.Allocator, x: f32, y: f32, random_row: bool) anyerror!void {
        const scale = y / lyra.game_height * lyra.sx;
        self.start_y = y;
        self.branches = ArrayList(ArrayList(Branch)).init(allocator);
        self.leaves = ArrayList(Leaf).init(allocator);

        var angle: i32 = -90;
        try self.append_row(allocator);
        try self.branches.items[0].append(Branch{
            .deg = angle,
            .v1 = rl.Vector2{ .x = x, .y = y},
            .v2 = rl.Vector2{ .x = x, .y = y - self.h},
            .w = self.w * scale,
            .h = self.h * scale,
            .color = get_color(self.cs_branch),
        });
        self.grow_timer = rl.GetRandomValue(0, self.grow_time);
        if (random_row) {
            var grow_to_row = rl.GetRandomValue(0, self.max_row);
            while (self.current_row < grow_to_row) {
                self.grow(allocator);
            }
        }
    }
    pub fn update(self: *Plant, allocator: std.mem.Allocator, _: f32) anyerror!void {
        if (self.grow_timer > 0) {
            self.grow_timer -= 1;
        }
        if (self.grow_timer == 0 and self.current_row < self.max_row) {
            self.grow(allocator);
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
    pub fn deinit(self: *Plant) void {
        for (self.branches.items) |*row, i| {
            _ = i;
            row.deinit();
        }
        self.branches.deinit();
        self.leaves.deinit();
    }
};


