const std = @import("std");
const Screen = @import("screens/screen.zig").Screen;

pub const ScreenNames = enum { arcade, title };

pub var next : ScreenNames = ScreenNames.arcade;

pub const screens = std.ComptimeStringMap(Screen, .{
    .{ "title", @import("screens/title.zig").screen },
    .{ "arcade", @import("screens/arcade.zig").screen },
});