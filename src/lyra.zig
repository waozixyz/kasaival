const std = @import("std");
const rl = @import("raylib");


pub const screen_width : f16 = 1920;
pub const screen_height: f16 = 1080;

pub const game_width : f16 = 3000;
pub const game_height: f16 = 1080;

pub const key_right = [_]rl.KeyboardKey{rl.KeyboardKey.KEY_RIGHT, rl.KeyboardKey.KEY_D};
pub const key_left  = [_]rl.KeyboardKey{rl.KeyboardKey.KEY_LEFT, rl.KeyboardKey.KEY_A};
pub const key_up    = [_]rl.KeyboardKey{rl.KeyboardKey.KEY_UP, rl.KeyboardKey.KEY_W};
pub const key_down  = [_]rl.KeyboardKey{rl.KeyboardKey.KEY_DOWN, rl.KeyboardKey.KEY_S};


pub const ScreenNames = enum { game, title };

pub var next : ScreenNames = ScreenNames.game;

pub var start_x : f16 = 0;
pub var start_y : f16 = 400;
pub var cx : f32 = 0;
pub var zoom : f16 = 1;
pub var mouse_x : f16 = 0;
pub var mouse_y : f16 = 0;