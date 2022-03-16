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
    color: [4]u8,
    color_start: [4]u8,
    color_end: [4]u8,
};


pub const Flame = struct{
    amount: i8,
    lifetime: f16,
    scale: f16,
    radius: f16,
    color: [4]u8,
    particles: ArrayList(Particle),
    fn get_particle(self: *Flame, x: f32, y: f32) Particle {
     
        const rand = std.crypto.random;

        const vel_x = rand.intRangeAtMost(i16, -3, 3);
        const vel_x_end = @intToFloat(f16, rand.intRangeAtMost(i16, -2 - vel_x, 2 - vel_x));
        const shrink_factor = @intToFloat(f16, rand.intRangeAtMost(u8, 90, 99)) * 0.01;
        return Particle{
            .scale = self.scale,
            .lifetime = self.lifetime,
            .position = ray.Vector2{.x = x, .y = y * 0.8 * self.scale},
            .vel_start = ray.Vector2{.x = @intToFloat(f16, vel_x), .y = -3},
            .vel_end = ray.Vector2{.x =  vel_x_end, .y = -3},
            .color = self.color,
            .color_start = self.color,
            .color_end = [4]u8{100, 30, 20, 200},
            .shrink_factor = shrink_factor,
            
        };
    }
    fn u8ToColor(color: [4]u8) ray.Color {
        return ray.Color{.r = color[0], .g = color[1], .b = color[2], .a = color[3]};
    }

    fn append_particle(self: *Flame, p: Particle) !void {
        var append = try self.particles.append(p);
        _ = append;
    }
    pub fn get_radius(self: *Flame) f32 {
        return self.radius * self.scale;
    }
    
    fn update_colors(p: *Particle, pp: f16) void {
        for (p.color) |_, i| {
            p.color[i] = @floatToInt(u8, @intToFloat(f16, p.color_start[i]) * pp + @intToFloat(f16, p.color_end[i]) * (1 - pp));
           // print(" {d} ", .{p.color[i]});
        }
    }

    pub fn update(self: *Flame, x: f32, y: f32) void {
        if (self.particles.items.len < self.amount) {
            var p = self.get_particle(x, y);
            append_particle(self, p) catch |err| {
                std.log.info("Caught error: {s}", .{ err });
            };
        }
        for (self.particles.items) |*p, i| {
            if (p.lifetime <= 0) {
                self.particles.items[i] = self.get_particle(x, y);
            }
            var pp = p.lifetime / self.lifetime;
            if (pp > 0) {
                p.position.x += p.vel_start.x * pp + p.vel_end.x * (1 - pp);
                p.position.y += p.vel_start.y * pp + p.vel_end.y * (1 - pp);
                update_colors(p, pp);

                p.scale *= p.shrink_factor;

            }
            p.lifetime -= 0.1;
        }
    }
    pub fn draw(self: *Flame) void {
        //p = self.particles[i];
        for (self.particles.items) |*p, i| {
            _ = i;
            var x = @floatToInt(i16, p.position.x - self.radius * p.scale * 0.5);
            ray.DrawCircle(x, @floatToInt(i16, p.position.y), self.radius * p.scale, u8ToColor(p.color));
        }
    }
    
    pub fn unload(self: *Flame) void {
        self.particles.deinit();
    }
};


pub fn new() Flame {
    const color = [4]u8{180, 50, 60, 200};
    return Flame{
        .particles = ArrayList(Particle).init(test_allocator),
        .radius = 48,
        .scale = 1,
        .color = color,
        .lifetime = 5,
        .amount = 60,
    };
}