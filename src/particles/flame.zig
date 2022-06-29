const std = @import("std");
const rl = @import("../raylib/raylib.zig");


const lyra = @import("../lyra.zig");

const print = std.debug.print;
const ArrayList = std.ArrayList;

const Particle = struct{
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


pub const Flame = struct{
    amount: i8 = 60,
    lifetime: f16 = 3,
    scale: f32 = 1,
    radius: f16 = 48,
    color: [4]u8 = [4]u8{180, 50, 60, 160},
    particles: ArrayList(Particle) = undefined,
    pub fn init(self: *Flame, allocator: std.mem.Allocator) void {
        self.particles = ArrayList(Particle).init(allocator);
    }
    fn get_particle(self: *Flame, position: rl.Vector2) Particle {
        const vel_x = rl.GetRandomValue(-3, 3);
        const vel_x_end = @intToFloat(f16, rl.GetRandomValue(-2 - vel_x, 2 - vel_x));
        const shrink_factor = @intToFloat(f16, rl.GetRandomValue(90, 99)) * 0.01;
        const particle_size = @intToFloat(f16, rl.GetRandomValue(@floatToInt(u8, self.radius * 0.8), @floatToInt(u8, self.radius)));
        const size = particle_size * self.scale;
        return Particle{
            .size = size,
            .lifetime = self.lifetime,
            .start_y = @floatToInt(u16, position.y + size),
            .position = position,
            .vel_start = rl.Vector2{.x = @intToFloat(f16, vel_x), .y = -3},
            .vel_end = rl.Vector2{.x =  vel_x_end, .y = -3},
            .color = self.color,
            .color_start = self.color,
            .color_end = [4]u8{100, 30, 20, 200},
            .shrink_factor = shrink_factor,
            
        };
    }
    fn u8ToColor(color: [4]u8) rl.Color {
        return rl.Color{.r = color[0], .g = color[1], .b = color[2], .a = color[3]};
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
        }
    }

    pub fn update(self: *Flame, position: rl.Vector2) void {
        if (self.particles.items.len < self.amount) {
            var p = self.get_particle(position);
            append_particle(self, p) catch |err| {
                std.log.info("Caught error: {s}", .{ err });
            };
        }
        for (self.particles.items) |*p, i| {
            if (p.lifetime <= 0) {
                self.particles.items[i] = self.get_particle(position);
            }
            var pp = p.lifetime / self.lifetime;
            if (pp > 0) {
                p.position.x += p.vel_start.x * pp + p.vel_end.x * (1 - pp);
                p.position.y += p.vel_start.y * pp + p.vel_end.y * (1 - pp);
                update_colors(p, pp);
                if (pp < 0.2) {

                    p.start_y = @floatToInt(u16, position.y + p.size);
                }

                p.size *= p.shrink_factor;

            }
            p.lifetime -= 0.1;
        }
    }
    pub fn draw(self: *Flame, i: usize) void {
        var p = self.particles.items[i];
        var v = rl.Vector2{.x = p.position.x - p.size * 0.5, .y = p.position.y};
        rl.DrawCircleV(v, p.size, u8ToColor(p.color));
    }
    
    pub fn deinit(self: *Flame) void {
        self.particles.deinit();
    }
};

