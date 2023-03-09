const std = @import("std");
const rl = @import("raylib/raylib.zig");

const config = @import("config.zig");

const Flame = @import("particles/flame.zig").Flame;

const print = std.debug.print;
const math = std.math;

fn get_angle(diff: rl.Vector2) rl.Vector2 {
    var angle: f32 = math.atan2(f32, diff.x, diff.y);
    if (angle < 0) {
        angle += math.pi * 2.0;
    }
    return rl.Vector2{ .x = math.sin(angle), .y = math.cos(angle) };
}

fn get_direction(x: f32, y: f32) rl.Vector2 {
    var dir = rl.Vector2{ .x = 0.0, .y = 0.0 };
    for (config.key_right) |key, i| {
        _ = i;
        if (rl.IsKeyDown(key)) {
            dir.x = 1;
        }
    }
    for (config.key_left) |key, i| {
        _ = i;
        if (rl.IsKeyDown(key)) {
            dir.x = -1;
        }
    }
    for (config.key_up) |key, i| {
        _ = i;
        if (rl.IsKeyDown(key)) {
            dir.y = -1;
        }
    }
    for (config.key_down) |key, i| {
        _ = i;
        if (rl.IsKeyDown(key)) {
            dir.y = 1;
        }
    }
    if (dir.y == 0 and dir.x == 0) {
        // check mouse press
        if (rl.IsMouseButtonDown(rl.MouseButton.MOUSE_BUTTON_LEFT)) {
            var diff = rl.Vector2{ .x = config.mouse_x - x + config.cx, .y = config.mouse_y - y };
            const offset = 5;
            if (@fabs(diff.x) > offset or @fabs(diff.y) > offset) {
                dir = get_angle(diff);
            }
        }
    }
    return dir;
}
pub const Player = struct {
    flame: Flame = Flame{},
    position: rl.Vector2 = undefined,
    hp: f32 = 100,
    xp: f32 = 0,
    speed: f32 = 0.5,
    frozen: bool = false,

    pub fn init(self: *Player, allocator: std.mem.Allocator) void {
        self.position = rl.Vector2{ .x = config.cx + config.screen_width * 0.5, .y = config.screen_height * 0.8 };
        self.flame.init(allocator);
    }
    pub fn get_radius(self: *Player) f32 {
        return self.flame.radius * self.flame.scale;
    }
    pub fn update(self: *Player) !void {
        const x = self.position.x;
        const y = self.position.y;
        var dir: rl.Vector2 = rl.Vector2{ .x = 0, .y = 0 };
        if (!self.frozen) {
            dir = get_direction(x, y);
        }
        var dx = dir.x * self.speed * self.get_radius();
        var dy = dir.y * self.speed * self.get_radius();
        var eye_bound = config.screen_width / 5;
        if ((x + dx < config.cx + eye_bound and config.cx > 0) or (x + dx > config.cx + config.screen_width - eye_bound and config.cx < config.end_x - config.screen_width)) {
            config.cx += dx;
        }

        if (x + dx < config.cx + self.get_radius() and dx < 0) {
            self.position.x = config.cx + self.get_radius();
        } else if (x + dx > config.cx + config.screen_width - self.get_radius()) {
            self.position.x = config.cx + config.screen_width - self.get_radius();
        } else {
            self.position.x += dx;
        }
        // y limits
        var min_y = config.start_y - self.get_radius() * 0.5;
        var max_y = config.screen_height - self.get_radius();
        if (y + dy > max_y and dy > 0) {
            self.position.y = max_y;
        } else if (y + dy < min_y and dy < 0) {
            self.position.y = min_y;
        } else {
            self.position.y += dy;
        }
        try self.flame.update(self.position);
    }
    pub fn draw(self: *Player) void {
        self.flame.draw();
    }
    pub fn deinit(self: *Player) void {
        self.flame.deinit();
    }
};
