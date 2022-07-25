const std = @import("std");
const rl = @import("raylib/raylib.zig");


pub const screen_width : f16 = 800;
pub const screen_height: f16 = 600;

pub const key_right = [_]rl.KeyboardKey{rl.KeyboardKey.KEY_RIGHT, rl.KeyboardKey.KEY_D};
pub const key_left  = [_]rl.KeyboardKey{rl.KeyboardKey.KEY_LEFT, rl.KeyboardKey.KEY_A};
pub const key_up    = [_]rl.KeyboardKey{rl.KeyboardKey.KEY_UP, rl.KeyboardKey.KEY_W};
pub const key_down  = [_]rl.KeyboardKey{rl.KeyboardKey.KEY_DOWN, rl.KeyboardKey.KEY_S};

pub var start_x : f16 = 0;
pub var end_x : f16 = 0;
pub var start_y : f16 = 200;
pub var end_y: f16 = 600;
pub var cx : f32 = 1000;
pub var zoom : f16 = 1;
pub var sx : f16 = 1;
pub var mouse_x : f16 = 0;
pub var mouse_y : f16 = 0;

pub var time: f32 = 0;
