const std = @import("std");
const rl = @import("raylib/raylib.zig");

const lyra = @import("lyra.zig");
const utils = @import("utils.zig");

const math = std.math;

const ArrayList = std.ArrayList;
const print = std.debug.print;

const Star = struct {
    pos: rl.Vector2,
    radius: f32,
    color: rl.Color,
};

const cx_scale = 0.2;

fn get_mhd(h_off: u32) f16 {
    return @intToFloat(f16, lyra.get_minute() + (lyra.get_hour() - h_off) * 60);
}

fn get_mhn(h_off: u32) f16 {
    return @intToFloat(f16, (60 - lyra.get_minute()) + (h_off - lyra.get_hour()) * 60);
}

fn rand_y() f32 {
    return utils.f32_rand(0, lyra.screen_height);
}
fn rand_x() f32 {
    return utils.f32_rand(-20 / cx_scale, lyra.screen_width / cx_scale);
}
fn rand_pos() rl.Vector2 {
    return rl.Vector2{.x = rand_x(), .y = rand_y()};
}
pub const Sky = struct{
    stars: ArrayList(Star) = undefined,
    nebula: rl.Texture2D = undefined,
    nebula_y: f32 = -lyra.screen_height,
    sun: Star = undefined,
    pub fn init(self: *Sky, allocator: std.mem.Allocator) !void {
        self.nebula = rl.LoadTexture("assets/nebula.png");
        self.sun = Star{
            .pos = rand_pos(),
            .radius = 42,
            .color = rl.YELLOW,
        };
        self.stars = ArrayList(Star).init(allocator);
        var i: usize = 0;
        while (true)  {
            var star = Star{
                .pos = rand_pos(),
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
    pub fn update(self: *Sky, dt: f32) void {
        var vy = dt * lyra.time_speed;
        self.nebula_y += vy;
        if (self.nebula_y > 0) {
            self.nebula_y -= lyra.screen_height;
        }
        self.sun.pos.y += vy;
        if (self.sun.pos.y > lyra.screen_height) {
            self.sun.pos.y -= lyra.screen_height + self.sun.radius;
            self.sun.pos.x = rand_x();
        }
        for (self.stars.items) |*s, i| {
            _ = i;
            s.pos.y += vy;

            if (s.pos.y > lyra.screen_height) {
                s.pos.y -= lyra.screen_height + s.radius;
                s.pos.x = rand_x();
            }
        }
    }
    pub fn predraw(self: *Sky) void {
        var cx = lyra.cx * cx_scale;
        var hour = lyra.get_hour();
        //var minute = lyra.get_minute();
        // draw blue sky
        var r_f: f16 = 8;
        var g_f: f16 = 24;
        var b_f: f16 = 6;

        var t_r: f16 = 0;
        var t_g: f16 = 0;
        var t_b: f16 = 0;

        if (hour <= 12) {
            t_b = get_mhd(0) / b_f;
            t_g = get_mhd(0) / g_f;
        } else {
            t_b = get_mhn(26) / b_f;
            t_g = get_mhn(26) / g_f;
        }

        // sunset and sunrise
        if (hour >= 4 and hour <= 7) {
            t_r = get_mhd(4) / r_f;
        } else if (hour > 7 and hour < 12) {
            t_r = get_mhn(12) / r_f;
        } else if (hour >= 17 and hour <= 20) {
            t_r = get_mhd(17)/ r_f;
        } else if (hour > 20  and hour < 22) {
            t_r = get_mhn(22) / r_f;
        } 

        // convert colors to u8
        var r = @floatToInt(u8, t_r);
        var g = @floatToInt(u8, t_g);
        var b = @floatToInt(u8, t_b);
        // set color for sky
        var color = rl.Color{.r = r, .g = g, .b = b, .a = 255};

        var start_v = rl.Vector2{.x = 0, .y = 0};
        var end_v = rl.Vector2{.x = lyra.screen_width, .y = lyra.start_y};
        
        rl.DrawRectangleV(start_v, end_v, color);
        rl.BeginBlendMode(@enumToInt(rl.BlendMode.BLEND_ADDITIVE));

        for (self.stars.items) |*s, i| {
            _ = i;
            s.color.a = @floatToInt(u8, utils.clamp(255 - (t_b + t_g) * 1.2, 0, 255));
            var pos = s.pos;
            pos.x -= cx;
            rl.DrawCircleV(pos, s.radius, s.color);    
        }
        var pos = self.sun.pos;
        pos.x -= cx;
        rl.DrawCircleV(pos, self.sun.radius, self.sun.color);    

        rl.EndBlendMode();
        color = rl.WHITE;
        color.a = 200;
        var x = -cx;
        var scale: f32 = 10;
        while (x < lyra.screen_width) {
            var y = self.nebula_y;
            while (y < lyra.screen_height) {
                rl.DrawTextureEx(self.nebula, rl.Vector2{.x = x, .y = y}, 0, scale, color);  
                y += @intToFloat(f32, self.nebula.height) * scale;
            }
            x += @intToFloat(f32, self.nebula.width) * scale;
        } 
    }

    pub fn deinit(self: *Sky) void {
        self.stars.deinit();
        rl.UnloadTexture(self.nebula);
    }
};

