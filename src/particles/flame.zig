const std = @import("std");
const rl = @import("../raylib/raylib.zig");
const common = @import("../common.zig");

const print = std.debug.print;
const ArrayList = std.ArrayList;

const Particle = struct {
    start_y: u16,
    position: rl.Vector2,
    lifetime: f16,
    vel_start: rl.Vector2,
    vel_end: rl.Vector2,
    shrink_factor: f16,
    size: f32,
    color: [4]u8,
    color_start: [4]u8,
    color_end: [4]u8,
};

pub const Flame = struct {
    amount: u8 = 70,

    lifetime: f16 = 40,
    scale: f32 = 1,
    radius: f16 = 14,
    color_start: [4]u8 = [4]u8{ 200, 50, 80, 200 },
    color_end: [4]u8 = [4]u8{ 120, 30, 60, 20 },
    particles: ArrayList(Particle) = undefined,

    fn get_color_end(
        self: *Flame,
    ) [4]u8 {
        var rtn = self.color_end;
        rtn[0] -= @intCast(u8, rl.GetRandomValue(0, 40));
        rtn[1] -= @intCast(u8, rl.GetRandomValue(0, 20));
        rtn[2] -= @intCast(u8, rl.GetRandomValue(0, 20));
        rtn[3] -= @intCast(u8, rl.GetRandomValue(0, 20));
        return rtn;
    }

    pub fn init(self: *Flame, allocator: std.mem.Allocator) void {
        self.particles = ArrayList(Particle).init(allocator);
    }
    fn get_particle(self: *Flame, position: rl.Vector2) Particle {
        const vel_x: f32 = @intToFloat(f16, rl.GetRandomValue(-3, 3)) * self.scale;
        const vel_x_end = (@intToFloat(f16, rl.GetRandomValue(-2, 2)) - vel_x) * self.scale;
        const shrink_factor = @intToFloat(f16, rl.GetRandomValue(95, 90)) * 0.01;
        const particle_size = self.radius;
        const size = particle_size * self.scale;
        const vel_y = -4 * self.scale;
        return Particle{
            .size = size,
            .lifetime = self.lifetime,
            .start_y = @floatToInt(u16, position.y),
            .position = position,
            .vel_start = rl.Vector2{ .x = vel_x, .y = vel_y },
            .vel_end = rl.Vector2{ .x = vel_x_end, .y = vel_y },
            .color = self.color_start,
            .color_start = self.color_start,
            .color_end = self.get_color_end(),
            .shrink_factor = shrink_factor,
        };
    }
    fn u8ToColor(color: [4]u8) rl.Color {
        return rl.Color{ .r = color[0], .g = color[1], .b = color[2], .a = color[3] };
    }

    pub fn get_radius(self: *Flame) f32 {
        return self.radius * self.scale;
    }

    fn update_colors(p: *Particle, pp: f16) void {
        for (p.color, 0..) |_, i| {
            p.color[i] = @floatToInt(u8, @intToFloat(f16, p.color_start[i]) * pp + @intToFloat(f16, p.color_end[i]) * (1 - pp));
        }
    }

    pub fn update(self: *Flame, position: rl.Vector2) !void {
        if (self.particles.items.len < self.amount) {
            var p = self.get_particle(position);
            try self.particles.append(p);
        }
        for (self.particles.items, 0..) |*p, i| {
            if (p.lifetime <= 0) {
                self.particles.items[i] = self.get_particle(position);
            }
            var pp = p.lifetime / self.lifetime;
            if (pp > 0) {
                p.position.x += p.vel_start.x * pp + p.vel_end.x * (1 - pp);
                p.position.y += p.vel_start.y * pp + p.vel_end.y * (1 - pp);
                update_colors(p, pp);

                p.size *= p.shrink_factor;
            }
            p.lifetime -= 1;
        }
    }
    pub fn draw(self: *Flame) void {
        var i: usize = 0;
        var len = self.particles.items.len;
        while (i < len) {
            var p = self.particles.items[len - i - 1];

            var v = rl.Vector2{ .x = p.position.x, .y = p.position.y };
            rl.DrawCircleV(v, p.size, u8ToColor(p.color));
            i += 1;
        }
    }

    pub fn deinit(self: *Flame) void {
        self.particles.deinit();
    }
};
