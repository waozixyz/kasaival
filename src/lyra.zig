const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});

pub const ScreenNames = enum {
    title,
    game,
};

pub var next : ScreenNames = ScreenNames.game;
