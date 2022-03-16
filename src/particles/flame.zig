const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});

const lyra = @import("../lyra.zig");

const print = std.debug.print;
const ArrayList = std.ArrayList;
const test_allocator = std.testing.allocator;

const Particle = struct{
    position: ray.Vector2,
    lifetime: f16,
    vel_start: ray.Vector2,
    vel_end: ray.Vector2,
    shrink_factor: f16,
    scale: f16,
    color: ray.Color,
    color_start: ray.Color,
    color_end: ray.Color,
};


pub const Flame = struct{
    amount: i8,
    lifetime: f16,
    scale: f16,
    radius: f16,
    color: ray.Color,
    particles: ArrayList(Particle),
    fn get_particle(self: *Flame, x: f32, y: f32) Particle {
     
        const rand = std.crypto.random;

        const vel_x = @intToFloat(f32, rand.intRangeAtMost(u8, 0, 6)) - 3;
        const vel_x_end = (@intToFloat(f32, rand.intRangeAtMost(u8, 0, 4)) - vel_x - 2) * 1.6;
        const shrink_factor = @intToFloat(f16, rand.intRangeAtMost(u8, 95, 99)) * 0.01;
        return Particle{
            .scale = self.scale,
            .lifetime = self.lifetime,
            .position = ray.Vector2{.x = x, .y = y * 0.8 * self.scale},
            .vel_start = ray.Vector2{.x = vel_x, .y = -3},
            .vel_end = ray.Vector2{.x =  vel_x_end, .y = -3},
            .color = self.color,
            .color_start = self.color,
            .color_end = ray.Color{.r = 0, .g = 30, .b = 20, .a = 0},
            .shrink_factor = shrink_factor,
            
        };
    }
    fn append_particle(self: *Flame, p: Particle) !void {
        var append = try self.particles.append(p);
        _ = append;
    }
    pub fn get_radius(self: *Flame) f32 {
        return self.radius * self.scale;
    }
    fn update_colors(p: *Particle, pp: f16) void {
        p.color.r = @floatToInt(u8, @intToFloat(f16, p.color_start.r) * pp + @intToFloat(f16, p.color_end.r) * (1 - pp));
        p.color.g = @floatToInt(u8, @intToFloat(f16, p.color_start.g) * pp + @intToFloat(f16, p.color_end.g) * (1 - pp));
        p.color.b = @floatToInt(u8, @intToFloat(f16, p.color_start.b) * pp + @intToFloat(f16, p.color_end.b) * (1 - pp));
        p.color.a = @floatToInt(u8, @intToFloat(f16, p.color_start.a) * pp + @intToFloat(f16, p.color_end.a) * (1 - pp));

    }
    pub fn update(self: *Flame, x: f32, y: f32) void {
        if (self.particles.items.len < self.amount) {
            var p = self.get_particle(x, y);
            append_particle(self, p) catch |err| {
                std.log.info("Caught error: {s}", .{ err });
            };
        }
        for (self.particles.items) |*p, i| {
            if (p.lifetime == 0) {
                self.particles.items[i] = self.get_particle(x, y);
            }
            var pp = p.lifetime / self.lifetime;
            if (p.lifetime < self.lifetime) {
                p.position.x += p.vel_start.x * pp + p.vel_end.x * (1 - pp);
                p.position.y += p.vel_start.y * pp + p.vel_end.y * (1 - pp);
            }
            update_colors(p, pp);
            p.scale *= p.shrink_factor;
            p.lifetime -= 1;
        }
    }
    pub fn draw(self: *Flame) void {
        //p = self.particles[i];
        for (self.particles.items) |*p, i| {
            _ = i;
            var x = @floatToInt(i16, p.position.x - self.radius * p.scale * 0.5);
            ray.DrawCircle(x, @floatToInt(i16, p.position.y), self.radius * p.scale, p.color);
        }
    }
    
    pub fn unload(self: *Flame) void {
        self.particles.deinit();
    }
};


pub fn new() Flame {
    const color = ray.Color{.r = 180, .g = 30, .b = 40, .a = 200};
    const amount = 60;
    return Flame{
        .particles = ArrayList(Particle).init(test_allocator),
        .radius = 48,
        .scale = 1,
        .color = color,
        .lifetime = amount,
        .amount = amount,
    };
}