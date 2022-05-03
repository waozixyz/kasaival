const std = @import("std");
const plant = @import("plant.zig");

const Array = std.ArrayList;
const Branch = plant.Branch;
const Leaf = plant.Leaf;
const Plant = plant.Plant;
const test_allocator = std.testing.allocator;


pub fn oak() Plant {
    return Plant{
        .branches = Array(Array(Branch)).init(test_allocator),
        .leaves = Array(Leaf).init(test_allocator),
        .leaf_chance = 0.5,
        .max_row = 10,
        .current_row = 0,
        .w = 20,
        .h = 30,
        .split_chance = 40,
        .split_angle = .{20, 30},
        .cs_branch = .{125, 178, 122, 160, 76, 90},
        .cs_leaf = .{150, 204, 190, 230, 159, 178},
        .left_x = 9999999,
        .right_x = -9999999,
        .grow_timer = 0,
        .grow_time = 20,
    };
}