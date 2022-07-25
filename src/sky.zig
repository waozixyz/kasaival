const std = @import("std");
const rl = @import("raylib/raylib.zig");

const lyra = @import("lyra.zig");
const utils = @import("utils.zig");

const math = std.math;

const ArrayList = std.ArrayList;

const Star = struct {
    pos: rl.Vector2,
    radius: f32,
    color: rl.Color,
};

pub const Sky = struct{
    stars: ArrayList(Star) = undefined,

    pub fn init(self: *Sky, allocator: std.mem.Allocator) !void {
        self.stars = ArrayList(Star).init(allocator);
        var i: usize = 0;
        while (true)  {
            var star = Star{
                .pos = rl.Vector2{
                    .x = utils.f32_rand(0, lyra.screen_width),
                    .y = utils.f32_rand(0, lyra.start_y),
                },
                .radius = utils.f32_rand(1, 5),
                .color = rl.Color {
                    .r = utils.u8_rand(200, 255),
                    .g = utils.u8_rand(200, 255),
                    .b = utils.u8_rand(0, 200),
                    .a = utils.u8_rand(200, 255),
                    
                }
            };
            
            try self.stars.append(star); 
            if (i == 100)
                break;
            i += 1;
        }
    }
    pub fn update(_: *Sky) void {
    }
    pub fn predraw(self: *Sky) void {
        // draw blue sky

        var color = rl.Color{.r = 30, .g = 10, .b = 150, .a = 200};
        var start_v = rl.Vector2{.x = 0, .y = 0};
        var end_v = rl.Vector2{.x = lyra.screen_width, .y = lyra.start_y};
        rl.DrawRectangleV(start_v, end_v, color);
        rl.BeginBlendMode(@enumToInt(rl.BlendMode.BLEND_ADDITIVE));

        for (self.stars.items) |*s, i| {
            _ = i;
            var x = s.pos.x - lyra.cx * 0.02;

            rl.DrawCircleV(rl.Vector2{.x = x, .y = s.pos.y}, s.radius, s.color);    
        }

        rl.EndBlendMode();
    }

    pub fn deinit(self: *Sky) void {
        self.stars.deinit();

    }
};

