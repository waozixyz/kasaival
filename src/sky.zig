const std = @import("std");
const rl = @import("raylib");

const lyra = @import("lyra.zig");

const print = std.debug.print;
const math = std.math;

pub const Sky = struct{
    nebula: rl.Texture,
    planets: rl.Texture,

    pub fn load(_: *Sky) void {
    }
    pub fn update(_: *Sky) void {

    }
    pub fn draw(self: *Sky) void {
        // draw blue sky

        var color = rl.Color{.r = 30, .g = 10, .b = 150, .a = 200};
        var start_v = rl.Vector2{.x = 0, .y = 0};
        var end_v = rl.Vector2{.x = lyra.game_width, .y = lyra.start_y};
        rl.DrawRectangleV(start_v, end_v, color);

        rl.DrawTexture(self.planets, 0, 0, rl.WHITE);
        rl.DrawTexture(self.nebula, 0, 0, rl.WHITE);

        
    }
    pub fn unload(self: *Sky) void {
        rl.UnloadTexture(self.nebula);
        rl.UnloadTexture(self.planets);

    }

};


pub fn new() Sky {
    return Sky{
        .nebula = rl.LoadTexture("assets/sky/nebula.png"),
        .planets = rl.LoadTexture("assets/sky/planets.jpg")
        };

}
