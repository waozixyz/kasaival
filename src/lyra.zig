const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});


pub const screen_width : f16 = 1920;
pub const screen_height: f16 = 1080;

pub const game_width : f16 = 3000;
pub const game_height: f16 = 1080;

pub const key_right = [_]u16{ray.KEY_RIGHT, ray.KEY_D};
pub const key_left  = [_]u16{ray.KEY_LEFT, ray.KEY_A};
pub const key_up    = [_]u16{ray.KEY_UP, ray.KEY_W};
pub const key_down  = [_]u16{ray.KEY_DOWN, ray.KEY_S};


pub const ScreenNames = enum {
    title,
    game,
};

pub var next : ScreenNames = ScreenNames.game;

pub var start_x : f16 = 0;
pub var start_y : f16 = 400;
pub var cx : f32 = 0;
pub var zoom : f16 = 1;
pub var mouse_x : f16 = 0;
pub var mouse_y : f16 = 0;