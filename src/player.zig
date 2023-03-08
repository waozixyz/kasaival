const std = @import("std");
const rl = @import("raylib/raylib.zig");

const common = @import("common.zig");

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
    for (common.key_right, 0..) |key, i| {
        _ = i;
        if (rl.IsKeyDown(key)) {
            dir.x = 1;
        }
    }
    for (common.key_left, 0..) |key, i| {
        _ = i;
        if (rl.IsKeyDown(key)) {
            dir.x = -1;
        }
    }
    for (common.key_up, 0..) |key, i| {
        _ = i;
        if (rl.IsKeyDown(key)) {
            dir.y = -1;
        }
    }
    for (common.key_down, 0..) |key, i| {
        _ = i;
        if (rl.IsKeyDown(key)) {
            dir.y = 1;
        }
    }
    if (dir.y == 0 and dir.x == 0) {
        // check mouse press
        if (rl.IsMouseButtonDown(rl.MouseButton.MOUSE_BUTTON_LEFT)) {
            var diff = rl.Vector2{ .x = common.mouse_x - x + common.cx, .y = common.mouse_y - y };
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
    hp: f16 = 100,
    xp: f16 = 0,
    speed: f16 = 0.5,
    frozen: bool = false,

    pub fn init(self: *Player, allocator: std.mem.Allocator) void {
        self.position = rl.Vector2{ .x = common.cx + common.screen_width * 0.5, .y = common.screen_height * 0.8 };
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
        var eye_bound = common.screen_width / 5;
        if ((x + dx < common.cx + eye_bound and common.cx > 0) or (x + dx > common.cx + common.screen_width - eye_bound and common.cx < common.end_x - common.screen_width)) {
            common.cx += dx;
        }

        if (x + dx < common.cx + self.get_radius() and dx < 0) {
            self.position.x = common.cx + self.get_radius();
        } else if (x + dx > common.cx + common.screen_width - self.get_radius()) {
            self.position.x = common.cx + common.screen_width - self.get_radius();
        } else {
            self.position.x += dx;
        }
        // y limits
        var min_y = common.start_y - self.get_radius() * 0.5;
        var max_y = common.screen_height - self.get_radius();
        if (y + dy > max_y and dy > 0) {
            self.position.y = max_y;
        } else if (y + dy < min_y and dy < 0) {
            self.position.y = min_y;
        } else {
            self.flame.scale = self.position.y / common.end_y * common.sx;
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
